--Testbench for entity registers
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

--Empty entity for testbench
ENTITY testbench_reg IS
END testbench_reg;

ARCHITECTURE behaviour OF testbench_reg IS

--Declare component to test
	COMPONENT registers IS
		PORT (
			clock				:	IN  STD_LOGIC;
			rst				:	IN  STD_LOGIC;
			reg_addr_1		:	IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_addr_2		: 	IN	 STD_LOGIC_VECTOR (4 DOWNTO 0);
			write_reg		: 	IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
			write_data		:	IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			write_enable	:  IN  STD_LOGIC;
			read_data_1		:	OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			read_data_2		:	OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	--all the input signals with initial values
	
	SIGNAL clock : STD_LOGIC := '0';
	CONSTANT clk_period : time := 10 ns;
	SIGNAL rst: STD_LOGIC := '0';
	SIGNAL reg_addr_1		: STD_LOGIC_VECTOR (4 DOWNTO 0) := "00000";
	SIGNAL reg_addr_2		: STD_LOGIC_VECTOR (4 DOWNTO 0) := "00000";
	SIGNAL write_reg		: STD_LOGIC_VECTOR (4 DOWNTO 0) := "00000";
	SIGNAL write_data		: STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '0');
	SIGNAL write_enable	: STD_LOGIC := '0';
	SIGNAL read_data_1	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL read_data_2	: STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN

    --dut => Device Under Test
    dut: registers
   			PORT MAP(
					clock,
					rst,
					reg_addr_1,
					reg_addr_2,
					write_reg,
					write_data,
					write_enable,
					read_data_1,
					read_data_2
    			);

    clock_process : PROCESS
    BEGIN
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
    END PROCESS;

    test_process : PROCESS
    BEGIN
		--reg_addr_1 and reg_addr_2 both equal write_reg ("00000")
    	wait for 2*clk_period;
		
		reg_addr_1 <= "00010";
		reg_addr_2 <= "00100";
		
		wait for clk_period;
		
		write_reg <= "00000";
		write_data <= x"AB324F30";
		
		wait for 3*clk_period;
		
		write_enable <= '1';
		
		wait for clk_period;
		
		write_reg <= "00001";
		write_data <= x"439CC901";
		
		wait for clk_period;
		
		reg_addr_1 <= "00100";
		write_reg <= "00100";
		write_data <= x"22CB20FF";
		
		wait for clk_period;
		
		write_enable <= '0';
		
		wait for clk_period;
	
	
      wait;

    END PROCESS;

 
END;
