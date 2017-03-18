LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.Signal_Types.all;

ENTITY Instruction_Fetch IS
	PORT (				IF_Control						: IN	IF_CTRL_SIGS; --control command
								Clock									: IN	STD_LOGIC;
								Reset									: IN	STD_LOGIC;
								Init									: IN 	STD_LOGIC;
								Ready									: IN	STD_LOGIC;
								Memory_Bus_Data				: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
								IF_Stall							: IN  STD_LOGIC; --stall from ID if needed
								ID_Branch_Zero				: IN 	STD_LOGIC;
								ID_Branch_Address			: IN	STD_LOGIC_VECTOR (31 DOWNTO 0);
								Branch_Taken					: OUT STD_LOGIC; --signal to ID to flush address
								IF_PC									: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --next address
								IF_Instruction				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
								
	);
END ENTITY;


ARCHITECTURE behavioural OF Instruction_Fetch IS

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
				IF_PC <= x"00000000";--PC_Plus;
				IF_Instruction <= Instruction;
			END IF;
		END IF;
	END PROCESS;


	--BUS: check for stalls, reads and writes, set the bus to high-impedance if issue
	Stall <= IF_Stall OR (NOT Ready);
	Dont_Use <= IF_Stall OR Init;

	Memory_Bus_Data <= (OTHERS => 'Z');

	Instruction <= Memory_Bus_Data;

END behavioural;
