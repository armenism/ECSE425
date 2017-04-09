--Main driver reponsible to connect all the stahes in the pipelined processor.
--Will be driven from a clock coming from the testbench

--Integration part is being done here!

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.signal_types.all;

--Main driver entity connecting all the stages
ENTITY Driver IS

	PORT (
		clk				:	IN  STD_LOGIC;
		rst				: 	IN  STD_LOGIC;
		done_program_in : in STD_LOGIC;

		instr_mem_address	:	OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --mem address destined for instruction memory component (PC in 32 bit now)
      instr_mem_data  : in STD_LOGIC_VECTOR (31 DOWNTO 0);    --what we get from instruction memory after requesting the address
	 
		--MEM stage signals necessary to communicate with the main memory residing in the test bench 
		data_read_from_memory : in STD_LOGIC_VECTOR (31 DOWNTO 0);
		waitrequest_from_memory: in STD_LOGIC; 
		data_to_write_to_memory : out STD_LOGIC_VECTOR (31 DOWNTO 0);
		address_for_memory : out STD_LOGIC_VECTOR (31 DOWNTO 0);
		do_mem_write	: out STD_LOGIC;
		do_mem_read	: out STD_LOGIC
	);

END Driver;

ARCHITECTURE arch OF Driver IS

	SIGNAL ready : STD_LOGIC;
	SIGNAL init : STD_LOGIC;
	SIGNAL data_to_write_to_memory_sig :  STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL address_for_memory_sig :  STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL do_mem_write_sig	:  STD_LOGIC;
	SIGNAL do_mem_read_sig	:  STD_LOGIC;

  --Control uni declaration
	COMPONENT CPU_control_unit IS
		PORT (
			instruction 	: IN	STD_LOGIC_VECTOR (31 DOWNTO 0);
			IF_SIGS 	: OUT IF_CTRL_SIGS;
			ID_SIGS  	: OUT ID_CTRL_SIGS;
			EX_SIGS  	: OUT EX_CTRL_SIGS;
			MEM_SIGS  : OUT MEM_CTRL_SIGS;
			WB_SIGS  	: OUT WB_CTRL_SIGS
		);
	END COMPONENT;

  -- Signals needed to pass control signals from control unit to all other stages, resulting in output of the control unit
	SIGNAL IF_control_signals  : IF_CTRL_SIGS;
	SIGNAL ID_control_signals  : ID_CTRL_SIGS;
	SIGNAL EX_control_signals  : EX_CTRL_SIGS;
	SIGNAL MEM_control_signals : MEM_CTRL_SIGS;
	SIGNAL WB_control_signals  : WB_CTRL_SIGS;


  --Port map for the Instruction Fetch Stage
	COMPONENT Instruction_Fetch IS
		PORT (
					Clock	: IN	STD_LOGIC;
					Reset	: IN	STD_LOGIC;
					Init	: IN 	STD_LOGIC;
					Ready	: IN	STD_LOGIC;
					IF_Stall : IN  STD_LOGIC;
					ID_Branch_Zero : IN 	STD_LOGIC;
					ID_Branch_Address : IN	STD_LOGIC_VECTOR (31 DOWNTO 0);
					IF_Control : IN	IF_CTRL_SIGS;
					Input_From_Instruction_Memory	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
					Branch_Taken : OUT STD_LOGIC;
					IF_PC	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
					IF_Instruction : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
			);

	END COMPONENT;

	SIGNAL IF_PC : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL IF_instruction : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL branch_taken : STD_LOGIC;

	COMPONENT instruction_decode  IS
		PORT (
			clock 			: IN	STD_LOGIC;
			rst				: IN	STD_LOGIC;
			rd_ready			: IN	STD_LOGIC;
			wr_done			: IN	STD_LOGIC;
			branch_taken	: IN 	STD_LOGIC; --Input from IF to know if the branch was taken

			--Write back inputs
			WB_ctrl	: IN WB_CTRL_SIGS; --Signals coming from MEM to WB
			WB_data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			WB_addr 	: IN STD_LOGIC_VECTOR (4 DOWNTO 0); --Destination register

			PC_in				: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			instruction_in	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);

			--memory bus used by mem stage
			MEM_busacccess_in : IN STD_LOGIC;

			--Bypass inputs used for hazard detection (Forwarding)
			bp_MEM_reg_write	: IN STD_LOGIC;
			bp_MEM_reg_data 	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			bp_MEM_dest_reg 	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			bp_EX_reg_write	: IN STD_LOGIC;
			bp_EX_reg_data 	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			bp_EX_dest_reg 	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);

			--Control inputs
			ControlID_in	: IN ID_CTRL_SIGS;
			ControlEX_in	: IN EX_CTRL_SIGS;
			ControlMEM_in 	: IN MEM_CTRL_SIGS;
			ControlWB_in 	: IN WB_CTRL_SIGS;
			
			done_program : in STD_LOGIC;

			--Branch outputs
			ID_stall_IF	: OUT STD_LOGIC;
			ID_br_zero	: OUT STD_LOGIC;
			ID_br_addr 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

			ControlEX_out	: OUT EX_CTRL_SIGS;
			ControlMEM_out	: OUT MEM_CTRL_SIGS;
			ControlWB_out 	: OUT WB_CTRL_SIGS;
			ID_rs	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_rt : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_IMM : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_shamt: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			ID_dest_reg : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			PC_out 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
			
		);
	END COMPONENT;

  -- All the intermediate signals that come from the instruction decode stage
	SIGNAL ID_rs			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ID_rt  			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ID_IMM			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ID_shamt		: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL ID_dest_reg	: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL PC_out 			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ID_stall_IF	: STD_LOGIC;
	SIGNAL ID_br_zero 	: STD_LOGIC;
	SIGNAL ID_br_addr 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ControlEX_out	: EX_CTRL_SIGS;
	SIGNAL ControlMEM_out	: MEM_CTRL_SIGS;
	SIGNAL ControlWB_out  : WB_CTRL_SIGS;


  --Port map for the execution stage
	COMPONENT EX_STAGE IS
		PORT (
			 --STAGE INPUTS
			 --operation related signals
			 clk		: in std_logic;
			 rdy		: in std_logic;
			 reset	: in std_logic;

			 --Register file related data
			 EX_data_from_RS	: in std_logic_vector (31 downto 0);
			 EX_data_from_RT	: in std_logic_vector (31 downto 0);
			 EX_shift_amount	: in std_logic_vector (4 downto 0);

			 EX_program_counter		: in std_logic_vector (31 downto 0);
			 EX_sign_extended_IMM	: in std_logic_vector (31 downto 0);
			 EX_destination_reg_RD	: in std_logic_vector (4 downto 0);

			 --Control signals to current stage:
			 EX_STAGE_CONTROL_SIGNALS	: in EX_CTRL_SIGS;
			 --Control signals to be passed to further stages:
			 MEM_STAGE_CONTROL_SIGNALS	: in MEM_CTRL_SIGS;
			 WB_STAGE_CONTROL_SIGNALS	: in WB_CTRL_SIGS;

			 --STAGE OUTPUTS
			 EX_ALU_result_out		: out std_logic_vector (31 downto 0);
			 EX_write_data_out		: out std_logic_vector (31 downto 0);
			 EX_destination_reg_RD_out : out std_logic_vector (4 downto 0);
			 --Control signals to be passed to further stages:
			 MEM_STAGE_CONTROL_SIGNALS_out	: out MEM_CTRL_SIGS;
			 WB_STAGE_CONTROL_SIGNALS_out		: out WB_CTRL_SIGS;

			--Data bypassing to ID --TODO HI LO bypassing
			bp_EX_reg_write	: OUT STD_LOGIC;
			bp_EX_reg_data 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			bp_EX_dest_reg 	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
		);
	END COMPONENT;

  --Oiutput signals of EX stage
  SIGNAL EX_ctrl_WB : WB_CTRL_SIGS;
  SIGNAL EX_ctrl_MEM : MEM_CTRL_SIGS;
  SIGNAL EX_ALU : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL EX_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL EX_dest_reg : STD_LOGIC_VECTOR (4 DOWNTO 0);
	--TODO
	SIGNAL bp_EX_reg_write : STD_LOGIC;
	SIGNAL bp_EX_reg_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL bp_EX_dest_reg : STD_LOGIC_VECTOR (4 DOWNTO 0);

	COMPONENT MEM_STAGE IS
		PORT (
			  --STAGE INPUTS
			 --operation related signals
			 clk: in std_logic;
			 rdy: in std_logic;
			 reset: in std_logic;

				--Data related inputs
			 ALU_output_from_EX: in std_logic_vector(31 downto 0);    --> The ALU output to forward to WB, or computed address for lw and sw
			 data_to_write_from_EX: in std_logic_vector(31 downto 0); --> Whatever we want to write from the register RT
			 destination_reg_RD: in std_logic_vector (4 downto 0);

			 --MEM stage control signals coming passed from EX stage. To be consumed here.
			 --WB stage signals coming passed from EX stage. To be passed further to WB stage.
			 MEM_STAGE_CONTROL_SIGNALS: in MEM_CTRL_SIGS;
			 WB_STAGE_CONTROL_SIGNALS: in WB_CTRL_SIGS;

			  --STAGE OUTPUTS
			 --Data read from memory/ALU
			 data_out_to_WB: out std_logic_vector(31 downto 0);  --> Either memory data or alu result
			 MEM_destination_reg_RD_out: out std_logic_vector (4 downto 0);

			 --To be passed to WB stage
			 MEM_WB_STAGE_CONTROL_SIGNALS_out: out WB_CTRL_SIGS;

			 --Data bypassing to ID --TODO HI LO bypassing
			 bp_MEM_reg_write	: OUT STD_LOGIC;
			 bp_MEM_reg_data 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			 bp_MEM_dest_reg 	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			 
			 	
			 --Interface sinals to and from driver that comminucates with the main memory 
			 data_read_from_memory : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			 waitrequest_from_memory: IN STD_LOGIC;
			 
			 data_to_write_to_memory : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			 address_for_memory : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			 do_mem_write	: OUT STD_LOGIC;
			 do_mem_read	: OUT STD_LOGIC
	 
		);
	END COMPONENT;

  --Output signals of the MEM stage
	SIGNAL MEM_WB_control_signals : WB_CTRL_SIGS;
	SIGNAL MEM_data_out_to_WB : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL MEM_destination_reg_RD_out  : STD_LOGIC_VECTOR (4 DOWNTO 0);

	SIGNAL bp_MEM_reg_write : STD_LOGIC;
	SIGNAL bp_MEM_reg_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL bp_MEM_dest_reg : STD_LOGIC_VECTOR (4 DOWNTO 0);

-- Architecture begin, map every stage signal
BEGIN
	
	--mem_address <= TO_INTEGER (UNSIGNED(mem_bus_addr));
	ready <= '1'; -->
	init <= '0';

  --Port mapping all the control signals
	control_unit_map : CPU_control_unit
		PORT MAP (
			instruction => IF_instruction, --GETS FROM instruction fetch
			IF_SIGS => IF_control_signals,
			ID_SIGS => ID_control_signals,
			EX_SIGS => EX_control_signals,
			MEM_SIGS => MEM_control_signals,
			WB_SIGS => WB_control_signals
		);

  --Port mapping instruction fetch.
  --Gets inputs from control and branch signals and outputs the instruction to be decoded
	IF_map : Instruction_Fetch
		PORT MAP (
  			Clock => clk,
  			Reset => rst,
  			init => init,
  			Ready => ready,
  			IF_Control => IF_control_signals,
  			IF_Stall => ID_stall_IF,
  			ID_Branch_Zero => ID_br_zero,
  			ID_Branch_Address => ID_br_addr,
  			Input_From_Instruction_Memory => instr_mem_data,  --NOTE: Wired to input of the driver, driver talks to instruction memory to get the actual instruction
  			IF_PC => IF_PC,        --NOTE: Wired to output of the driver, driver talks to instruction memory to provide the address for instruction
  			IF_Instruction => IF_instruction, --GETS FROM instruction memory
  			Branch_Taken => branch_taken
    	);

  --Instruction decode map.
  --Gets inputs from the instruction decode
	ID_map : instruction_decode
		PORT MAP (
			clock => clk,
			rst => rst,
			rd_ready => waitrequest_from_memory,
			wr_done => waitrequest_from_memory,
			branch_taken => branch_taken,
			WB_ctrl => MEM_WB_control_signals,
			WB_data => MEM_data_out_to_WB,
			WB_addr => MEM_destination_reg_RD_out,
			PC_in => IF_PC,
			instruction_in => IF_instruction,

			bp_MEM_reg_write => bp_MEM_reg_write,
			bp_MEM_reg_data => bp_MEM_reg_data,
			bp_MEM_dest_reg => bp_MEM_dest_reg,
			bp_EX_reg_write => bp_EX_reg_write,
			bp_EX_reg_data => bp_EX_reg_data,
			bp_EX_dest_reg => bp_EX_dest_reg,

			ControlID_in => ID_control_signals,
			ControlEX_in => EX_control_signals,
			ControlMEM_in => MEM_control_signals,
			ControlWB_in => WB_control_signals,
			
			done_program => done_program_in,

			MEM_busacccess_in => EX_ctrl_MEM.memory_bus,

			ID_stall_IF	=> ID_stall_IF,
			ID_br_zero => ID_br_zero,
			ID_br_addr => ID_br_addr,
			ControlEX_out => ControlEX_out,
			ControlMEM_out	=> ControlMEM_out,
			ControlWB_out => ControlWB_out,
			ID_rs => ID_rs,
			ID_rt => ID_rt,
			ID_IMM => ID_IMM,
			ID_shamt =>	ID_shamt,
			ID_dest_reg => ID_dest_reg,
			PC_out => PC_out
		);

	EX_map : EX_STAGE
		PORT MAP (
			clk => clk,
			reset => rst,
			rdy => ready,

			EX_STAGE_CONTROL_SIGNALS => ControlEX_out,
			MEM_STAGE_CONTROL_SIGNALS => ControlMEM_out,
			WB_STAGE_CONTROL_SIGNALS => ControlWB_out,

			EX_data_from_RS => ID_rs,
			EX_data_from_RT => ID_rt,
			EX_sign_extended_IMM => ID_IMM,
			EX_shift_amount => ID_shamt,
			EX_destination_reg_RD => ID_dest_reg,
			EX_program_counter => PC_out,

			MEM_STAGE_CONTROL_SIGNALS_out => EX_ctrl_MEM,
			WB_STAGE_CONTROL_SIGNALS_out => EX_ctrl_WB,
			EX_ALU_result_out => EX_ALU,
			EX_write_data_out => EX_data,
			EX_destination_reg_RD_out => EX_dest_reg,

			bp_EX_reg_write => bp_EX_reg_write,
			bp_EX_reg_data => bp_EX_reg_data,
			bp_EX_dest_reg => bp_EX_dest_reg
		);

	MEM_map : MEM_STAGE
		PORT MAP (
			clk => clk,
			reset => rst,
			rdy => ready,

			WB_STAGE_CONTROL_SIGNALS => EX_ctrl_WB,
			MEM_STAGE_CONTROL_SIGNALS => EX_ctrl_MEM,
			ALU_output_from_EX => EX_ALU,
			data_to_write_from_EX => EX_data,
			destination_reg_RD => EX_dest_reg,


			MEM_WB_STAGE_CONTROL_SIGNALS_out	=> MEM_WB_control_signals,
			data_out_to_WB	=> MEM_data_out_to_WB,
			MEM_destination_reg_RD_out => MEM_destination_reg_RD_out,

			bp_MEM_reg_write => bp_MEM_reg_write,
			bp_MEM_reg_data => bp_MEM_reg_data,
			bp_MEM_dest_reg => bp_MEM_dest_reg,
			
			data_read_from_memory =>data_read_from_memory,
			waitrequest_from_memory => waitrequest_from_memory,
			 
			data_to_write_to_memory => data_to_write_to_memory_sig,
			address_for_memory => address_for_memory_sig,
			do_mem_write => do_mem_write_sig,
			do_mem_read	=> do_mem_read_sig
		);

	Handle_reset: Process(clk, rst)
		begin
			if rising_edge(rst) then
				instr_mem_address <=  "00000000000000000000000000000000";
				data_to_write_to_memory <=  "00000000000000000000000000000000";
				address_for_memory <=  "00000000000000000000000000000000";
				do_mem_write	<= '0';
				do_mem_read	<= '0';
			elsif rst = '0' then
				instr_mem_address <= IF_PC;
				--instr_mem_address <= x"00000000";
				data_to_write_to_memory <= data_to_write_to_memory_sig;
				address_for_memory <= address_for_memory_sig;
				do_mem_write <= do_mem_write_sig;
				do_mem_read <= do_mem_read_sig;
		   end if;
		end process;
END arch;
