LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.Signal_Types.all;

ENTITY Instruction_Fetch_Prime IS
	PORT (				Clock									: IN	STD_LOGIC;
								Reset									: IN	STD_LOGIC;
								-- IF_Stall							: IN  STD_LOGIC; --stall from ID if needed
								read_Instruction			: IN STD_LOGIC_VECTOR (31 DOWNTO 0)
								IF_PC									: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --next address
								IF_Instruction				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END ENTITY;


ARCHITECTURE behavioural OF Instruction_Fetch_Prime IS

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
		IF (Clock'event AND Clock = '1') THEN
			IF Reset = '1' THEN
				PC <= x"00000000";
			ELSIF rising_edge(Clock) THEN
				IF Init = '1' THEN
					PC <= x"00000000";
				ELSIF Stall = '0' THEN
					PC <=  STD_LOGIC_VECTOR (UNSIGNED(PC) + x"00000001");
				END IF;
			END IF;
		END IF;
	END PROCESS;

	--Logic for new branch address.. gives PC+4 if no new branch
	IF_PC <= PC;


	-- Branch_Logic : PROCESS (Clock, Reset)
	-- BEGIN
	-- 	IF Reset = '1' THEN
	-- 		Temp_Branch_Taken <= '0';
	-- 	ELSIF rising_edge(Clock) AND Stall = '0' THEN
	--
	-- 		IF (((ID_Branch_Zero = '1' XOR IF_Control.bne = '1')
	-- 		AND IF_Control.branch = '1')
	-- 		OR IF_Control.jump = '1')
	-- 		AND Temp_Branch_Taken = '0' THEN
	-- 				Temp_Branch_Taken <= '1';
	-- 		ELSE Temp_Branch_Taken <= '0';
	--
	-- 		END IF;
	-- 	END IF;
	-- END PROCESS;

	-- Branch_Taken <= Temp_Branch_Taken;

	--process to move data from this stage to next stage
	Pipe : PROCESS (Clock, Reset)

	BEGIN
		IF (Clock'event AND Clock = '1') THEN
			IF Reset = '1' THEN
				IF_PC <= x"00000000";
				IF_Instruction <= x"00000000";
			ELSIF (read_Instruction'event) THEN
				Instruction <= read_Instruction;
			ELSE
				Instruction <= x"00000000";
			END IF;
		END IF;
	END PROCESS;

	--pass intsruction to output
	IF_Instruction <= Instruction;


	--BUS: check for stalls, reads and writes, set the bus to high-impedance if issue
	-- Stall <= IF_Stall OR (NOT Ready);
	-- Dont_Use <= IF_Stall OR Init;

	--Memory_Bus_Data <= (OTHERS => 'Z');

	-- Instruction <= Memory_Bus_Data;

END behavioural;
