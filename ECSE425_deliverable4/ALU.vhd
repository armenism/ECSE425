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
	
	signal intermediate_result: std_logic_vector(31 downto 0);

	--Need a HI and LO registers to keep the 64 bit result from multiplication and division
	signal HI: std_logic_vector(31 downto 0);
	signal LO: std_logic_vector(31 downto 0);

	begin

		alu_proc : process(ALU_CONTROL_CODE,dataA,dataB)

		--ALU logic here

		--Var necessary to 32x32 bit mult and 32/32 bit div
		variable multiplication_res : std_logic_vector(63 downto 0);

		--Var necessary to 32/32 bit div and remained for lower bits
		variable division_res : std_logic_vector(32 downto 0);
		variable division_remainer : std_logic_vector(32 downto 0);

		--More on division and multiplication for ALU check here: https://www.d.umn.edu/~gshute/logic/multiplication-division.xhtml

		begin

			case ALU_CONTROL_CODE is:

				--CASE add,addi
				when "0000" =>
					intermediate_result <= std_logic_vector(signed(data_A) + signed(data_B));

				--CASE sub
				when "0001" =>
					intermediate_result <= std_logic_vector(signed(data_A) - signed(data_B));

				--CASE mult
				when "0010" =>
					-- do signed multiplication and store higher bits in HI and lwoer bits in LO
					multiplication_res := std_logic_vector(signed(data_A) * signed(data_B));
					LO <= multiplication_res(31 downto 0);
					HI <= multiplication_res(63 downto 32);

				--CASE div
				when "0011" =>
					-- do signed division and assign higher bits to remainder
					division_res := std_logic_vector(signed(data_A) / signed(data_B));
					--division_remainer := std_logic_vector(signed(data_A) mod signed(data_B));
					division_remainer := std_logic_vector(signed(data_A) rem signed(data_B));
					LO <= division_res;
					HI <= division_remainer;

				--CASE slt,slti
				when "0100" =>
					--TODO

				--CASE and,andi
				when "0101" =>
					--TODO

				--CASE or,ori
				when "0110" =>
					--TODO
				
				--CASE nor
				when "0111" =>
					--TODO

				--CASE xor, xori
				when "1000" =>
					--TODO

				--CASE mfhi
				when "1001" =>
					--TODO

				--CASE mflo
				when "1010" =>
					--TODO

				--CASE lui
				when "1011" =>
					--TODO

				--CASE slt
				when "1100" =>
					--TODO

				--CASE slr
				when "1101" =>
					--TODO

				--CASE sra
				when "1110" =>
					--TODO

			end case;

		end process;

		RESULT <= intermediate_result;

	end architecture;