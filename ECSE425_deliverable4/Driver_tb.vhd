LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
USE STD.textio.all;

entity Driver_tb is
end Driver_tb;

architecture arch of Driver_tb is

--------------------------------------------------COMPONENTS

-- INSTRUCTION MEM COMPONENT
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
--
---- DATA MEM COMPONENT
COMPONENT DataMEM IS
	GENERIC(
		ram_size : INTEGER := 8192;
		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
	);
	PORT (
		clock: IN STD_LOGIC;
		writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		memwrite: IN STD_LOGIC;
		memread: IN STD_LOGIC;
		readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		waitrequest: OUT STD_LOGIC
	);
END COMPONENT;


 --MAIN CPU DRIVER COMPONENT
COMPONENT Driver IS
	PORT (
	 clk:	IN  STD_LOGIC;
	 rst: IN  STD_LOGIC;
	 
	 --INSTRUCTION MEM SINALS
	 instr_mem_address: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --mem address destined for instruction memory component (PC in 32 bit now)
    instr_mem_data: in STD_LOGIC_VECTOR (31 DOWNTO 0);    --what we get from instruction memory after requesting the address

	 
	 --DATA MEM  SIGNALS stage signals necessary to communicate with the main memory residing in the test bench 
	 data_read_from_memory : in STD_LOGIC_VECTOR (31 DOWNTO 0);
	 waitrequest_from_memory: in STD_LOGIC; 
	 data_to_write_to_memory : out STD_LOGIC_VECTOR (31 DOWNTO 0);
	 address_for_memory : out STD_LOGIC_VECTOR (31 DOWNTO 0);
	 do_mem_write	: out STD_LOGIC;
	 do_mem_read	: out STD_LOGIC
	);
	
END COMPONENT;
--------------------------------------------------COMPONENTS END


    CONSTANT clk_period : time := 1 ns;
    CONSTANT ram_size : integer := 1024;
    SIGNAL clock : std_logic := '0';
	 
	 --Instruction memory signals
    SIGNAL address: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL memwrite: STD_LOGIC := '0';
	 SIGNAL memread: STD_LOGIC := '0';
    SIGNAL inst_readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL writedata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL done_writing: STD_LOGIC := '0';
	 SIGNAL mem_ready_to_use: STD_LOGIC := '0';
	
	 --Main memory signals
	 SIGNAL address_for_memory: STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL data_to_write_to_memory:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL data_read_from_memory: STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL do_mem_write	:  STD_LOGIC;
	 SIGNAL do_mem_read	:  STD_LOGIC;
	 SIGNAL waitrequest_from_memory:  STD_LOGIC;
	 
	 SIGNAL transitive_address:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	 	 
	 --Reset
	 SIGNAL reset : STD_LOGIC := '0';

--------------------------------------------------BEGIN ARCH
BEGIN

--------------------------------------------------MAIN DRIVER PORT MAP
Main_Driver:
	Driver PORT MAP(
			 clk => clock,
			 rst => reset,
	       		 instr_mem_address => transitive_address,
          		 instr_mem_data => inst_readdata, 
			 data_read_from_memory => data_read_from_memory,
			 waitrequest_from_memory => waitrequest_from_memory,
			 data_to_write_to_memory => data_to_write_to_memory,
			 address_for_memory => address_for_memory,
			 do_mem_write => do_mem_write,
			 do_mem_read  => do_mem_read
	);

----------------------------------------------------INSTR MEM PORT MAP
Instruction_Memory:
    InstructionMEM GENERIC MAP(
            ram_size => 1024
                )
                PORT MAP
					 (
							clock,
							writedata,
							address,		--PC
							memwrite,
							memread,
							done_writing,
							mem_ready_to_use,
							inst_readdata
					 );
----------------------------------------------------DATA MEM PORT MAP
Data_Memory:
	DataMEM 	GENERIC MAP(
		ram_size => 8192
	)
	PORT MAP (
		clock => clock,
		writedata => data_to_write_to_memory,
		address => address_for_memory,
		memwrite => do_mem_write,
		memread =>do_mem_read,
		readdata => data_read_from_memory,
		waitrequest => waitrequest_from_memory
	);	
	
	

--------------------------------------------------CLOCK PROCESS		
clock_process : process
  BEGIN

    wait for clk_period/2;
    clock <= not clock;
    wait for clk_period/2;
    clock <= not clock;

  END process;

--------------------------------------------------MAIN PROCESS					
test_process : process

	FILE ex_file: text;
   VARIABLE current_line: line;
	variable i : integer := 0;
	variable j : integer := 0;
	VARIABLE data_line: std_logic_vector(31 downto 0);

	BEGIN
	  
	  wait on mem_ready_to_use;
		
		-- Below logic fills up he instruction memory, happens once. 
		IF (mem_ready_to_use = '0') THEN
		  done_writing <= '0';
		  memwrite<='1';
		  WAIT FOR clk_period;
			--open file: path specified in the second argument
			file_open (ex_file, "\\campus.mcgill.ca\emf\cpe\astepa2\Desktop\ECSE425\ECSE425\ECSE425_deliverable4\program(THE RE UP).txt", READ_MODE);
			--Read through 1024 lines of text file and save to memory
			while not endfile(ex_file) and i < 1024 loop
				address<= std_logic_vector(to_unsigned(i,32));
				readline (ex_file, current_line);
				read (current_line, data_line);
				writedata <= data_line;
				WAIT FOR clk_period;
				i := i + 1;
				WAIT FOR clk_period;
			END LOOP;
			
			file_close (ex_file);
			memwrite <= '0';
			done_writing <= '1';
			address <=   "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
			writedata <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
			--address_for_memory <= (OTHERS => '0');
		END IF;
	
		--Once the main memory is done filling up, we can launch CPU simulation
		--Condition to be able to use the memory only and only if its filled up
		IF (mem_ready_to_use = '1') THEN
		
			reset <= '1';
			WAIT FOR clk_period;
			memread <='1';
			reset <= '0';
			while j < 10000 loop
				--As soon as done writing to instruction memory, can read instructions.
				
				address <= transitive_address;
				WAIT FOR clk_period;
				j := j + 1;
			end loop;

		END IF;

	END PROCESS;

end arch;













