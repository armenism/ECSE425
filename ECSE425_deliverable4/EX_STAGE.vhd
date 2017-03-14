--EXECUTION stage
--Gets control and data from ID stage for current ALU operation, data forwarding and control signals
--for writeback stage to be forwarded further down the pipe.

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use signal_types.all

entity EX_STAGE is

  port(

    --STAGE INPUTS
    --operation related signals
    clk: in std_logic;
    rdy: in std_logic;
    reset: in std_logic;

    --Register file related data
    EX_data_from_RS: in std_logic_vector (31 downto 0);
    EX_data_from_RT: in std_logic_vector (31 downto 0);
    EX_shift_amount: in std_logic_vector (4 downto 0);

    EX_program_counter: in std_logic_vector (31 downto 0);
    EX_sign_extended_IMM: in in std_logic_vector (31 downto 0);
    EX_destination_reg_RD: in std_logic_vector (4 downto 0);

    --Control signals to current stage:
    EX_STAGE_CONTROL_SIGNALS: in EX_CTRL_SIGS;
    --Control signals to be passed to further stages:
		MEM_STAGE_CONTROL_SIGNALS: in MEM_CTRL_SIGS;
		WB_STAGE_CONTROL_SIGNALS: in WB_CTRL_SIGS;

    --STAGE OUTPUTS
    EX_ALU_result_out: out std_logic_vector (31 downto 0);
    EX_write_data_out: out std_logic_vector (31 downto 0);
    EX_destination_reg_RD_out : out std_logic_vector (4 downto 0);
    --Control signals to be passed to further stages:
    MEM_STAGE_CONTROL_SIGNALS_out: out MEM_CTRL_SIGS;
    WB_STAGE_CONTROL_SIGNALS_out: out WB_CTRL_SIGS

    );

architecture arch of EX_STAGE is

  -------------------------------------------------------------COMPONENTS

  ------Arithmetical multiplication and division component
  component standalone_multi_div_unit is
    port(
      OPERAND_A: in std_logic_vector (31 downto 0);
      OPERAND_B: in	 std_logic_vector (31 downto 0);
      OPERATION: in alu_operation; -->mult, div only to be used here from alu instruction types
      MULT_DIV_RESULT: out std_logic_vector (63 downto 0)
    );
  end component;

  ------ALU component
  component ALU is
    port(
      ALU_CONTROL_CODE: in alu_operation; --> on of the types we defined in types, contains a subset of signals for ALU
      data_A: in std_logic_vector (31 DOWNTO 0); --when shift operation, ALU shifts B by shamt
      data_B: in std_logic_vector (31 DOWNTO 0);
      shamt: in std_logic_vector (31 DOWNTO 0);
      RESULT: out std_logic_vector (31 DOWNTO 0)
    );

  end component;
  -------------------------------------------------------------SIGNALS

  --Intermediate buffer signals
  signal shamt_for_alu : std_logic_vector (31 DOWNTO 0);
  signal ALU_data_A : std_logic_vector (31 DOWNTO 0);
  signal ALU_data_B : std_logic_vector (31 DOWNTO 0);
  signal ALU_res : std_logic_vector (31 DOWNTO 0);
  signal ALU_res_to_mem : std_logic_vector (31 DOWNTO 0);

  --Intermediate multiplication signals, high bits and low bits signals for mflo and mfhi operations (since decoupled from ALU now)
  signal mult_div_low_bits: std_logic_vector (31 DOWNTO 0);
  signal mult_div_hi_bits: std_logic_vector (31 DOWNTO 0);
  signal mult_div_res: std_logic_vector (63 DOWNTO 0); --> long vector for result after multiplication/division operation. Needs to be routed to output of this stage (instead of ALU) if mflo or mfhi op was decoded

  begin

    --Might need to manipulate signals here (adding multiplexors) according to the instruction (not yet)
    -------------------------------------------------------------MUXES
    --Multiplexor for shift amount: no needed since if we do lui, 16 is hardcoded in ALU already.
    shamt_for_alu <= x"000000" & "000" & EX_shift_amount; --Shift amount for the ALU coming from the ID stage (sra,sll,sra) BUT (in ALU, lui hardcoded 16 bit shift)

    --Multiplexor for data A input to ALU, can be normal data from RS register or target address to jal
    ALU_data_A <= x"00000004" when EX_STAGE_CONTROL_SIGNALS.jump_and_link = '1' else EX_data_from_RS;

    --Multiplexor for data B input to ALU, can be normal data from RT register or Immediate value for I type (addi, ori, xori etc) and address operations or PC
    ALU_data_B <= EX_sign_extended_IMM when in_ctrl_EX.use_imm = '1' else EX_program_counter when in_ctrl_EX.jump_and_link = '1' else EX_data_from_RT;

    --Multiplexor for output of the stage from ALU
    ALU_res_to_mem <= ALU_res;

    -------------------------------------------------------------PORTMAPS
    mult_div : standalone_multi_div_unit
    PORT MAP(
      OPERAND_A => EX_data_from_RS,
      OPERAND_B => EX_data_from_RT,
      OPERATION => EX_STAGE_CONTROL_SIGNALS.ALU_control_op,
      MULT_DIV_RESULT => mult_div_res
    );

    ALU_instance : ALU
		PORT MAP(
      ALU_CONTROL_CODE => EX_STAGE_CONTROL_SIGNALS.ALU_control_op,
			data_A => ALU_data_A,
			data_B => ALU_data_B,
			shamt => shamt_for_alu,
      RESULT => ALU_res
		);

    -------------------------------------------------------------PROCESSES
    ------Process intended for mfhi mflo operations, which involve div and mult operations
    ------to be able to get higher or lower bits of the result to a general purpose register
    MFHI_MFLO_PROCESS : process (clk, reset)
    begin

      if reset = '1' then

        mult_div_low_bits <= '00000000000000000000000000000000';
        mult_div_hi_bits <= '00000000000000000000000000000000';

      elsif rising_edge(clk) then

        if EX_STAGE_CONTROL_SIGNALS.multdiv = '1' then

          mult_div_low_bits <= mult_div_res(31 DOWNTO 0);
          mult_div_hi_bits <= mult_div_res(63 DOWNTO 32);

        end if;

      end if;

    end process;

    ------Actual stage process
    EX_STAGE_PROCESS : process (clk, reset)
  	begin

      --Resetting all output to 0
  		if reset = '1' then

  			EX_ALU_result_out <= '00000000000000000000000000000000';
  			EX_write_data_out <= '00000000000000000000000000000000';
  			EX_destination_reg_RD_out <= '00000';
        MEM_STAGE_CONTROL_SIGNALS_out <= ('0','0');
        WB_STAGE_CONTROL_SIGNALS_out <= (OTHERS => '0');

      --At rising edge, assign all the signals to output
  		elsif rising_edge(clk) then

  			if rdy = '1' then
          --Forward control signals from ID to MEM though current (EX) stage
          MEM_STAGE_CONTROL_SIGNALS_out <= MEM_STAGE_CONTROL_SIGNALS;
          WB_STAGE_CONTROL_SIGNALS_out <= WB_STAGE_CONTROL_SIGNALS;

          --Assign all the computed signals
  				EX_ALU_result_out <= ALU_res_to_mem;
  				EX_write_data_out <= EX_data_from_RT;
  				EX_destination_reg_RD_out <= EX_destination_reg_RD;

  			end if;

  		end if;

  	end process;
    ------

  end arch;
