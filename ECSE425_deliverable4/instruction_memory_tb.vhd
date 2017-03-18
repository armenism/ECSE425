LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all;

entity instruction_memory_tb is
end instruction_memory_tb;

architecture arch of instruction_memory_tb is

COMPONENT instruction_memory IS
	GENERIC(
		ram_size : INTEGER := 1024
	);
	PORT (
		clock: IN STD_LOGIC;
		writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address: IN INTEGER RANGE 0 TO ram_size-1; -- This is the PC
		memwrite: IN STD_LOGIC;
		memread: IN STD_LOGIC;
		readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		ready_to_use: OUT STD_LOGIC
	);
END COMPONENT;

    CONSTANT clk_period : time := 1 ns;
    CONSTANT ram_size : integer := 1024;
    SIGNAL clock : std_logic := '0';
    SIGNAL address: INTEGER RANGE 0 TO ram_size-1;
    SIGNAL memwrite: STD_LOGIC := '0';
    SIGNAL memread: STD_LOGIC := '0';
    SIGNAL readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL writedata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL done_writing: STD_LOGIC := '0';
		SIGNAL ready_to_use: STD_LOGIC := '0';

BEGIN

DUT:
    instruction_memory GENERIC MAP(
            ram_size => 1024
                )
                PORT MAP(
								clock,
								writedata,
								address,		--PC
								memwrite,
								memread,
								done_writing,
								ready_to_use,
								readdata
								);

test_process : process
	FILE ex_file: text;
  VARIABLE current_line: line;
	variable i : integer := 0;
	VARIABLE data_line: std_logic_vector(31 downto 0);

	BEGIN
		memwrite<='1';
		--open file: path specified in the second argument
		file_open (ex_file, "\\campus.mcgill.ca\emf\cpe\cdibet\My Documents\Ecse 425\Deliverable 4\output_files\program.txt", READ_MODE);
		--Read through 1024 lines of text file and save to memory
		while not endfile(ex_file) and i < 1024 loop
			clock <= '0';
			address<= std_logic_vector(to_unsigned(i,32));
			readline (ex_file, current_line);
			read (current_line, data_line);
			writedata <= data_line;
			WAIT FOR clk_period/2;
			clock <= '1';
			i := i + 1;
			WAIT FOR clk_period/2;
		END LOOP;

		memwrite <= '0';
		clock <= '0';
		done_writing <= '1';
		WAIT FOR clk_period/2;
		clock <= '1';
		--tell InstructionMEM writing is done

	END PROCESS;

end arch;
