LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.Signal_Types.all;

--Empty entity for testbench
ENTITY Testbench_Instruction_Fetch IS
END Testbench_Instruction_Fetch;

ARCHITECTURE behaviour OF Testbench_Instruction_Fetch IS

--Declare component to test
	COMPONENT Instruction_Fetch IS
		PORT (
			Clock			: IN	STD_LOGIC;
			Reset			: IN	STD_LOGIC;
			Init			: IN 	STD_LOGIC;
			Ready			: IN	STD_LOGIC;
			IF_Control						: IN	IF_CTRL_SIGS;
			IF_Stall		: IN  STD_LOGIC;
			ID_Branch_Zero	: IN 	STD_LOGIC; --branch request from ID
			ID_Branch_Address	: IN	STD_LOGIC_VECTOR (31 DOWNTO 0);
			Memory_Bus_Data: INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			Memory_Bus_Address: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			Memory_Bus_Read	: OUT STD_LOGIC;
			Memory_Bus_Write	: OUT	STD_LOGIC;
			Memory_Word: OUT STD_LOGIC;
			IF_PC			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --reg outputs
			IF_Instruction		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	CONSTANT Clock_Period : time := 10 ns;

	--all the input signals with initial values

	SIGNAL Clock : STD_LOGIC := '0';
	SIGNAL Reset : STD_LOGIC := '0';
	SIGNAL Init : STD_LOGIC := '0';
	SIGNAL Ready : STD_LOGIC := '0';
	SIGNAL IF_Control : IF_CTRL_SIGS := ('0', '0', '0');
	SIGNAL IF_Stall : STD_LOGIC := '0';
	SIGNAL ID_Branch_Zero	: STD_LOGIC := '0'; --branch request from ID
	SIGNAL ID_Branch_Address	: STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => 'Z');
	SIGNAL Memory_Bus_Data: STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => 'Z');
	SIGNAL Memory_Bus_Address: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL Memory_Bus_Read	: STD_LOGIC;
	SIGNAL Memory_Bus_Write	: STD_LOGIC;
	SIGNAL Memory_Word : STD_LOGIC;
	SIGNAL IF_PC		: STD_LOGIC_VECTOR (31 DOWNTO 0); --reg outputs
	SIGNAL IF_Instruction	: STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL Initialize : STD_LOGIC := '0';
	SIGNAL Dump : STD_LOGIC := '0';
	SIGNAL Write_Done : STD_LOGIC;
	SIGNAL Read_Ready : STD_LOGIC;

	SIGNAL Memory_Address : INTEGER;

	
	SIGNAL Stall : STD_LOGIC;
	SIGNAL Dont_Use : STD_LOGIC;
	SIGNAL Temp_Branch_Taken : STD_LOGIC;
	SIGNAL Next_PC	: STD_LOGIC_VECTOR (31 DOWNTO 0); --
	SIGNAL PC : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL PC_Plus : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL Instruction : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN

	Memory_Address <= TO_INTEGER (UNSIGNED(Memory_Bus_Address));
	Ready <= Read_Ready;

   --dut => Device Under Test
   dut: Instruction_Fetch
		PORT MAP (
			Clock => Clock,
			Reset => Reset,
			Init => Init,
			Ready => Ready,
			IF_Control => IF_Control,
			IF_Stall => IF_Stall,
			ID_Branch_Zero => ID_Branch_Zero,
			ID_Branch_Address => ID_Branch_Address,
			Memory_Bus_Data => Memory_Bus_Data,
			Memory_Bus_Address => Memory_Bus_Address,
			Memory_Bus_Read => Memory_Bus_Read,
			Memory_Bus_Write => Memory_Bus_Write,
			Memory_Word => Memory_Word,
			IF_PC => IF_PC,
			IF_Instruction => IF_Instruction
    	);

    Clock_Process : PROCESS
    BEGIN
        Clock <= '0';
        wait for Clock_Period/2;
        Clock <= '1';
        wait for Clock_Period/2;
    END PROCESS;

	 
	pc_test :	PROCESS (Clock, Reset)
	BEGIN
		IF Reset = '1' THEN
			PC <= x"00000000";
		ELSIF rising_edge(Clock) THEN
			IF Init = '1' THEN
				PC <= x"00000000";
			ELSIF Stall = '0' THEN
				PC <= Next_PC;
			END IF;
		END IF;
	END PROCESS;
	 
		--Logic for new branch address.. gives PC+4 if no new branch
	PC_Plus <= STD_LOGIC_VECTOR (UNSIGNED(PC) + x"00000004");
	Next_PC <= ID_Branch_Address WHEN (((ID_Branch_Zero = '1' XOR IF_Control.bne = '1')
																AND IF_Control.branch = '1')
																OR IF_Control.jump = '1')
																AND Temp_Branch_Taken = '0'
																ELSE PC_Plus;


	
    Test_Process : PROCESS
    BEGIN
		
		
		
		wait for Clock_Period;
		Reset <= '1';
		Init <= '1';


    END PROCESS;

	 
	 	--BUS: check for stalls, reads and writes, set the bus to high-impedance if issue
	Stall <= IF_Stall OR (NOT Ready);
	Dont_Use <= IF_Stall OR Init;

	Memory_Bus_Data <= (OTHERS => 'Z');

	Instruction <= Memory_Bus_Data;

	Memory_Bus_Address <= PC WHEN Dont_Use = '0' ELSE (OTHERS => 'Z');

	Memory_Bus_Read <= '1' WHEN Dont_Use = '0' ELSE 'Z';

	Memory_Bus_Write <= '0' WHEN Dont_Use = '0' ELSE 'Z';

	--make sure insturctions are in words
	Memory_Word <= '1' WHEN Dont_Use = '0' ELSE 'Z';

END;
