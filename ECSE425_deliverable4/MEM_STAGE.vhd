--STAGE for MEMORY write/reads
--This stage is responsible to read/write to main memory as well as pass the ALU output further to WB stage.
--The output from ALU is used  as the address to input to memory if lw or sw operations are true in control
--or use the arithmetical result of the ALU is passed further to wrete back stage.
--To be noted, the data to be written in the sw operation is also passed as input here from the EX stage

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signal_types.all;

entity MEM_STAGE is

  generic(
    ram_size : INTEGER := 8192;
    mem_delay : time := 1 ns;
    clock_period : time := 1 ns
  );

  port(

    --STAGE INPUTS
    --operation related signals
    clk: in std_logic;
    rdy: in std_logic;
    reset: in std_logic;

    --Data related inputs
    ALU_output_from_EX: in std_logic_vector(31 downto 0);    --> The ALU output to forward to WB, or computed address for lw and sw
    data_to_write_from_EX: in std_logic_vector(31 downto 0); --> Whatever we want to write from the register RT
    destination_reg_RD: in std_logic_vector (4 downto 0);

    --MEM stage control signals coming passed from EX stage. To be consumed here.
    --WB stage signals coming passed from EX stage. To be passed further to WB stage.
    MEM_STAGE_CONTROL_SIGNALS: in MEM_CTRL_SIGS;
	 WB_STAGE_CONTROL_SIGNALS: in WB_CTRL_SIGS;

    --STAGE OUTPUTS
    --Data read from memory/ALU
    data_out_to_WB: out std_logic_vector(31 downto 0);
    MEM_destination_reg_RD_out: out std_logic_vector (4 downto 0);

    --To be passed to WB stage
    MEM_WB_STAGE_CONTROL_SIGNALS_out: out WB_CTRL_SIGS;
	 
    --Bypass outputs
	 bp_MEM_reg_write	: OUT STD_LOGIC;
	 bp_MEM_reg_data 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	 bp_MEM_dest_reg 	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
	
	 --Interface sinals to and from driver that comminucates with the main memory 
	 --data_read_from_memory : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    --waitrequest_from_memory: IN STD_LOGIC;
	 
	 --data_to_write_to_memory : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    --address_for_memory : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    --do_mem_write	: OUT STD_LOGIC;
    --do_mem_read	: OUT STD_LOGIC
	 
  );

end MEM_STAGE;


architecture arch of MEM_STAGE is

  -------------------------------------------------------------COMPONENTS
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
  -------------------------------------------------------------SIGNALS
  --Will map to memory data or the ALU output bypassing the memory
	signal intermediate_data_out : std_logic_vector (31 downto 0);
		 --Main memory signals
	SIGNAL address_for_memory: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL data_to_write_to_memory:  STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL data_read_from_memory: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL do_mem_write	:  STD_LOGIC;
	SIGNAL do_mem_read	:  STD_LOGIC;
	SIGNAL waitrequest_from_memory:  STD_LOGIC;

begin

  -------------------------------------------------------------MUXES

  intermediate_data_out <= data_read_from_memory when do_mem_read = '1' else
    ALU_output_from_EX;
	 
  ----------------------------------------------------DATA MEM PORT MAP
	Data_Memory:
		DataMEM 	GENERIC MAP(
			ram_size => 8192
		)
		PORT MAP (
			clock => clk,
			writedata => data_to_write_to_memory,
			address => address_for_memory,
			memwrite => do_mem_write,
			memread =>do_mem_read,
			readdata => data_read_from_memory,
			waitrequest => waitrequest_from_memory
		);	

  -------------------------------------------------------------PROCESSES

  ------Memory operation process
  MEMORY_PROCESS : process (clk)
  begin

    --Set inputs to memeory
    if rising_edge(clk) then
	 
      -- Address for the memory must be BYTE addressable. We have from 0 to 32767 bytes. The ALU output containing
      -- the address is a 32 bit address (at lw or sw operations). Truncate the address to use only the lower 15 bit.
      -- Also, convert the 15 bit address onto an integer, since memory acccepts integer as address.
		address_for_memory <= ALU_output_from_EX;
		
      --Set signals according to the MEM control signals if its a write or a read
		if (MEM_STAGE_CONTROL_SIGNALS.read_from_memory = '1') then
			do_mem_read <= '1';
		else
			do_mem_read <= '0'; --otherwise will be always U
		end if;
		
		if (MEM_STAGE_CONTROL_SIGNALS.write_to_memory = '1') then
			do_mem_write <= '1';
			data_to_write_to_memory <= data_to_write_from_EX;
		else 
			do_mem_write <= '0';
		end if;
		
      --Once memory returns wait request, we have its output if memory read operation was performed.
      --wait until rising_edge(waitrequest_from_memory);

    end if;

  end process;


  ------Actual stage process
  MEM_STAGE_PROCESS : process (clk, reset)

  	begin

  		if reset = '1' then

        data_out_to_WB <= (others => '0');
        MEM_destination_reg_RD_out <= (others => '0');
  		  MEM_WB_STAGE_CONTROL_SIGNALS_out <= (others => '0');
		  --data_read_from_memory <= (others => '0');

  		elsif rising_edge(clk) then

  			if rdy = '1' then

          data_out_to_WB <= intermediate_data_out;
          MEM_destination_reg_RD_out <= destination_reg_RD;
          MEM_WB_STAGE_CONTROL_SIGNALS_out <= WB_STAGE_CONTROL_SIGNALS;

  			end if;

      end if;

  end process;
  
	bp_MEM_reg_write <= WB_STAGE_CONTROL_SIGNALS.write_to_register;
	bp_MEM_reg_data  <= intermediate_data_out;
	bp_MEM_dest_reg  <= destination_reg_RD;

end arch;
