--STAGE for MEMORY write/reads

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use signal_types.all

entity MEM_STAGE is
  port(

    --STAGE INPUTS
    --operation related signals
    clk: in std_logic;
    rdy: in std_logic;
    reset: in std_logic;

    --Data related inputs
    ALU_output_from_EX: in std_logic_vector(31 downto 0);
    data_to_write_from_EX: in std_logic_vector(31 downto 0);
    destination_reg_RD: in std_logic_vector (4 downto 0);

    --MEM stage control signals coming passed from EX stage. To be consumed here.
    --WB stage signals coming passed from EX stage. To be passed further to WB stage.
    EM_STAGE_CONTROL_SIGNALS: in MEM_CTRL_SIGS;
		WB_STAGE_CONTROL_SIGNALS: in WB_CTRL_SIGS;

    --TODO: Memory module inputs


    --STAGE OUTPUTS
    --Data read from memory
    data_out: out std_logic_vector(31 downto 0);
    destination_reg_RD_out: out std_logic_vector (4 downto 0);

    --To be passed to WB stage
    WB_STAGE_CONTROL_SIGNALS_out: out WB_CTRL_SIGS

  );

end entity;


architecture arch of MEM_STAGE is

  --Will map to memory data or the ALU output bypassing the memory
	signal intermediate_data_out : std_logic_vector (31 downto 0);

BEGIN

  -------------------------------------------------------------PROCESSES
  ------Actual stage process
  MEM_STAGE_PROCESS : process (clk, reset)

  	begin

  		if reset = '1' then

        data_out <= (others => '0');
        destination_reg_RD_out <= (others => '0');
  			WB_STAGE_CONTROL_SIGNALS_out <= (others => '0');

  		elsif rising_edge(clk) then

  			if rdy = '1' then

          data_out <= intermediate_data_out;
          destination_reg_RD_out <= destination_reg_RD;
          WB_STAGE_CONTROL_SIGNALS_out <= WB_STAGE_CONTROL_SIGNALS;

  			end if;

      end if;

  end process;


  ------Process to read/write to/from memory
  MEM_OPERATION_PROCESS : process (clk, reset)

  	begin

    --TODO: read from memory and then assign the result to the intermediate_data_out signal.
   end process;

end arch;
