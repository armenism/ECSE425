--Registers for the ID stage
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY registers IS
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
END registers;

ARCHITECTURE arch OF registers IS

	TYPE MEM_TYPE IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL sram : MEM_TYPE:= (others => (others => '0')); --use a high-speed static RAM for registers
	
BEGIN

	

	-- 32-register file
	Registers : PROCESS (reg_addr_1, reg_addr_2)--(clock)
	BEGIN
		IF reg_addr_1'event OR reg_addr_2'event THEN
			--Hardwire register 0 to zero
			sram(0) <= x"00000000";
			
			if rst = '1' then
            FOR i IN 0 TO 31 LOOP
                sram(i) <= "00000000000000000000000000000000";
            END LOOP;
			else
				read_data_1 <= sram(to_integer(unsigned(reg_addr_1)));
		  
				read_data_2 <= sram(to_integer(unsigned(reg_addr_2)));
           
				--Write to register if write enable is 1, and the register we are writing to isn't the 0 register
				IF (write_enable = '1') AND (write_reg /= "00000")  THEN
				
					sram(TO_INTEGER(UNSIGNED(write_reg))) <= write_data;
					
					--bypass code (when writing and reading at the same time)
					IF reg_addr_1 = write_reg THEN
						read_data_1 <= write_data;
					END IF;
					IF reg_addr_2 = write_reg THEN
						read_data_2 <= write_data;
					END IF;
				END IF;
			end if;
		END IF;
	END PROCESS;
	
END arch;