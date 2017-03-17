LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY memory_bus IS
	PORT (
		clock				: IN	STD_LOGIC;
		rst				: IN	STD_LOGIC;
		ready				: IN	STD_LOGIC;
		mem_request	: IN	STD_LOGIC; --memstage memory request signal (coming from ID)
		mem_access : OUT STD_LOGIC --Gives access to mem stage
	);
END ENTITY;


ARCHITECTURE arch OF memory_bus IS

	TYPE State_Type IS (i_mem, d_mem);

	SIGNAL current_state : State_Type;
	SIGNAL next_state 	: State_Type;

BEGIN

	--State change process
	State_change : PROCESS (clock, rst)
	BEGIN
		IF rst = '1' THEN
			current_state <= i_mem;
		ELSIF rising_edge(clock) THEN
			current_state <= next_state;
		END IF;
	END PROCESS;

	PROCESS (current_state, ready, mem_request)
	BEGIN
		CASE current_state IS
			WHEN i_mem =>
				mem_access <= '0';
				IF mem_request = '1' and ready = '1' THEN
					next_state <= d_mem;
				ELSE
					next_state <= i_mem;
				END IF;
			WHEN d_mem =>
				mem_access <= '1';
				IF mem_request = '0' AND ready = '1' THEN
					next_state <= i_mem;
				ELSE
					next_state <= d_mem;
				END IF;
		END CASE;
	END PROCESS;

END arch;
