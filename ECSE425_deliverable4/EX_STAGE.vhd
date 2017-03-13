--EXECUTION stage
--Gets control and data from ID stage for current ALU operation, data forwarding and control signals
--for writeback stage to be forwarded further down the pipe.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity EX_STAGE is

  port(
    --operation related signals
    clk: in std_logic;
    rdy: in std_logic;
    reset: in std_logic;

    --Register file related data
    data_from_RS: in std_logic_vector (31 downto 0);
    data_from_RT: in std_logic_vector (31 downto 0);
    shift_amount: in std_logic_vector (4 downto 0);

    program_counter: in std_logic_vector (31 downto 0);
    sign_extended_IMM: in in std_logic_vector (31 downto 0);
    destination_reg_RD: in std_logic_vector (4 downto 0);

    --Control signals to current stage:
    EX_STAGE_CONTROL_SIGNALS: in EX_CTRL_SIGS;
    --Control signals to be passed to further stages:
		MEM_STAGE_CONTROL_SIGNALS: in MEM_CTRL_SIGS;
		WB_STAGE_CONTROL_SIGNALS: IN WB_CTRL_SIGS;

    );
