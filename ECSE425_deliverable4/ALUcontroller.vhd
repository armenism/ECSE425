-- *******************************************************************************************************************************************************
-- ALU Controller
-- Gets input from main control (from decode stage) and issues the appropriate signal to the ALU based
-- on FUNC code from instruction and the ALU OP codes

-- Gets the mapping from I type, R type operations and maps them to the appropriate alu control code.
-- Funct also used for R-type to distinguish every type of op

-- See java files for funct code since it comes directly from the instruction bits

--	Mapping

--	R-type:  OP_code R: 000000 (coming from main control from ID)
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


-- *******************************************************************************************************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALUcontroller is

	port(

		OP_code : in std_logic_vector(5 downto 0);  -- check on the vector size later. Will come from main control (ID)
		func_code: in std_logic_vector(5 downto 0); -- fucntion code coming from instruction funct field
		res_ALU_op: out std_logic_vector(3 downto 0) -- output to the actual ALU
	);

end ALUcontroller;


architecture alu_ctrl_arch of ALUcontroller is

		signal temp_res_ALU_op: std_logic_vector(3 downto 0);

		alu_ctl_process: process(ALU_op,func_code)

		begin

		-- cases for each type of ALU OP
		case ALU_op is

			-- R type instruction, where OP code is 0 for all instructions. Need to distinguish by funct code
			when "000000" =>

				case func_code =>

					-- case mult
					when "011000"
						temp_res_ALU_op <= "0010";

					-- case mflo
					when "010010"
						temp_res_ALU_op <= "1010";

					--case mfhi
					when "010000"
						temp_res_ALU_op <= "1001";

					--case add
					when "100000"
						temp_res_ALU_op <= "0000";

					--case sub
					when "100010"
						temp_res_ALU_op <= "0001";

					--case and
					when "100100"
						temp_res_ALU_op <= "0101";

					--case div
					when "011010"
						temp_res_ALU_op <= "0011";

					--case slt
					when "101010"
						temp_res_ALU_op <= "0100";

					--case or
					when "100101"
						temp_res_ALU_op <= "0110";

					--case nor
					when "100111"
						temp_res_ALU_op <= "0111";

					--case xor
					when "101000"
						temp_res_ALU_op <= "1000";

					--case sra
					when "000011"
						temp_res_ALU_op <= "1110";

					--case srl
					when "000010"
						temp_res_ALU_op <= "1101";

					--case sll
					when "000000"
						temp_res_ALU_op <= "1100";

					-- --case jr
					-- when "001000"
					-- 	temp_res_ALU_op <= "1111";

					when others =>
						null;

				end case; -- end or R type mappings

			 	--I type, slti (same as slt)
			 	when "001010" =>
			 			temp_res_ALU_op <= "0100";

				--I type, lui
				when "001111" =>
						temp_res_ALU_op <= "1011";

				--I type, andi (same as and)
				when "001100" =>
						temp_res_ALU_op <= "0101";

				--I type, ori (same as or)
				when "001101" =>
						temp_res_ALU_op <= "0110";

				--I type, xori (same as xor)
				when "001110" =>
						temp_res_ALU_op <="1000";

				--I type, bne (ZERO needed from ALU)
				when "000101" =>
						temp_res_ALU_op <="1111";

				--I type, beq (ZERO needed from ALU)
				when "000100" =>
						temp_res_ALU_op <="1111";

				--I type lw (ALU necesary for addr calculation (add offset) to load data to dataA reg froam address (dataB reg+offset) in memory <$t = MEM[$s + offset]>
				when "101011" =>
						temp_res_ALU_op <= "0000";

				--I type sw (ALU necesary for addr calculation (add offset) to save data from dataA reg to memory location ad address (dataB reg + offset) <MEM[$s + offset] = $t>
				when "100011" =>
						temp_res_ALU_op <= "0000";

				when others =>
						null;

		end case;

	end process;

	res_ALU_op <= temp_res_ALU_op;

end alu_ctrl_arch;
