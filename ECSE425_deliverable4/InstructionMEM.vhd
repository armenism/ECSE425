--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY InstructionMEM IS
	GENERIC(
		ram_size : INTEGER := 1024;
		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
	);
	PORT (
		clock: IN STD_LOGIC;
		writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address: IN INTEGER RANGE 0 TO ram_size-1; -- This is the PC
		memwrite: IN STD_LOGIC;
		memread: IN STD_LOGIC;
		done_writing: IN STD_LOGIC;
		ready_to_use: OUT STD_LOGIC;
		readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
END InstructionMEM;

ARCHITECTURE rtl OF InstructionMEM IS
	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block: MEM;
	SIGNAL data_to_be_read: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_address_reg: INTEGER RANGE 0 to ram_size-1;
	SIGNAL ready_signal: std_logic := '0';
BEGIN
	--This is the main section of the SRAM model
	mem_process: PROCESS (clock)
	BEGIN
		--This is a cheap trick to initialize the SRAM in simulation
		IF(now < 1 ps)THEN
			For i in 0 to ram_size-1 LOOP
				ram_block(i) <= std_logic_vector(to_unsigned(i,32));
			END LOOP;
		end if;

		--This is the actual synthesizable SRAM block
		IF (clock'event AND clock = '1') THEN
			IF (memwrite = '1') THEN
				ram_block(address) <= writedata;
			END IF;
			IF (memread = '1' AND done_writing = '1') THEN
				data_to_be_read <= ram_block(address);
			END IF;
		END IF;
	END PROCESS;
	readdata <= data_to_be_read;


	issue_done_writing: PROCESS (done_writing)
	BEGIN
		IF(done_writing'event AND done_writing = '1')THEN
			ready_signal <= '1';
		END IF;
	END PROCESS;
	ready_to_use <= ready_signal;


END rtl;
