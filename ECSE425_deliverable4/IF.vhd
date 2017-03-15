LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.my_types.all;

ENTITY IF IS
	PORT (				IF_Control						: IN	IF_CTRL_SIGS; --control command
								Clock									: IN	STD_LOGIC;
								Reset									: IN	STD_LOGIC;
								Init									: IN 	STD_LOGIC;
								Ready									: IN	STD_LOGIC;
								IF_Stall							: IN  STD_LOGIC; --stall from ID if needed
								ID_Branch_Zero				: IN 	STD_LOGIC;
								Branch_Taken					: OUT STD_LOGIC --signal to ID to flush address
								ID_Branch_Address			: IN	STD_LOGIC_VECTOR (31 DOWNTO 0);
								IF_PC									: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --next address
								IF_Instruction				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
								Memory_Bus_Address		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
								Memory_Bus_Read				: OUT STD_LOGIC;
								Memory_Bus_Write			: OUT	STD_LOGIC;
								Memory_Word 					: OUT STD_LOGIC;
								Memory_Bus_Data				: INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	);
END ENTITY;


ARCHITECTURE behavioural OF IF IS

	--signals used for instruction fetch
	SIGNAL Stall : STD_LOGIC;
	SIGNAL Dont_Use : STD_LOGIC;
	SIGNAL Temp_Branch_Taken : STD_LOGIC;
	SIGNAL Next_PC	: STD_LOGIC_VECTOR (31 DOWNTO 0); --
	SIGNAL PC : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL PC_Plus : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL Instruction : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN

	--On reset go to 0x0, on initiate go to 0x0 otherwise go to next PC
	PROCESS (Clock, Reset)
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


	Branch_Logic : PROCESS (Clock, Reset)
	BEGIN
		IF Reset = '1' THEN
			Temp_Branch_Taken <= '0';
		ELSIF rising_edge(Clock) AND Stall = '0' THEN

			IF (((ID_Branch_Zero = '1' XOR IF_Control.bne = '1')
			AND IF_Control.branch = '1')
			OR IF_Control.jump = '1')
			AND Temp_Branch_Taken = '0'
			THEN Temp_Branch_Taken <= '1';
			ELSE Temp_Branch_Taken <= '0';

			END IF;
		END IF;
	END PROCESS;

	Branch_Taken <= Temp_Branch_Taken;

	--process to move data from this stage to next stage
	Pipe : PROCESS (Clock, Reset)

	BEGIN
		IF Reset = '1' THEN
			IF_PC <= x"00000000";
			IF_Instruction <= x"00000000";
		ELSIF rising_edge(Clock) THEN
			IF Init = '1' THEN
				IF_PC <= x"00000000";
				IF_Instruction <= x"00000000";
			ELSIF Stall = '0' THEN
				IF_PC <= PC_Plus;
				IF_Instruction <= Instruction;
			END IF;
		END IF;
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

END behavioural;
