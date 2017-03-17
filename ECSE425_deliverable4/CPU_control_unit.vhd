--Main control unit, responsible to intake the 32bit instruction vector and assign control signals for each stage.
--Those control signals will be propagated further down the pipeline.
--The control checks all the fields of the instruction, including op code, RS, RT, RD, immediate, func for R,L,J instruction
--types.

--Takes the instruction from the IF stage (supposed to read the instruction from the instr memory and pass it here)

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signal_types.all;

entity CPU_control_unit is
  port(
    instruction: in std_logic_vector(31 downto 0); --the actual binary instruction that will get fetched.
    IF_SIGS: out IF_CTRL_SIGS; -- All the control signals (types) to be passed down the pipe
    ID_SIGS: out ID_CTRL_SIGS;
    EX_SIGS: out EX_CTRL_SIGS;
    MEM_SIGS:  out MEM_CTRL_SIGS;
    ctrl_WB: out WB_CTRL_SIGS
  );
end CPU_control_unit;

architecture control of CPU_control_unit is

  signal funct: std_logic_vector(5 downto 0) is instruction(5 downto 0); --funct code is defined in the lower 6 bits of the 32 bit instruction
  signal op_code: std_logic_vector(5 downto 0) is instruction(31 downto 26);  --OP code is defined in the upper 6 bits of the 32 bit instruction

begin

--TODO: control process that generates control signals based on funct and op code 


end control;
