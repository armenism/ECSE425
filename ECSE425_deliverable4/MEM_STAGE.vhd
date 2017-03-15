--STAGE for MEMORY write/reads
--This stage is responsible to read/write to main memory as well as pass the ALU output further to WB stage.
--The output from ALU is used  as the address to input to memory if lw or sw operations are true in control
--or use the arithmetical result of the ALU is passed further to wrete back stage.
--To be noted, the data to be written in the sw operation is also passed as input here from the EX stage

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use signal_types.all

entity MEM_STAGE is

  generic(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
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
    destination_reg_RD_out: out std_logic_vector (4 downto 0);

    --To be passed to WB stage
    WB_STAGE_CONTROL_SIGNALS_out: out WB_CTRL_SIGS

  );

end entity;


architecture arch of MEM_STAGE is

  -------------------------------------------------------------COMPONENTS

  ------Main Memory component
  component DataMEM is
    port(
      clock: IN STD_LOGIC;
      writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      address: IN INTEGER RANGE 0 TO ram_size-1;
      memwrite: IN STD_LOGIC;
      memread: IN STD_LOGIC;
      readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      waitrequest: OUT STD_LOGIC
    );
  end component;

  -------------------------------------------------------------SIGNALS
  --Will map to memory data or the ALU output bypassing the memory
	signal intermediate_data_out : std_logic_vector (31 downto 0);
  --Memory module related signals


  signal address_for_memory: INTEGER RANGE 0 TO ram_size-1;
  signal data_read_from_memory: INTEGER RANGE 0 TO ram_size-1;
  signal data_to_write_to_memory: INTEGER RANGE 0 TO ram_size-1;
  signal waitrequest_from_memory:  STD_LOGIC; --> DO SOMETHING WITH THIS

  signal do_mem_read: std_logic;
  signal do_mem_write: std_logic;

begin

  -------------------------------------------------------------MUXES
  -- Address for the memory must be BYTE addressable. We have from 0 to 32767 bytes. The ALU output containing
  -- the address is a 32 bit address (at lw or sw operations). Truncate the address to use only the lower 15 bit.
  -- Also, convert the 15 bit address onto an integer, since memory acccepts integer as address.
  address_for_memory <= unsigned(ALU_output_from_EX(14 downto 0));

  --Set signals according to the MEM control signals if its a write or a read
  do_mem_read <= '1' when MEM_STAGE_CONTROL_SIGNALS.read_from_memory = '1';
  do_mem_write <= '1' when MEM_STAGE_CONTROL_SIGNALS.write_to_memory = '1';

  --TODO: make compatible 32bit data from ALU or register to be written to memory (FOR READ AND WRITE)

  --   32 BIT                     --8 BIT
  data_to_write_to_memory <= data_to_write_from_EX;

  -- 32 BIT                     --8 BIT
  intermediate_data_out <= data_read_from_memory when MEM_STAGE_CONTROL_SIGNALS.read_from_memory = '1' else
    ALU_output_from_EX;


  -------------------------------------------------------------PORTMAPS

  --Main memory module portmap
  main_memory : DataMEM
    port map(
    clock: => clk,
    writedata: => data_to_write_to_memory,
    address => address_for_memory,
    memwrite => do_mem_write,
    memread => do_mem_read,
    readdata => data_read_from_memory,
    waitrequest => waitrequest_from_memory
  );

  -------------------------------------------------------------PROCESSES
  ------Actual stage process
  MEM_STAGE_PROCESS : process (clk, reset)

  	begin

  		if reset = '1' then

        data_out_to_WB <= (others => '0');
        destination_reg_RD_out <= (others => '0');
  			WB_STAGE_CONTROL_SIGNALS_out <= (others => '0');

  		elsif rising_edge(clk) then

  			if rdy = '1' then

          data_out_to_WB <= intermediate_data_out;
          destination_reg_RD_out <= destination_reg_RD;
          WB_STAGE_CONTROL_SIGNALS_out <= WB_STAGE_CONTROL_SIGNALS;

  			end if;

      end if;

  end process;

end arch;
