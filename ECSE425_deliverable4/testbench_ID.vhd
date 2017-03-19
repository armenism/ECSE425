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
	SIGNAL ControlEX_in	: EX_CTRL_SIGS := ('0', '0', alu_addi, mult, '0', '0', '0', '0');
	SIGNAL ControlMEM_in : MEM_CTRL_SIGS := ('0', '0', '0');
	SIGNAL ControlWB_in 	: WB_CTRL_SIGS := ('0', '0');  
	
	--Branch outputs
	SIGNAL ID_stall_IF	: STD_LOGIC;
	SIGNAL ID_br_zero	: STD_LOGIC;
	SIGNAL ID_br_addr 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL ControlEX_out		: EX_CTRL_SIGS;
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
	
	Signal stall : std_logic:= '0';
	signal rs_value : STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal rt_value : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	-- Destination register
	SIGNAL destination_reg : STD_LOGIC_VECTOR (4 DOWNTO 0);
	
	--Zero extend and sign extend immediate
	SIGNAL imm_extend : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	-- Branch logic
	signal j_addr 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal br_addr : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	-- ID to ID bypass signals
	signal bp_ID_ctrl_MEM : MEM_CTRL_SIGS;
	signal bp_ID_rt 		 : STD_LOGIC_VECTOR (4 DOWNTO 0);
	
	-- Bypass 
	signal bp_rs_MEM	: STD_LOGIC;
	signal bp_rt_MEM	: STD_LOGIC;
	signal bp_rs_EX	: STD_LOGIC;
	signal bp_rt_EX	: STD_LOGIC;
	
	-- Hazard detection 
	signal insert_nop : STD_LOGIC; --No operation
	signal hazard_stall 	: STD_LOGIC;
	
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
	 
	 
	 
	 -- Zero extend if ControlID_in.zero_extend is asserted, otherwise sign extend
	imm_extend(15 DOWNTO 0) <= instruction_in(15 DOWNTO 0) ;
	imm_extend(31 DOWNTO 16) <= (OTHERS => (instruction_in(15) AND NOT(ControlID_in.zero_extend)));
	
	--Choose destination register			
	destination_reg <= "11111" WHEN ControlEX_in.jump_and_link = '1' ELSE --If jal instruction, use reg $31
					rd		  WHEN ControlEX_in.use_imm = '0' ELSE --Choose rd or rt depending on R or I type
					rt;
	
--Logic for branches and jumps
	br_addr <= STD_LOGIC_VECTOR ((SIGNED(imm_extend) SLL 2) + SIGNED(PC_in)); --PC here already +4
	
	ID_br_zero <= '1' WHEN rs_value = rt_value ELSE
					  '0';
				 
	--MUX for jump address
	j_addr <= rs_value WHEN ControlID_in.jr = '1' ELSE
					 PC_in(31 DOWNTO 28) & STD_LOGIC_VECTOR (shift_left(UNSIGNED(instruction_in(27 DOWNTO 0)), 2));
					
	--Either jump or branch to address
	ID_br_addr <= br_addr WHEN ControlID_in.branch = '1' ELSE
					  j_addr;
	
	-- Determine if rs is bypassed from EX or MEM
	rs_value <= bp_EX_reg_data  WHEN bp_rs_EX = '1' ELSE
					bp_MEM_reg_data WHEN bp_rs_MEM = '1' ELSE
					rs_reg_1;
					
	-- Determine if rt is bypassed from EX or MEM	
	rt_value <= bp_EX_reg_data  WHEN bp_rt_EX = '1' ELSE
					bp_MEM_reg_data WHEN bp_rt_MEM = '1' ELSE
					rt_reg_2;


					
-- Forwarding evaluation
	-- Check if bypassing rs from MEM
	bp_rs_MEM <= '1' WHEN ( bp_MEM_reg_write = '1' AND
								   bp_MEM_dest_reg /= "00000" and
									bp_MEM_dest_reg = rs ) ELSE
					 '0';
			
	-- Check if bypassing rs from EX
	bp_rs_EX <= '1' WHEN ( bp_EX_reg_write = '1' AND
								  bp_EX_dest_reg /= "00000" and
								  bp_EX_dest_reg = rs ) ELSE
					'0';
				  
	-- Check if bypassing rt from MEM
	bp_rt_MEM <= '1' WHEN ( bp_MEM_reg_write = '1' AND
								   bp_MEM_dest_reg /= "00000" and
									bp_MEM_dest_reg = rt ) ELSE
					 '0';
			
	-- Check if bypassing rt from EX
	bp_rt_EX <= '1' WHEN ( bp_EX_reg_write = '1' AND
								  bp_EX_dest_reg /= "00000" and
								  bp_EX_dest_reg = rt ) ELSE
					'0';
	

-- Hazard detection
	-- Stall. If the previous intruction was load: 
	-- put a no operation the registers that will be used by the current instruction
	-- instruction
	insert_nop <= '1' WHEN (bp_ID_ctrl_MEM.read_from_memory = '1' AND
							((bp_ID_rt = rs) or bp_ID_rt = rt))
							OR (wr_done = '1') else
				 '0';
	hazard_stall <= insert_nop OR mem_busacccess_in;
	ID_stall_IF <= hazard_stall;
	stall <= hazard_stall OR ((NOT rd_ready) AND (NOT wr_done));
	
	
	pipeline : PROCESS (clock, rst)
	BEGIN
		IF rst = '1' THEN
			ControlEX_out <= ('0', '0', alu_addi, mult, '0', '0', '0', '0');
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
				ControlEX_out <= ('0', '0', alu_addi, mult, '0', '0', '0', '0');
				ControlWB_out <= (OTHERS => '0');
				
			--pass instruction to next stage
			ELSIF stall = '0' THEN 
				ControlEX_out <= ControlEX_in;
				ControlWB_out <= ControlWB_in;
				ID_rs <= rs_value;
				ID_rt <= rt_value;
				ID_IMM <= imm_extend;
				ID_shamt <= shamt;
				ID_dest_reg <= destination_reg;
				PC_out <= PC_in;
			END IF;
		END IF;
	END PROCESS;
	 

   test_process : PROCESS
   BEGIN
		
		rst <= '1';
		
		wait for clk_period;
		
		rst <= '0';
		
		wait for clk_period;
		
		branch_taken <= '1';
		
		wait for clk_period;
		
		branch_taken <= '0';
		
		
    	--wait until is useful to simulate FSM behaviour.
    	--this is NOT synthesizable and should not be used in a hardware design
	
		--assert  = "01101110110110111011011011101101101110110110111011011011101101101101" report "write unsuccessful" severity error;
	
        wait;

    END PROCESS;

 
END arch;
