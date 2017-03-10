-- *******************************************************************************************************************************************************
-- ALU Controller
-- Gets input from main control (from decode stage) and issues the appropriate signal to the ALU based 
-- on FUNC code from instruction and the ALU OP codes

-- Gets the mapping from I type, R type lw and br operations and maps them to the appropriate alu control code.
-- Funct also used for R-type to distinguish every type of op

-- See java files for funct code since it comes directly from the instruction bits

--Mapping

--R-type:  OP_code R: 000000 (coming from main control from ID)
--					funct for mult: 011000
--					funct for mflo: 010010
--					funct for mfhi: 010000
--					funct for  add: 100000
--					funct for  sub: 100010
--					funct for  and: 100100
--					funct for  div: 011010
--					funct for  slt: 101010
--					funct for   or: 100101
--					funct for  nor: 100111
--					funct for  xor: 101000
--					funct for  sra: 000011
--					funct for  srl: 000010
--					funct for  sll: 000000
--					funct for   jr: 001000
--
--I-type:  OP_code I, addi : 001000
--		   OP_code I, slti : 001010
--		   OP_code I,  lui : 001111
--		   OP_code I, andi : 001100
--		   OP_code I,  ori : 001101
--		   OP_code I, xori : 001110

--		   OP_code I,  bne : 000101 
--		   OP_code I,  beq : 000100
--		   OP_code I,   sw : 101011
--		   OP_code I,   lw : 100011
						

-- *******************************************************************************************************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALUcontroller is

	port(

		OP_code : in std_logic_vector(5 downto 0);  -- check on the vector size later. Will come from main control (ID)
		func_code: in std_logic_vector(5 downto 0); -- fucntion code coming from instruction funct field
		res_ALU_op: out std_logic_vector(3 downto 0); -- output to the actual ALU
	);

end ALUcontroller;


architecture alu_ctrl_arch of ALUcontroller is

	signal temp_res_ALU_op: std_logic_vector(3 downto 0);

	alu_ctl_process: process(ALU_op,func_code)

		begin


		end process;

	res_ALU_op <= temp_res_ALU_op;

end alu_ctrl_arch;

