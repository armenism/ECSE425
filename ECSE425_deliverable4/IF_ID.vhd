LIBRARY ieee;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY IF_ID IS
	PORT(	clock : in std_logic;
		InstrD_in : in std_logic_vector(31 downto 0);
		PCF_in : in std_logic_vector(31 downto 0);
		IF_ID_write : in std_logic :='1'; --For hazard dectection. Always 1 unless hazard detecttion unit changes it.
		InstrD_out : out std_logic_vector(31 downto 0);
		PCF_out : out std_logic_vector(31 downto 0)
	);
END ENTITY;

ARCHITECTURE arch OF IF_ID IS
signal temp_InstrD_in, temp_PCF_in : std_logic_vector(31 downto 0);

BEGIN

fetch: process(PCF_in, InstrD_in)
begin
	temp_InstrD_in <= InstrD_in;
	temp_PCF_in <= PCF_in;
end process fetch;

latch: process(clock)
begin
	if(rising_edge(clock) AND IF_ID_write = '1' )then
		InstrD_out <= temp_InstrD_in;
		PCF_out <= temp_PCF_in;
	end if;
end process latch;

END arch;