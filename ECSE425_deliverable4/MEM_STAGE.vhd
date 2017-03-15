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

    --STAGE OUTPUTS
    --Data read from memory
    data_read_from_memory: in std_logic_vector(31 downto 0);
    destination_reg_RD_out: in std_logic_vector (4 downto 0);
    WB_STAGE_CONTROL_SIGNALS_out: in WB_CTRL_SIGS;

  );

end entity;
