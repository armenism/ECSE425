library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768;
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic; 
    
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is

-- declare signals here
-- I dont know if we actually need all these signals
signal index: std_logic_vector (4 downto 0);
signal block_offset: std_logic_vector (1 downto 0);
signal tag: std_logic_vector (5 downto 0);
signal valid: std_logic;
signal dirty: std_logic;
signal tag_success: std_logic;

begin

-- make circuits here

--Compares the adress tag to the tag in cache (untested)
procedure compare_tag (tag_adress, tag_cache: in std_logic_vector (5 downto 0); outcome: out std_logic) is 
begin
	
	--Might need to do bitwise comparison
	if (tag_adress = tag_cache)
	{
		outcome <= '1';
	}
	else 
	{
		outcome = '0'
	}
	end if;
	
end procedure;

	
-- 2D Array for storage
--There are 32 arrays of 4 words (32 bits in length)
type words is array (3 downto 0) of std_logic_vector (31 downto 0);
type rows is array  (31 downto 0) of std_logic_vector of words;
	
process(clock)
{
	--Set all signals for each clock cycle
	tag_success <= 0;
	block_offset <= s_addr (1 downto 0);
	index <= s_addr (6 downto 2);
	tag <= s_addr (12 downto 7);
	dirty <= s_addr (13);
	valid <= s_addr (14);
	
	if(s_read)
	{
		
	}
	
	if(s_write)
	{
		
	}
}

procedure check_dirty_bits is
begin
--TODO

end check_dirty_bits;

procedure read_main_mem is
begin
--TODO

end read_main_mem;

procedure write_main_mem is
begin
--TODO

end write_main_mem;


procedure write_to_cache is
begin
--TODO

end write_to_cache;

procedure read_from_cache is
begin
--TODO

end read_from_cache;

end arch;