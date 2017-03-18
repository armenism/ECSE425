--Main driver reponsible to connect all the stahes in the pipelined processor.
--Will be driven from a clock coming from the testbench

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.signal_types.all;

entity Driver is
	port (
		clk:	in  std_logic;
		rst: 	in  std_logic;
    mem_data: 	in std_logic_vector (31 downto 0);
		mem_address:	out integer
	);

end Driver;

architecture arch of Driver is

	signal ready : std_logic;
	signal init : std_logic;

  --Control component
	component CPU_control_unit is
		port (
      instruction: in std_logic_vector(31 downto 0); --the actual binary instruction that will get fetched.
      IF_SIGS: out IF_CTRL_SIGS; -- All the control signals (types) to be passed down the pipe
      ID_SIGS: out ID_CTRL_SIGS;
      EX_SIGS: out EX_CTRL_SIGS;
      MEM_SIGS:  out MEM_CTRL_SIGS;
      WB_SIGS: out WB_CTRL_SIGS
  		);
	end component;

  --Control temp signals
	signal IF_SIGS  : IF_CTRL_SIGS;
	signal ID_SIGS  : ID_CTRL_SIGS;
	signal EX_SIGS  : EX_CTRL_SIGS;
	signal MEM_SIGS : MEM_CTRL_SIGS;
	signal WB_SIGS  : WB_CTRL_SIGS;

  --Instruction Fetch component
	component IF is
		port (
          IF_Control: in IF_CTRL_SIGS;
					Clock: in	std_logic;
					Reset: in	std_logic;
					Init: in 	std_logic;
					Ready: in	std_logic;
					IF_Stall: in  std_logic;
					ID_Branch_Zero: in std_logic;
					ID_Branch_Address: in	std_logic_vector(31 downto 0);
					Branch_Taken: out std_logic; --signal to ID to flush address
					IF_PC: out std_logic_vector (31 downto 0); --next address
					IF_instruction: out std_logic_vector (31 downto 0)
					);
	end component;

  --Seignals needed for instruction fetch (for now)
  signal Branch_Taken : std_logic;
	signal IF_PC : std_logic_vector (31 downto 0);
	signal IF_instruction : std_logic_vector (31 downto 0);
  signal ID_stall_IF	: std_logic;
  signal ID_br_zero	: std_logic;
  signal ID_br_zero 	: std_logic;
  signal ID_br_addr 	: std_logic_vector (31 DOWNTO 0);
  signal IF_PC : std_logic_vector (31 DOWNTO 0);
  signal branch_taken : STD_LOGIC;

BEGIN

  --TO BE TESTED
	mem_address <= TO_INTEGER (UNSIGNED(mem_bus_addr));
	ready <= '1';
	init <= '0';
  ID_stall_IF <='0';
  --

	control_unit : CPU_control_unit
		PORT MAP (
      instruction => IF_instruction,
      IF_SIGS => IF_SIGS,
      ID_SIGS => ID_SIGS;
      EX_SIGS => EX_SIGS;
      MEM_SIGS => MEM_SIGS;
      WB_SIGS => WB_SIGS
		);

	if_stage : IF
		PORT MAP (
			clk => clk,
			rst => rst,
			init => init,
			ready => ready,
			IF_Control => IF_SIGS,
			IF_Stall => ID_stall_IF,
			ID_Branch_Zero => ID_br_zero,
			ID_Branch_Address => ID_br_addr,
			Memory_Bus_Data => mem_data,
			IF_PC => IF_PC,
			IF_instr => IF_instruction,
			Branch_Taken => branch_taken
    );

END arch;
