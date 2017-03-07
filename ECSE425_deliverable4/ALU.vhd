--*******************************************************************************************************************************************************
-- ALU implementation for the pipelined processor
-- See details for OPs at https://cse.sc.edu/~jbakos/611/tutorials/alu_design_specs.shtml

-- OP codes: https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats

-- OP codes and Instr codes for this project: Look into the instruction_types folder in the assembler folder
-- ALU must implement up to 15 arithmetical functions, need 4 bit OP code input to indicate what instruction
-- we need to apply on both data inputs

-- From java file:

--    R INSTRUCTION FORMAT:
--      B31-26	    B25-21	    B20-16	    B15-11	    B10-6	        B5-0
--      opcode  	register s	register t	register d	shift amount	function
--      EXAMPLE:
--      add $rd, $rs, $rt


--    I INSTRUCTION FORMAT:
--      B31-26	    B25-21	    B20-16	        B15-0
--      opcode  	register s	register t      immediate
--      EXAMPLE:
--      addi $rt, $rs, immediate

--	Note: Since immediate instructions are made in such way so that we extend the sign from 16 bit to 32, they are the same instruction basically, but with extended input
--  Hence add=addi, slt=slti, and=andi and so on, we will get the same ALU control code from ALU control for both operations.
--  Hence subset of instructons to implement:
-- add (=addi)
-- sub
-- mult
-- div
-- slt 		(=slti)
-- and 		(=andi)
-- or 		(=ori)
-- nor
-- xor 		(=xori)
-- mfhi
-- mflo
-- lui
-- slt
-- srl
-- sra
-- 15 functions: 4 bit necessary for ALU Control to output to ALU to indicate the right operation. ALU Control will intake instruction OP code and INSTR code (in R type
-- instructions only and output a 4-bit signal to ALU to indicate which function to choose)
-- 
-- MAPPING TO CONSIDER IN THE ALU CONTROL UNIT:

-- add 		(=addi)			0000
-- sub 						0001
-- mult						0010
-- div						0011
-- slt 		(=slti)			0100
-- and 		(=andi)			0101
-- or 		(=ori)			0110
-- nor						0111
-- xor 		(=xori)			1000
-- mfhi						1001
-- mflo						1010
-- lui						1011
-- slt 						1100
-- srl 						1101
-- sra						1110

-- *******************************************************************************************************************************************************


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALU is 

	port(
		clk: in std_logic;
		ALU_CONTROL_CODE: in std_logic_vector(3 downto 0);
		data_A : in std_logic_vector(31 downto 0);
		data_B : in std_logic_vector(31 downto 0);
		ZERO : out std_logic;
		RESULT : out std_logic_vector(31 downto 0);
	);

end entity ALU;

architecture alu_arch of ALU is

	begin

		alu_proc : process(ALU_function_code,dataA,dataB)

		begin

		--ALU logic here

		end process;

	end architecture;