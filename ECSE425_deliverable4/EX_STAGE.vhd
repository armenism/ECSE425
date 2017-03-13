--EXECUTION stage
--Gets control and data from ID stage for current ALU operation, data forwarding and control signals
--for writeback stage to be forwarded further down the pipe.

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use signal_types.all

entity EX_STAGE is

  port(

    --STAGE INPUTS
    --operation related signals
    clk: in std_logic;
    rdy: in std_logic;
    reset: in std_logic;

    --Register file related data
    EX_data_from_RS: in std_logic_vector (31 downto 0);
    EX_data_from_RT: in std_logic_vector (31 downto 0);
    EX_shift_amount: in std_logic_vector (4 downto 0);

    EX_program_counter: in std_logic_vector (31 downto 0);
    EX_sign_extended_IMM: in in std_logic_vector (31 downto 0);
    EX_destination_reg_RD: in std_logic_vector (4 downto 0);

    --Control signals to current stage:
    EX_STAGE_CONTROL_SIGNALS: in EX_CTRL_SIGS;
    --Control signals to be passed to further stages:
		MEM_STAGE_CONTROL_SIGNALS: in MEM_CTRL_SIGS;
		WB_STAGE_CONTROL_SIGNALS: IN WB_CTRL_SIGS;

    --STAGE OUTPUTS
    EX_ALU_result_out: out std_logic_vector (31 downto 0);
    EX_write_data_out: out std_logic_vector (31 downto 0);
    EX_destination_reg_RD_out : out std_logic_vector (4 downto 0);
    --Control signals to be passed to further stages:
    MEM_STAGE_CONTROL_SIGNALS_out: in MEM_CTRL_SIGS;
    WB_STAGE_CONTROL_SIGNALS_out: IN WB_CTRL_SIGS
    );

architecture arch of EX_STAGE is
  begin

  end arch;
