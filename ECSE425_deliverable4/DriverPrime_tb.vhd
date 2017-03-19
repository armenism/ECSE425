LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all;

entity DriverPrime_tb is
end DriverPrime_tb;

architecture arch of DriverPrime_tb is

COMPONENT InstructionMEM IS
	GENERIC(
		ram_size : INTEGER := 1024
	);
	PORT (
		clock: IN STD_LOGIC;
		writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address: IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- This is the PC
		memwrite: IN STD_LOGIC;
		memread: IN STD_LOGIC;
		done_writing: IN STD_LOGIC;
		ready_to_use: OUT STD_LOGIC;
		readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT DriverPrime IS
  PORT (
		clk				:	IN  STD_LOGIC;
		rst				: IN  STD_LOGIC;
      ready_to_use :    IN STD_LOGIC;
      instr_mem_read  : IN STD_LOGIC_VECTOR (31 DOWNTO 0);    --what we get from instruction memory after requesting the address
		PC	            :	OUT STD_LOGIC_VECTOR (31 DOWNTO 0) --mem address destined for instruction memory component (PC in 32 bit now)

    -- data_mem_address: OUT INTEGER;                          --mem address destineed for data memory component
    -- data_mem_data  : in STD_LOGIC_VECTOR (31 DOWNTO 0);     --what we want to write to main memory component
    -- data_mem_data_out  : out STD_LOGIC_VECTOR (31 DOWNTO 0); --what we want to read from main memory component

    -- mem_wr_done		:	IN	 STD_LOGIC;
    -- mem_rd_ready	:	IN	 STD_LOGIC
	);
END COMPONENT;

    CONSTANT clk_period : time := 1 ns;
    CONSTANT ram_size : integer := 1024;
    SIGNAL clock : std_logic := '0';
    SIGNAL reset : std_logic := '0';

    --Instruction memory signals
    SIGNAL PC: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL memwrite: STD_LOGIC := '0';
    SIGNAL memread: STD_LOGIC := '0';
    SIGNAL readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL writedata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL done_writing: STD_LOGIC := '0';
    SIGNAL mem_ready_to_use: STD_LOGIC := '0';

    --Main memory signals
    SIGNAL datamem_address: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL data_mem_data_in:  STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL data_mem_data_out: STD_LOGIC_VECTOR (31 DOWNTO 0);

    SIGNAL data_mem_write_done: STD_LOGIC := '0';
    SIGNAL data_mem_read_done: STD_LOGIC := '0';

BEGIN

Instruction_Memory:
    InstructionMEM GENERIC MAP(
            ram_size => 1024
                )
                PORT MAP
					 (
							clock,
							writedata,
							PC,		--PC
							memwrite,
							memread,
							done_writing,
							mem_ready_to_use,
							readdata
					 );

Main_Driver:
	DriverPrime PORT MAP(
			 clk => clock,
			 rst => reset,
			 ready_to_use => mem_ready_to_use,
			 instr_mem_read => readdata,
			 PC => PC
	);



test_process : process (clock, mem_ready_to_use)

	FILE ex_file: text;
  VARIABLE current_line: line;
	variable i : integer := 0;
	VARIABLE data_line: std_logic_vector(31 downto 0);

	BEGIN

    IF (clock'event AND clock = '1') THEN
  	  -- wait on mem_ready_to_use;

  		-- Below logic fills up he instruction memory, happens once.
  		IF (mem_ready_to_use = '0') THEN
  		  memwrite<='1';
  			--open file: path specified in the second argument
  			file_open (ex_file, "\\campus.mcgill.ca\emf\cpe\astepa2\Desktop\ECSE425\ECSE425\ECSE425_deliverable4\program.txt", READ_MODE);
  			--Read through 1024 lines of text file and save to memory
  			IF not endfile(ex_file) and i < 1024 THEN
  				PC<= std_logic_vector(to_unsigned(i,32));
  				readline (ex_file, current_line);
  				read (current_line, data_line);
  				writedata <= data_line;
  				--WAIT FOR clk_period/2;
  				i := i + 1;
  			END IF;

  			file_close (ex_file);
  			memwrite <= '0';
  			done_writing <= '1';
  			--tell InstructionMEM writing is done
  		END IF;

  --			i := 8;
  --			memread <= '1';
  --			while i < 41 loop
  --				clock <= not clock;
  --				address<= std_logic_vector(to_unsigned(i,32));
  --				WAIT FOR clk_period/2;
  --				clock <= not clock;
  --				i := i + 1;
  --				WAIT FOR clk_period/2;
  --			END LOOP;
  --
  --			address <= std_logic_vector(to_unsigned(10,32));
  --
  --			clock <= not clock;
  --			WAIT FOR clk_period/2;
  --			clock <= not clock;
  --			WAIT FOR clk_period/2;
  --			clock <= not clock;
  --			WAIT FOR clk_period/2;

    END IF;

	END PROCESS;


  clock_process : process

  BEGIN

    wait for clk_period/2;
    clock <= not clock;
    wait for clk_period/2;
    clock <= not clock;

  END process;



end arch;
