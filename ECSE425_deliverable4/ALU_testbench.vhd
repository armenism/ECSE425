
--Testbench for the ALU

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signal_types.all;
use work.standalone_multi_div_unit


entity ALU_testbench is
end ALU_testbench;

architecture behaviour of ALU_testbench is

--Declare component to test
	component ALU is
		port (
		  ALU_OPERATION: in alu_operation;
			data_A: in	std_logic_vector (31 downto 0);
			data_B: in	std_logic_vector (31 downto 0);
			shamt	: in  std_logic_vector (31 downto 0);
			RESULT: out std_logic_vector (31 downto 0)
		);
	end component;


	constant clk_period: time := 10 ns;
	signal clk : std_logic :='0';
	signal input_A: std_logic_vector (31 downto 0) := (others => '0');
	signal input_B: std_logic_vector (31 downto 0) := (others => '0');
	signal shamt: std_logic_vector (31 downto 0) := (others => '0');
	signal result: std_logic_vector (31 downto 0) := (others => '0');
	signal alu_op: alu_operation;

  begin

  dut: ALU
   			PORT MAP(
   			  alu_op,
					input_A,
					input_B,
					shamt,
					result
    			);

    test_process : process

    BEGIN

		-- test alu_add
    wait for clk_period;

			alu_op <= alu_add;
			input_A <= x"00000001"; -- (1)
			input_B <= x"00000002"; -- (2)

			wait for clk_period;
			assert result = x"00000003" report "add result should have been 3" severity error;

		-- test alu_add
    wait for clk_period;

			alu_op <= alu_add;
			input_A <= x"0000000A"; -- (10)
			input_B <= x"0000000B"; -- (11)

			wait for clk_period;
			assert result = x"00000015" report "add result should have been 21" severity error;

		-- test alu_addi
    wait for clk_period;

  		alu_op <= alu_addi;
			input_A <= x"00000030"; -- (48)
			input_B <= x"00000015"; -- (21)

			wait for clk_period;
			assert result = x"00000045" report "addi result should have been 69" severity error;

		-- test alu_addi
    wait for clk_period;

  		alu_op <= alu_addi;
			input_A <= x"000000F1"; -- (241)
			input_B <= x"000000D5"; -- (213)

			wait for clk_period;
			assert result = x"000001C6" report "addi result should have been 454" severity error;

		-- test alu_sub
    wait for clk_period;

  		alu_op <= alu_sub;
			input_A <= x"00000030"; -- (48)
			input_B <= x"00000015"; -- (21)

			wait for clk_period;
			assert result = x"0000001B" report "sub result should have been 27" severity error;

		-- test alu_sub
		wait for clk_period;

  		alu_op <= alu_sub;
			input_A <= x"00000015"; -- (21)
			input_B <= x"00000030"; -- (48)

			wait for clk_period;
			assert result = x"0000001B" report "sub result should have been -27" severity error;

		-- -- test alu_mult
		-- wait for clk_period;
		--
  	-- 	alu_op <= alu_mult;
		-- 	input_A <= x"00000009"; -- (9)
		-- 	input_B <= x"0000000A"; -- (10)
		--
		-- 	wait for clk_period;
		-- 	assert result = x"0000005A" report "mult result should have been 90" severity error;
		--
		-- -- test alu_mult
		-- wait for clk_period;
		--
  	-- 	alu_op <= alu_mult;
		-- 	input_A <= x"00001234"; -- (4660)
		-- 	input_B <= x"0000ABCD"; -- (43981)
		--
		-- 	wait for clk_period;
		-- 	assert result = x"0C374FA4" report "mult result should have been 204951460" severity error;
		--
		-- -- test alu_div
		-- wait for clk_period;
		--
  	-- 	alu_op <= alu_div;
		-- 	input_A <= x"00000064"; -- (100)
		-- 	input_B <= x"0000000A"; -- (10)
		--
		-- 	wait for clk_period;
		-- 	assert result = x"0000000A" report "div result should have been 10" severity error;
		--
		-- -- test alu_div
		-- wait for clk_period;
		--
  	-- 	alu_op <= alu_div;
		-- 	input_A <= x"00000005"; -- (5)
		-- 	input_B <= x"00000002"; -- (2)
		--
		-- 	wait for clk_period;
		-- 	assert result = x"00000002" report "div result should have been 2" severity error;

		-- test alu_slt
		wait for clk_period;

  		alu_op <= alu_slt;
			input_A <= x"00000000"; -- smaller
			input_B <= x"00000001"; --

			wait for clk_period;
			assert result = x"00000001" report "slt result should have been 1" severity error;

		-- test alu_slt
		wait for clk_period;

  		alu_op <= alu_slt;
			input_A <= x"ABCDF987"; -- bigger
			input_B <= x"ABCDF887"; --

			wait for clk_period;
			assert result = x"00000000" report "slt result should have been 0" severity error;

		-- test alu_slti
		wait for clk_period;

  		alu_op <= alu_slti;
			input_A <= x"69696969"; -- smaller
			input_B <= x"72345678"; --

			wait for clk_period;
			assert result = x"00000001" report "slti result should have been 1" severity error;

		-- test alu_slti
		wait for clk_period;

  		alu_op <= alu_slti;
			input_A <= x"ABCDF987"; -- equal
			input_B <= x"ABCDF987"; --

			wait for clk_period;
			assert result = x"00000000" report "slti result should have been 0" severity error;

		-- test alu_and
		wait for clk_period;

  		alu_op <= alu_and;
			input_A <= x"01010101"; --
			input_B <= x"10101010"; --

			wait for clk_period;
			assert result = x"00000000" report "and result should have been 0" severity error;

		-- test alu_and
		wait for clk_period;

  		alu_op <= alu_and;
			input_A <= x"FBADC111"; --
			input_B <= x"FDABC121"; --

			wait for clk_period;
			assert result = x"F0A0C101" report "and result should have been 4037067009" severity error;

		-- test alu_andi
		wait for clk_period;

  		alu_op <= alu_andi;
			input_A <= x"01010101"; --
			input_B <= x"10101010"; --

			wait for clk_period;
			assert result = x"00000000" report "andi result should have been 4037067009" severity error;

		-- test alu_andi
		wait for clk_period;

  		alu_op <= alu_andi;
			input_A <= x"FBADC111"; --
			input_B <= x"FDABC121"; --

			wait for clk_period;
			assert result = x"F0A0C101" report "andi result should have been 4037067009" severity error;

		-- test alu_or
		wait for clk_period;

  		alu_op <= alu_or;
			input_A <= x"00000000"; --
			input_B <= x"11001101"; --

			wait for clk_period;
			assert result = x"11001101" report "or result should have been 285217025" severity error;

		-- test alu_or
		wait for clk_period;

  		alu_op <= alu_or;
			input_A <= x"12345678"; --
			input_B <= x"87654321"; --

			wait for clk_period;
			assert result = x"97755779" report "or result should have been 2541049721" severity error;

		-- test alu_ori
		wait for clk_period;

  		alu_op <= alu_ori;
			input_A <= x"00000000"; --
			input_B <= x"00000010"; --

			wait for clk_period;
			assert result = x"00000010" report "ori result should have been 16" severity error;

		-- test alu_ori
		wait for clk_period;

  		alu_op <= alu_ori;
			input_A <= x"10101010"; --
			input_B <= x"01010101"; --

			wait for clk_period;
			assert result = x"11111111" report "ori result should have been 286331153" severity error;

		-- test alu_nor
		wait for clk_period;

  		alu_op <= alu_nor;
			input_A <= x"00000000"; --
			input_B <= x"00000010"; --

			wait for clk_period;
			assert result = x"11111101" report "nor result should have been 286331137" severity error;

		-- test alu_nor
		wait for clk_period;

  		alu_op <= alu_nor;
			input_A <= x"10101010"; --
			input_B <= x"01010101"; --

			wait for clk_period;
			assert result = x"00000000" report "nor result should have been 0" severity error;

		-- test alu_xor
		wait for clk_period;

  		alu_op <= alu_xor;
			input_A <= x"10101010"; --
			input_B <= x"01010101"; --

			wait for clk_period;
			assert result = x"11111111" report "xor result should have been 286331153" severity error;

		-- test alu_xor
		wait for clk_period;

  		alu_op <= alu_xor;
			input_A <= x"10101010"; --
			input_B <= x"10101010"; --

			wait for clk_period;
			assert result = x"00000000" report "xor result should have been 0" severity error;

		-- test alu_xori
		wait for clk_period;

  		alu_op <= alu_xori;
			input_A <= x"10101010"; --
			input_B <= x"01010101"; --

			wait for clk_period;
			assert result = x"11111111" report "xori result should have been 286331153" severity error;

		-- test alu_xori
		wait for clk_period;

  		alu_op <= alu_xori;
			input_A <= x"10101010"; --
			input_B <= x"10101010"; --

			wait for clk_period;
			assert result = x"00000000" report "xori result should have been 0" severity error;

		-- test alu_xori
		wait for clk_period;

  		alu_op <= alu_xori;
			input_A <= x"10101010"; --
			input_B <= x"01010101"; --

			wait for clk_period;
			assert result = x"11111111" report "xori result should have been 286331153" severity error;

		-- test alu_xori
		wait for clk_period;

  		alu_op <= alu_xori;
			input_A <= x"10101010"; --
			input_B <= x"10101010"; --

			wait for clk_period;
			assert result = x"00000000" report "xori result should have been 0" severity error;

	-- test lui (load upper IMM)
		wait for clk_period;

	  		alu_op <= alu_lui;
				input_B <= "00000000000000000000000000100111"; -- IMMEDIATE loaded to data_B

				wait for clk_period;
				assert result = "0000000001100111000000000000000" report "lui result should have been 0000000001100111000000000000000" severity error;

	-- test sll (shift logical left)
		wait for clk_period;

	  		alu_op <= alu_sll;
				input_B <= "00000000000000000000000000100111"; --  data from $t data_B
				shamt <= "00000000000000000000000000000011";

				wait for clk_period;
				assert result = "00000000000000000000000010011100" report "sll result should have been 00000000000000000000000010011100" severity error;

	-- test sll (shift logical left)
		wait for clk_period;

	  		alu_op <= alu_sll;
				input_B <= "01000000000000000000000000000000"; --  data from $t data_B
				shamt <= "00000000000000000000000000000001";

				wait for clk_period;
				assert result = "10000000000000000000000000000000" report "sll result should have been 10000000000000000000000000000000" severity error;

		-- test slr (shift logical right)
			wait for clk_period;

		  		alu_op <= alu_slr;
					input_B <= "00011000000000000000000000000000"; -- data from $t data_B
					shamt <= "00000000000000000000000000000101";

					wait for clk_period;
					assert result = "00000000110000000000000010011100" report "slr result should have been 00000000110000000000000010011100" severity error;

		-- test slr (shift logical right)
			wait for clk_period;

		  		alu_op <= alu_slr;
					input_B <= "00000000000000000000000000000100"; -- data from $t data_B
					shamt <= "00000000000000000000000000000010";

					wait for clk_period;
					assert result = "00000000000000000000000000000001" report "slr result should have been 00000000000000000000000000000001" severity error;

		-- test sra (shift right arithmetic)
			wait for clk_period;

		  		alu_op <= alu_sra;
					input_B <= "11111111111111111111111111001011"; --  data from $t data_B
					shamt <= "00000000000000000000000000000010";

					wait for clk_period;
					assert result = "11111111111111111111111111110010" report "sra result should have been 11111111111111111111111111110010" severity error;


		-- test sra (shift right arithmetic)
			wait for clk_period;

					alu_op <= alu_sra;
					input_B <= "11111111111111111111111111111111"; --  data from $t data_B
					shamt <= "00000000000000000000000000000010";

					wait for clk_period;
					assert result = "11111111111111111111111111111111" report "sra result should have been 11111111111111111111111111111111" severity error;
					
	    wait;

    END PROCESS test_process;


END;
