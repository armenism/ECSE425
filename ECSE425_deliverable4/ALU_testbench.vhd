
--Testbench for the ALU

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signal_types.all;


entity ALU_testbench is
end ALU_testbench;

architecture behaviour of ALU_testbench is

--Declare component to test
	component ALU is
		port (
		  ALU_OPERATION: in alu_operation;
			data_A: in	std_logic_vector (31 downto 0);
			data_B: 	in	 std_logic_vector (31 downto 0);
			shamt	:  in  std_logic_vector (31 downto 0);
			RESULT:  out std_logic_vector (31 downto 0)
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
      
    wait for clk_period;
    
		alu_op <= alu_add;
		
		input_A <= x"00000001"; -- (1)
		input_B <= x"00000002"; -- (2)
		
		
		wait for clk_period;
		
		assert result = x"00000003" report "result should have been 3" severity error;
    
    wait for clk_period;
    
		alu_op <= alu_add;
		
		input_A <= x"0000000A"; -- (10)
		input_B <= x"0000000B"; -- (11)
		
		
		wait for clk_period;
		
		assert result = x"00000015" report "result should have been 21" severity error;

    wait for clk_period;
    
  		alu_op <= alu_addi;
		
		input_A <= x"00000030"; -- (48)
		input_B <= x"00000015"; -- (21)
		
		
		wait for clk_period;
		
		assert result = x"00000045" report "result should have been 69" severity error;
		
    wait for clk_period;
    
  		alu_op <= alu_sub;
		
		input_A <= x"00000030"; -- (48)
		input_B <= x"00000015"; -- (21)
		
		
		wait for clk_period;
		
		assert result = x"0000001B" report "result should have been 27" severity error;
		
		
		wait for clk_period;
    
  		alu_op <= alu_sub;
		
		input_A <= x"00000015"; -- (21)
		input_B <= x"00000030"; -- (48)
		
		
		wait for clk_period;
		
		assert result = x"0000001B" report "result should have been -27" severity error;

		
    wait;

    END PROCESS test_process;


END;