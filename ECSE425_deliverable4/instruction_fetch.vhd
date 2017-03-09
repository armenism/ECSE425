library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetch is
port(
	clock : in std_logic;
	reset : in std_logic;
	branch_taken : in std_logic;
	branch_address : in std_logic_vector (31 downto 0); --Might need to change
	
	instruction : out std_logic_vector (31 downto 0);
	updated_pc : out std_logic -- DOnt know whta this is
	
);
end instruction_fetch;

architecture arch of instruction_fetch is

signal pc: std_logic_vector (31 downto 0);

procedure calculate_pc (branch_taken: in std_logic; 
		    pc: in std_logic_vector (31 downto 0);
			 branch_address: in std_logic_vector (31 downto 0);
		    updated_pc: out std_logic_vector (31 downto 0)) is
begin
	
	if(branch_taken = '1') then
		updated_pc := branch_address;
	else	
		updated_pc := std_logic_vector( unsigned(pc) + to_unsigned(4, 32) );
	end if;
	
	
end calculate_pc;

begin


end arch;