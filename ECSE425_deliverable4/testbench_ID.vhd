--Test bench for instruction_decode
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.signal_types.all;

--Empty entity for testbench
ENTITY testbench_ID IS
END testbench_ID;

ARCHITECTURE arch OF testbench_ID IS

--Declare component to test
	Component instruction_decode IS
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
			
			PC_in		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
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
			
			--Branch outputs
			ID_stall_IF	: OUT STD_LOGIC;
			ID_br_zero	: OUT STD_LOGIC;
			ID_br_addr 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			
			ControlEX_out	: OUT EX_CTRL_SIGS;
			ControlMEM_out	: OUT MEM_CTRL_SIGS;
			ControlWB_out 	: OUT WB_CTRL_SIGS;
			ID_rs				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_rt 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_IMM 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			ID_shamt			: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			ID_dest_reg 	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			PC_out 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END Component;
		
	COMPONENT registers
		PORT
		(
			clock				:	 IN STD_LOGIC;
			rst				:	 IN STD_LOGIC;
			reg_addr_1		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_addr_2		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			write_reg		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			write_data		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			write_enable	:	 IN STD_LOGIC;
			read_data_1		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			read_data_2		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	CONSTANT clk_period : time := 10 ns;
	
	--all the input signals with initial values
	
	SIGNAL clock : STD_LOGIC := '0';
	SIGNAL rst : STD_LOGIC := '0';
	SIGNAL rd_ready : STD_LOGIC := '0';
	SIGNAL wr_done : STD_LOGIC := '0';
	SIGNAL branch_taken : STD_LOGIC := '0';
	SIGNAL WB_ctrl : WB_CTRL_SIGS;
	SIGNAL WB_data	: STD_LOGIC_VECTOR (31 DOWNTO 0) := "00110011001100110011001100110011";
	SIGNAL WB_addr 	: STD_LOGIC_VECTOR (4 DOWNTO 0) := (OTHERS => 'Z'); --Destination register
	
	SIGNAL PC_in		: STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL instruction_in	: STD_LOGIC_VECTOR (31 DOWNTO 0) := "10000000111100001111000011110000";
	
	--memory bus used by mem stage
	SIGNAL MEM_busacccess_in : STD_LOGIC := '0'; 
	
	--Bypass inputs used for hazard detection (Forwarding)
	SIGNAL bp_MEM_reg_write	: STD_LOGIC := '0';
	SIGNAL bp_MEM_reg_data 	: STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => 'Z');
	SIGNAL bp_MEM_dest_reg 	: STD_LOGIC_VECTOR (4 DOWNTO 0) := (OTHERS => 'Z');
	SIGNAL bp_EX_reg_write	: STD_LOGIC := '0';
	SIGNAL bp_EX_reg_data 	: STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => 'Z');
	SIGNAL bp_EX_dest_reg 	: STD_LOGIC_VECTOR (4 DOWNTO 0) := (OTHERS => 'Z');
	
	--Control inputs
	SIGNAL ControlID_in	: ID_CTRL_SIGS := ('0', '0', '0');
	SIGNAL ControlEX_in	: EX_CTRL_SIGS := ('0', '0', alu_addi, '0', '0', '0');
	SIGNAL ControlMEM_in : MEM_CTRL_SIGS := ('0', '0');
	SIGNAL ControlWB_in 	: WB_CTRL_SIGS := to_stdulogic(0);  
	
	--Branch outputs
	SIGNAL ID_stall_IF	: STD_LOGIC;
	SIGNAL ID_br_zero	: STD_LOGIC;
	SIGNAL ID_br_addr 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL ControlEX_out	: EX_CTRL_SIGS;
	SIGNAL ControlMEM_out	: MEM_CTRL_SIGS;
	SIGNAL ControlWB_out 	: WB_CTRL_SIGS;
	SIGNAL ID_rs				: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ID_rt 			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ID_IMM 			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ID_shamt			: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL ID_dest_reg 	: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL PC_out 			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL rs_reg_1 : std_logic_vector (31 downto 0);
	SIGNAL rt_reg_2 : std_logic_vector (31 downto 0);
	
			--Instruction aliases
	ALIAS opcode 	: STD_LOGIC_VECTOR (5 DOWNTO 0) IS instruction_in (31 DOWNTO 26);
	ALIAS rs 		: STD_LOGIC_VECTOR (4 DOWNTO 0) IS instruction_in (25 DOWNTO 21);
	ALIAS rt			: STD_LOGIC_VECTOR (4 DOWNTO 0) IS instruction_in (20 DOWNTO 16);
	ALIAS rd 		: STD_LOGIC_VECTOR (4 DOWNTO 0) IS instruction_in (15 DOWNTO 11);
	ALIAS shamt 	: STD_LOGIC_VECTOR (4 DOWNTO 0) IS instruction_in (10 DOWNTO 6);
	ALIAS funct 	: STD_LOGIC_VECTOR (5 DOWNTO 0) IS instruction_in (5 DOWNTO 0);


BEGIN
	
   uut: instruction_decode
	PORT MAP (
		clock => clock,
		rst	=> rst,
		rd_ready	=> rd_ready,
		wr_done	=> wr_done,
		branch_taken	=> branch_taken,
		
		--Write back inputs
		WB_ctrl	=> WB_ctrl,
		WB_data	=> WB_data,
		WB_addr  => WB_addr,
		
		PC_in		=> PC_in,
		instruction_in	=> instruction_in,
		
		--memory bus used by mem stage
		MEM_busacccess_in => MEM_busacccess_in,
		
		--Bypass inputs used for hazard detection (Forwarding)
		bp_MEM_reg_write => bp_MEM_reg_write,
		bp_MEM_reg_data => bp_MEM_reg_data,
		bp_MEM_dest_reg => bp_MEM_dest_reg,
		bp_EX_reg_write => bp_EX_reg_write,
		bp_EX_reg_data => bp_EX_reg_data,
		bp_EX_dest_reg => bp_EX_dest_reg,
		
		--Control inputs
		ControlID_in => ControlID_in,
		ControlEX_in => ControlEX_in,
		ControlMEM_in 	=> ControlMEM_in,
		ControlWB_in => ControlWB_in,
		
		--Branch outputs
		ID_stall_IF	=> ID_stall_IF,
		ID_br_zero	=> ID_br_zero,
		ID_br_addr => ID_br_addr,
		
		ControlEX_out	=> ControlEX_out,
		ControlMEM_out	=> ControlMEM_out,
		ControlWB_out 	=> ControlWB_out,
		ID_rs		=> ID_rs,
		ID_rt 	=> ID_rt,
		ID_IMM 	=> ID_IMM,
		ID_shamt	=> ID_shamt,
		ID_dest_reg => ID_dest_reg,
		PC_out 		=> PC_out
	);
		
	reg : registers
		PORT MAP (
			clock => clock,
			rst => rst,
			reg_addr_1 => rs,
			reg_addr_2 => rt,
			write_reg => WB_addr,
			write_data => WB_data,
			write_enable => '0',
			read_data_1 => rs_reg_1,
			read_data_2 => rt_reg_2
		);

    clk_process : PROCESS
    BEGIN
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
    END PROCESS;

    test_process : PROCESS
    BEGIN
		
		
    	--wait until is useful to simulate FSM behaviour.
    	--this is NOT synthesizable and should not be used in a hardware design
	
		--assert  = "01101110110110111011011011101101101110110110111011011011101101101101" report "write unsuccessful" severity error;
	
        wait;

    END PROCESS;

 
END arch;
