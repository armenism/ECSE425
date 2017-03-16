--*******************************************************************************************************************************************************
-- ALU implementation for the pipelined processor
-- See details for OPs at https://cse.sc.edu/~jbakos/611/tutorials/alu_design_specs.shtml

-- OP codes: https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats

-- OP codes and FUNC codes for this project: Look into the instruction_types folder in the assembler folder
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
-- sll
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
-- sll 						1100
-- srl 						1101
-- sra						1110

-- *******************************************************************************************************************************************************


LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signal_types.all;

entity ALU is

	port(
		ALU_OPERATION: in alu_operation; 									--Instead of standalone code, use alu operation from types. The bit vector will be multiplexed onto types in ID phase.
		data_A : in std_logic_vector(31 downto 0);				--RS reg
		data_B : in std_logic_vector(31 downto 0);				--RT reg
		shamt: in  std_logic_vector(31 downto 0);      --Will be easier to have a dedicated shift amount
		RESULT : out std_logic_vector(31 downto 0) 				--result out
	);

end entity ALU;

architecture alu_arch of ALU is

	signal intermediate_result: std_logic_vector(31 downto 0);

	begin

	ALU_Process : process ( data_A, data_B, ALU_OPERATION, shamt)

		variable lui_temp : std_logic_vector(31 downto 0);
		begin

				case ALU_OPERATION is

					--CASE add,addi
					when alu_add|alu_addi =>
						intermediate_result <= std_logic_vector(signed(data_A) + signed(data_B));

					--CASE sub
					when alu_sub =>
						intermediate_result <= std_logic_vector(signed(data_A) - signed(data_B));

					--CASE slt,slti
					when alu_slt|alu_slti =>
						if (signed(data_A) < signed(data_B)) then
							intermediate_result <= "00000000000000000000000000000001";
						else
							intermediate_result <= "00000000000000000000000000000000";
						end if;

					--CASE and,andi
					when alu_and|alu_andi =>
						intermediate_result <= data_A and data_B;

					--CASE or,ori
					when alu_or|alu_ori =>
						intermediate_result <= data_A or data_B;

					--CASE nor
					when alu_nor =>
						intermediate_result <= data_A nor data_B;

					--CASE xor, xori
					when alu_xor|alu_xori =>
						intermediate_result <= data_A xor data_B;

					--CASE lui
					--Shifts the immediate value to left by 16 bits and lower bits become all 0's
					--First do sll and then assign 0's to bits 0 to 15
					--Upper immediate will be provided in data_A
					when alu_lui =>
						intermediate_result <= to_stdlogicvector(to_bitvector(data_B) sll 16);

					--CASE sll
					-- Shift amounts specified in data_B (no shamt signal incoming to ALU)
					when alu_sll =>
						intermediate_result <= to_stdlogicvector(to_bitvector(data_B) sll to_integer(signed(shamt)));

					--CASE slr
					when alu_srl =>
						intermediate_result <= to_stdlogicvector(to_bitvector(data_B) srl to_integer(signed(shamt)));

					--CASE sra
					when alu_sra =>
						intermediate_result <= to_stdlogicvector(to_bitvector(data_B) sra to_integer(signed(shamt)));

					--Anything else
					when others =>
						intermediate_result <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

				end case;

		end process;

		RESULT <= intermediate_result;

	end alu_arch;
