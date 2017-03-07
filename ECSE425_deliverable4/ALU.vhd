--ALU implementation for the pipelined processor
--See details for OPs at https://cse.sc.edu/~jbakos/611/tutorials/alu_design_specs.shtml

--OP codes: https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats

--ALU must implement up to 15 arithmetical functions, need 4 bit OP code input to indicate what instruction
--we need to apply on both data inputs
--0000 > add
--0001 > and

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALU is 

	port(
		clk: in std_logic;
		ALU_op_code: in std_logic_vector(3 downto 0);
		dataA : in std_logic_vector(31 downto 0);
		dataB : in std_logic_vector(31 downto 0);
		--ZERO : out std_logic;
		RESULT : out std_logic_vector(31 downto 0);
	);

end entity ALU;

architecture alu_arch of ALU is

	begin

		alu_proc : process(dataA,dataB)

		begin

		--ALU logic here

		end process;

	end architecture;