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

  ------ALU component
  component ALU is
    PORT(
      ALU_CONTROL_CODE: in alu_operation; --> on of the types we defined in types, contains a subset of signals for ALU
      data_A: in std_logic_vector (31 DOWNTO 0); --when shift operation, ALU shifts B by shamt
      data_B: in std_logic_vector (31 DOWNTO 0);
      shamt: in std_logic_vector (31 DOWNTO 0);
      RESULT: out std_logic_vector (31 DOWNTO 0)
    );

  END component;
  ------

  --Intermediate buffer signals
  signal shamt_for_alu : std_logic_vector (31 DOWNTO 0);
  signal ALU_data_A : std_logic_vector (31 DOWNTO 0);
  signal ALU_data_B : std_logic_vector (31 DOWNTO 0);
  signal ALU_res : std_logic_vector (31 DOWNTO 0);
  signal ALU_res_to_mem : std_logic_vector (31 DOWNTO 0);

  begin

    --Might need to manipulate signals here (adding multiplexors) according to the instruction (not yet)
    -------------------------------------------------------------
    --Multiplexor for shift amount: no needed since if we do lui, 16 is hardcoded in ALU already.
    shamt_for_alu <= x"000000" & "000" & EX_shift_amount; --Shift amount for the ALU coming from the ID stage (sra,sll,sra) BUT (in ALU, lui hardcoded 16 bit shift)

    --Multiplexor for data A input to ALU, can be normal data from RS register or target address to jal
    ALU_data_A <= x"0000000-4" WHEN EX_STAGE_CONTROL_SIGNALS.jump_and_link = '1' ELSE EX_data_from_RS;

    --Multiplexor for data B input to ALU, can be normal data from RT register or Immediate value for I type and address operations or PC
    ALU_data_B <= EX_sign_extended_IMM WHEN in_ctrl_EX.use_imm = '1' ELSE EX_program_counter WHEN in_ctrl_EX.jump_and_link = '1' ELSE EX_data_from_RT;

    --Multiplexor for output of the stage from ALU (not needed, all operations such as mfhi and mflo are done in ALU directly)
    ALU_res_to_mem <= ALU_res;

    -------------------------------------------------------------
    ALU_instance : ALU
		PORT MAP(
      ALU_CONTROL_CODE => EX_STAGE_CONTROL_SIGNALS.ALU_control_op,
			data_A => ALU_data_A,
			data_B => ALU_data_B,
			shamt => shamt_for_alu,
      RESULT => ALU_res
		);

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
