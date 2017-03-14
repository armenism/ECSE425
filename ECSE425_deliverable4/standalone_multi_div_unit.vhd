-- To avoid using clock in ALU, carry out multiplication and division in this standalone module.
-- Will take two 32 bit data params and output a 64 bit long
--More on division and multiplication for ALU check here: https://www.d.umn.edu/~gshute/logic/multiplication-division.xhtml
--More on slt check here: http://web.cse.ohio-state.edu/~teodores/download/teaching/cse675.au08/Cse675.02.F.ALUDesign_part2.pdf

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use signal_types.all;


entity  standalone_multi_div_unit is
	port (
		OPERAND_A: in std_logic_vector (31 downto 0);
		OPERAND_B: in	 std_logic_vector (31 downto 0);
		OPERATION: in alu_operation; -->mult, div only to be used here from alu instruction types
		MULT_DIV_RESULT: out std_logic_vector (63 downto 0)
	);
end standalone_multi_div_unit;


architecture arch OF standalone_multi_div_unit is

  begin

  	MULT_OR_DIV_PROCESS : process (OPERAND_A, OPERAND_B, OPERATION)

      begin

    		if OPERATION = alu_mult then

          MULT_DIV_RESULT <= std_logic_vector(signed(OPERAND_A) * signed(OPERAND_B));

        elsif OPERATION = alu_div then

    			MULT_DIV_RESULT(31 downto 0) <= std_logic_vector( signed(source_A) / signed(source_B));
          MULT_DIV_RESULT(63 downto 32) <= std_logic_vector( signed(source_A) mod signed(source_B));

    		end if;

    	end process;

end arch;
