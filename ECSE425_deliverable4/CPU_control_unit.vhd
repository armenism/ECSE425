--Main control unit, responsible to intake the 32bit instruction vector and assign control signals for each stage.
--Those control signals will be propagated further down the pipeline.
--The control checks all the fields of the instruction, including op code, RS, RT, RD, immediate, func for R,L,J instruction
--types.

--Takes the instruction from the IF stage (supposed to read the instruction from the instr memory and pass it here)

--	R-type:  OP_code R: 000000 (coming from main control from ID)
--					funct for mult: 011000 -done
--					funct for mflo: 010010 -done
--					funct for mfhi: 010000 -done
--					funct for  add: 100000 -done
--					funct for  sub: 100010 -done
--					funct for  and: 100100 -done
--					funct for  div: 011010 -done
--					funct for  slt: 101010 -done
--					funct for   or: 100101 -done
--					funct for  nor: 100111 -done
--					funct for  xor: 101000 -done
--					funct for  sra: 000011 -done
--					funct for  srl: 000010 -done
--					funct for  sll: 000000 -done
--					funct for   jr: 001000 -done
--
--	I-type:  OP_code I, addi : 001000
--		   OP_code I, slti : 001010
--		   OP_code I,  lui : 001111
--		   OP_code I, andi : 001100
--		   OP_code I,  ori : 001101
--		   OP_code I, xori : 001110

--		   OP_code I,  bne : 000101
--		   OP_code I,  beq : 000100
--		   OP_code I,   sw : 101011
--		   OP_code I,   lw : 100011


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

  signal instruction_type : control_unit_instruction;
  --use alias to define the funct and opcode, since its just part of the input 32 bit instruction
  alias funct: std_logic_vector(5 downto 0) is instruction(5 downto 0); --funct code is defined in the lower 6 bits of the 32 bit instruction
  alias op_code: std_logic_vector(5 downto 0) is instruction(31 downto 26);  --OP code is defined in the upper 6 bits of the 32 bit instruction

begin

--TODO: control process that generates control signals based on funct and op code

 generate_control: process(funct,op_code):

  begin

    case op_code is
      -- R TYPE case
      when "000000" =>

          --check funct field to distinguish the R-type op
          case funct =>
            --mult/div case
            when "011010" =>
                instruction_type <= r_multi_div;
            when "011000" =>
                instruction_type <= r_multi_div;
            --jr case
            when "001000" =>
                instruction_type <= r_jump_register;
            --mflo/mfhi case
            when "010000" =>
                instruction_type <= r_hilo;
            --add case
            when "100000"
                instruction_type <= r_arithmetic;
            --sub case
            when "100010"
                instruction_type <= r_arithmetic;
            --and case
            when "100100"
                instruction_type <= r_arithmetic;
            --slt case
            when "101010"
                instruction_type <= r_arithmetic;
            --or case
            when "100101"
                instruction_type <= r_arithmetic;
            --nor case
            when "100111"
                instruction_type <= r_arithmetic;
            --xor case
            when "101000"
                instruction_type <= r_arithmetic;
            --sra case
            when "000011"
                instruction_type <= r_arithmetic;
            --srl case
            when "000010"
                instruction_type <= r_arithmetic;
            --sll case
            when "000000"
                instruction_type <= r_arithmetic;



        if funct = "001000" then --jr
  					instr_type <= R_JUMP_REG;


  				ELSIF funct = "010000" OR --mfhi
  						funct = "010010" THEN --mflow
  					instr_type <= R_MOVE_HILO;

  				ELSE
  					instr_type <= R_ARITHMETIC;
  				END IF;




end control;
