--Main driver reponsible to connect all the stahes in the pipelined processor.
--Will be driven from a clock coming from the testbench

--Integration part is being done here!

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use work.signal_types.all;

--Main driver entity connecting all the stages
ENTITY DriverPrime IS

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
END DriverPrime;

ARCHITECTURE arch OF DriverPrime IS

--  --Control uni declaration
--	COMPONENT CPU_control_unit IS
--		PORT (
--			instr 	: IN	STD_LOGIC_VECTOR (31 DOWNTO 0);
--			IF_control_signals 	: OUT IF_CTRL_SIGS;
--			ID_control_signals 	: OUT ID_CTRL_SIGS;
--			EX_control_signals 	: OUT EX_CTRL_SIGS;
--			MEM_control_signals : OUT MEM_CTRL_SIGS;
--			WB_control_signals 	: OUT WB_CTRL_SIGS
--		);
--	END COMPONENT;
--
--  -- Signals needed to pass control signals from control unit to all other stages, resulting in output of the control unit
--	SIGNAL IF_control_signals  : IF_CTRL_SIGS;
--	SIGNAL ID_control_signals  : ID_CTRL_SIGS;
--	SIGNAL EX_control_signals  : EX_CTRL_SIGS;
--	SIGNAL MEM_control_signals : MEM_CTRL_SIGS;
--	SIGNAL WB_control_signals  : WB_CTRL_SIGS;


  --Port map for the Instruction Fetch Stage
	COMPONENT Instruction_Fetch_Prime IS
    PORT (Clock									: IN	STD_LOGIC;
          Reset									: IN	STD_LOGIC;
          -- IF_Stall							: IN  STD_LOGIC; --stall from ID if needed
          read_Instruction			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
          IF_PC									: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --next address
          IF_Instruction				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
	END COMPONENT;

	SIGNAL IF_PC : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL IF_instruction : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL branch_taken : STD_LOGIC;

-- Architecture begin, map every stage signal
BEGIN

  --Port mapping all the control signals
--	control_unit_map : CPU_control_unit
--		PORT MAP (
--			instr => IF_instruction, --GETS FROM instruction fetch
--			IF_control_signals => IF_control_signals,
--			ID_control_signals => ID_control_signals,
--			EX_control_signals => EX_control_signals,
--			MEM_control_signals => MEM_control_signals,
--			WB_control_signals => WB_control_signals
--		);

  --Port mapping instruction fetch.
  --Gets inputs from control and branch signals and outputs the instruction to be decoded
	IF_map : Instruction_Fetch_Prime
		PORT MAP (
  			Clock => clk,
  			Reset => rst,
  			read_Instruction => instr_mem_read,  --NOTE: Wired to input of the driver, driver talks to instruction memory to get the actual instruction
  			IF_PC => IF_PC,        --NOTE: Wired to output of the driver, driver talks to instruction memory to provide the address for instruction
  			IF_Instruction => IF_instruction
    	);

END arch;
