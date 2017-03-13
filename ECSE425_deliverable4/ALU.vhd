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
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALU is

	port(
		clk: in std_logic;										--clock
		ALU_CONTROL_CODE: in std_logic_vector(3 downto 0);--control code for ALU OP from ALU Control
		data_A : in std_logic_vector(31 downto 0);				--RS reg
		data_B : in std_logic_vector(31 downto 0);				--RT reg
		shamt: in IN  STD_LOGIC_VECTOR (31 DOWNTO 0);     --Will be easier to have a dedicated shift amount
		ZERO : out std_logic;									--zero out
		RESULT : out std_logic_vector(31 downto 0) 		--result out
	);

end entity ALU;

architecture alu_arch of ALU is

	signal intermediate_result: std_logic_vector(31 downto 0);
	signal intermediate_zero: std_logic;
	--Need a HI and LO registers to keep the 64 bit result from multiplication and division
	signal HI: std_logic_vector(31 downto 0);
	signal LO: std_logic_vector(31 downto 0);


	begin

	ALU_Process : process (data_A, data_B, ALU_CONTROL_CODE, shamt)

		--Var necessary to 32x32 bit mult and 32/32 bit div
		variable multiplication_res : std_logic_vector(63 downto 0);

		--Var necessary to 32/32 bit div and remained for lower bits
		variable division_res : std_logic_vector(32 downto 0);
		variable division_remainer : std_logic_vector(32 downto 0);

		--More on division and multiplication for ALU check here: https://www.d.umn.edu/~gshute/logic/multiplication-division.xhtml
		--More on slt check here: http://web.cse.ohio-state.edu/~teodores/download/teaching/cse675.au08/Cse675.02.F.ALUDesign_part2.pdf

		variable lui_temp : std_logic_vector(32 downto 0);

		begin

				intermediate_zero<='0';

				case ALU_CONTROL_CODE is

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
						if (signed(data_A) < signed(data_B)) then
							intermediate_result <= '00000000000000000000000000000001';
						else
							intermediate_result <= '00000000000000000000000000000000';
						end if;

					--CASE and,andi
					when "0101" =>
						intermediate_result <= data_A and data_B;

					--CASE or,ori
					when "0110" =>
						intermediate_result <= data_A or data_B;

					--CASE nor
					when "0111" =>
						intermediate_result <= data_A nor data_B;

					--CASE xor, xori
					when "1000" =>
						intermediate_result <= data_A xor data_B;

					--CASE mfhi
					--For purposes of moving the higher bits of mult or div onto geenral purpose reg
					when "1001" =>
						intermediate_result <= LO;

					--CASE mflo
					--For purposes of moving the lower bits of mult or div onto geenral purpose reg
					when "1010" =>
						intermediate_result <= HI;

					--CASE lui
					--Shifts the immediate value to left by 16 bits and lower bits become all 0's
					--First do sll and then assign 0's to bits 0 to 15
					--Upper immediate will be provided in data_A
					when "1011" =>
						lui_temp := to_stdlogicvector(to_bitvector(data_A) sll 16);
						--lui_temp(15 downto 0) <= '0000000000000000';
						intermediate_result <= lui_temp;

					--CASE sll
					-- Shift amounts specified in data_B (no shamt signal incoming to ALU)
					when "1100" =>
						intermediate_result <= to_stdlogicvector(to_bitvector(data_A) sll to_integer(signed(data_B)));

					--CASE slr
					when "1101" =>
						intermediate_result <= to_stdlogicvector(to_bitvector(data_A) slr to_integer(signed(data_B)));

					--CASE sra
					when "1110" =>
						intermediate_result <= to_stdlogicvector(to_bitvector(data_A) sra to_integer(signed(data_B)));

					--CASE eq (needed to produce zero signal for beq, bne)
					when "1111" =>
						if (signed(data_A) = signed(data_B))  then
							intermediate_zero <= '1';
							else
							intermediate_zero <= '0';
						end if;

					when others =>
						intermediate_zero<='0';
						c <= 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

				end case;

		end process;

		RESULT <= intermediate_result;
		ZERO <= intermediate_zero;

	end alu_arch;
