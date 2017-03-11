library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

entity instruction_fetch is
port(
	clock : in std_logic;
	CLR : in std_logic;
	PCSrcD : in std_logic;
	PCBranchD : in std_logic_vector (31 downto 0); --Might need to change
	
	InstrD : out std_logic_vector (31 downto 0);
	PCPlus4F : out std_logic_vector (31 downto 0)
	
);
end instruction_fetch;

architecture arch of instruction_fetch is

signal PCF: std_logic_vector (31 downto 0);
signal sPCPlus4F: std_logic_vector (31 downto 0);

procedure pc_4 (PC: in std_logic_vector (31 downto 0);
			signal PCPlus4F: out std_logic_vector (31 downto 0)) is
begin
	
	PCPlus4F <= std_logic_vector( unsigned(PCF) + to_unsigned(4, 32) );
	
end pc_4;


procedure calculate_pc (PCSrcD: in std_logic; 
		    PCPlus4F: in std_logic_vector (31 downto 0);
			 PCBranchD: in std_logic_vector (31 downto 0);
		    signal PCF: out std_logic_vector (31 downto 0)) is
begin
		
	if(PCSrcD = '1') then
		PCF <= PCBranchD;
	else	
		PCF <= PCPlus4F;
	end if;
	
	
end calculate_pc;


begin

process (clock)

begin

	if(rising_edge(clock)) then

		pc_4(PCF, sPCPlus4F);
		
		calculate_pc(PCSrcD, sPCPlus4F, PCBranchD, PCF);
		
		PCPlus4F <= sPCPlus4F;
		
	end if;
	
end process;




end arch;