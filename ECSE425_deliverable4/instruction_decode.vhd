--ID stage

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.my_types.all;

ENTITY instruction_decode IS
	PORT (
		clock 			: IN	STD_LOGIC;
		rst				: IN	STD_LOGIC;
		branch_taken	: IN 	STD_LOGIC; --Input from IF to know if the branch was taken
		
		--Write back inputs
		WB_ctrl	: IN CTRL_WB_TYPE; --Signals coming from MEM to WB
		WB_data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		WB_addr 	: IN STD_LOGIC_VECTOR (4 DOWNTO 0); --Destination register
		
		PC_in		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		instruction_in	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		
		--Control inputs
		ControlID_in	: IN ID_CTRL_SIGS;
		ControlEX_in	: IN EX_CTRL_SIGS;
		ControlMEM_in : IN MEM_CTRL_SIGS;
		ControlWB_in 	: IN WB_CTRL_SIGS;  
		
		--Branch outputs
		ID_stall_IF	: OUT STD_LOGIC;
		ID_br_zero	: OUT STD_LOGIC;
		ID_br_addr 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		
		ControlID_out	: OUT EX_CTRL_SIGS;
		ControlWB_out 	: OUT WB_CTRL_SIGS;
		ID_rs				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		ID_rt 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		ID_IMM 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		ID_shamt			: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		ID_dest_reg 	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		PC_out 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE arch OF instruction_decode IS

	COMPONENT registers IS
		PORT (
			clock				:	IN  STD_LOGIC;
			rst				:	IN  STD_LOGIC;
			reg_addr_1		:	IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_addr_2		: 	IN	 STD_LOGIC_VECTOR (4 DOWNTO 0);
			write_reg		: 	IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
			write_data		:	IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			wite_enable		:  IN  STD_LOGIC;
			read_data_1		:	OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			read_data_2		:	OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;
	
	--Instruction aliases
	ALIAS opcode : STD_LOGIC_VECTOR (5 DOWNTO 0) IS instruction_in (31 DOWNTO 26);
	ALIAS rs : STD_LOGIC_VECTOR (4 DOWNTO 0) IS instruction_in (25 DOWNTO 21);
	ALIAS rt : STD_LOGIC_VECTOR (4 DOWNTO 0) IS instruction_in (20 DOWNTO 16);
	ALIAS rd : STD_LOGIC_VECTOR (4 DOWNTO 0) IS instruction_in (15 DOWNTO 11);
	ALIAS shamt : STD_LOGIC_VECTOR (4 DOWNTO 0) IS instruction_in (10 DOWNTO 6);
	ALIAS funct : STD_LOGIC_VECTOR (5 DOWNTO 0) IS instruction_in (5 DOWNTO 0);
	
	-- Register file
	SIGNAL rs_reg_1 : STD_LOGIC_VECTOR (31 DOWNTO 0); --data read from rs
	SIGNAL rt_reg_2 : STD_LOGIC_VECTOR (31 DOWNTO 0); --data read from rt
	
	-- Zero/sign extended immediate
	SIGNAL imm_extended : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	-- Destination reg
	SIGNAL destination_reg : STD_LOGIC_VECTOR (4 DOWNTO 0);
	
	SIGNAL rs_value : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL rt_value : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	-- Branch logic
	signal br_j_addr : STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal br_br_addr : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL stall : STD_LOGIC;
		
BEGIN

	-- Register file
	registers_1 : registers 
		PORT MAP (
			clock => clock,
			rst => rst,
			read_reg_1 => rs,
			read_reg_2 => rt,
			write_reg => WB_addr,
			write_data => WB_data,
			write_en => WB_ctrl.reg_write,
			read_data_1 => rs_reg_1,
			read_data_2 => rt_reg_2
		);
	
	-- Zero extend if ControlID_in.zero_extend is asserted, otherwise sign extend
	imm_extended(15 DOWNTO 0) <= instruction_in(15 DOWNTO 0) ;
	imm_extended(31 DOWNTO 16) <= (OTHERS => (instruction_in(15) AND NOT(ControlID_in.zero_extend)));
	
	--Choose destination register			
	destination_reg <= "11111" WHEN ControlEX_in.jump_link = '1' ELSE --If jal instruction, use reg $31
					rd		  WHEN ControlEX_in.select_imm = '0' ELSE --Choose rd or rt depending on R or I type
					rt;
	
	--Logic for branches and jumps
	br_br_addr <= STD_LOGIC_VECTOR ((SIGNED(imm_extended) SLL 2) + SIGNED(PC_in)); --PC here already +4
	
	ID_br_zero <= '1' WHEN rs_value = rt_value ELSE
					  '0';
				 
	--Jump address MUX
	br_j_addr <= rs_value WHEN ControlID_in.jr = '1' ELSE
					 PC_in(31 DOWNTO 28) & STD_LOGIC_VECTOR (shift_left(UNSIGNED(instruction_in(27 DOWNTO 0)), 2));
					
	--Jump or branch address
	ID_br_addr <= br_br_addr WHEN ControlID_in.branch = '1' ELSE
					  br_j_addr;
	
	
	pipeline : PROCESS (clock, rst)
	BEGIN
		IF rst = '1' THEN
			ControlID_out <= ('0', '0', '0', '0', add_op, mult_op, '0', '0', '0');
			ControlWB_out <= (OTHERS => '0');
			ID_rs <= (OTHERS => '0');
			ID_rt <= (OTHERS => '0');
			ID_IMM <= (OTHERS => '0');
			ID_dest_reg <= (OTHERS => '0');
			PC_out <= (OTHERS => '0');
			
		ELSIF rising_edge(clock) THEN
			--flush instruction after branch
			IF stall = '0' AND branch_taken = '1' THEN 
				--Insert NOP
				ControlID_out <= ('0', '0', '0', '0', add_op, mult_op, '0', '0', '0');
				ControlWB_out <= (OTHERS => '0');
				
			--pass instruction to next stage
			ELSIF stall = '0' THEN 
				ControlID_out <= ControlEX_in;
				ControlWB_out <= ControlWB_in;
				ID_rs <= rs_value;
				ID_rt <= rt_value;
				ID_IMM <= imm_extended;
				ID_shamt <= shamt;
				ID_dest_reg <= destination_reg;
				PC_out <= PC_in;
			END IF;
		END IF;
	END PROCESS;

END arch;