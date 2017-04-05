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
								Input_From_Instruction_Memory	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
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
	SIGNAL PC : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL Instruction : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN
																
	--process to move data from this stage to next stage
	Pipe : PROCESS (Input_From_Instruction_Memory, Reset,ID_Branch_Address)

	BEGIN
		IF Reset = '1' THEN
			PC <= x"00000000";
			Instruction <= x"00000000";
			Temp_Branch_Taken <= '0';
		
		ELSIF Input_From_Instruction_Memory'event THEN
			IF Input_From_Instruction_Memory /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" THEN
				Instruction <= Input_From_Instruction_Memory;
				
				-- IF branch or jump signals are valid, then actually jump. The PC
				--becomes the branch address calculated by ID
				--WORKS! Needs flushing/stalling
				IF (((ID_Branch_Zero = '1' XOR IF_Control.bne = '1')
															AND IF_Control.branch = '1')
															OR IF_Control.jump = '1')
															AND Temp_Branch_Taken = '0' THEN
								Temp_Branch_Taken <= '1';								
								PC <= ID_Branch_Address;
				ELSE
					PC <= STD_LOGIC_VECTOR (UNSIGNED(PC) + x"00000001");
					Temp_Branch_Taken <= '0';
				END IF;
			END IF;
		END IF;
		
	END PROCESS;
	
	Branch_Taken <= Temp_Branch_Taken;
	IF_PC <= PC;
	--BUS: check for stalls, reads and writes, set the bus to high-impedance if issue
	Stall <= '0'; --IF_Stall OR (NOT Ready); 
	Dont_Use <= IF_Stall OR Init;

	--Input_From_Instruction_Memory <= (OTHERS => 'Z');

	IF_Instruction <= Instruction;

END behavioural;
