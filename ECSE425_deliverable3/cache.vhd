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
signal c_index: std_logic_vector (4 downto 0);
signal c_block_offset: std_logic_vector (3 downto 0);
signal c_tag: std_logic_vector (3 downto 0);
signal valid: std_logic;
signal dirty: std_logic;
signal tag_success: std_logic; --implies a hit
signal word_ptr : INTEGER;

begin

-- make circuits here

-- 2D Array for storage
--There are 32 arrays of 4 words (32 bits in length)
--type words is array (3 downto 0) of std_logic_vector (31 downto 0);
--type rows is array  (31 downto 0) of std_logic_vector of words;

-- blk[133] = valid
-- blk[132] = dirty
-- blk[128-131] = tag
-- blk[96-127] = WORD1 
-- blk[64-95] = WORD2
-- blk[32-63] = WORD3
-- blk[0-31] = WORD4

type blk is array (1 downto 0) of std_logic_vector (133 downto 0);
type cache is array (31 downto 0) of std_logic_vector of blk;
signal cache_array : cache;
	
process(clock)

	begin
	--Set all signals for each clock cycle
	tag_success <= 0;
	c_block_offset <= s_addr (3 downto 0);
	c_index <= s_addr (8 downto 4 );
	c_tag <= s_addr (12 downto 9);

        case state is

   		when A =>
 			for i in cache_array range loop
      				cache_array(i,133) <= '0';
   			end loop;
			state <= B;
     			
   		when B =>
			if (s_read = '1') then
				state <= C;
				
			elsif (s_write = '1') then
				state <= F;
			end if;


		--Verifying tag state, getting valid/invalid tag, valid and dirty
      		when C => 
			
			compare_tag(c_index,c_tag,tag_success,valid,dirty);
			
			--If valid is 0 and dirty is 0 that means that its a read miss, have to read from memory
			--The block was not modified, hence safe to go and replace it 
			if (valid = '0' or dirty = '0' ) then
				state <= D;

			--If dirty is 1 that means that its a read miss, but 
			--block was modified. In order to get a block from memory and evict current one
			--we need to write back the dirty block to memory first
			elsif (dirty = '1') then
				state <= G;
			
			--Tag is matched! Return the block immediately to cpu
			elsif (tag_success = '1') then
				get_word(c_index,c_block_offset,s_readdata);
				state <= B;
			end if;

		
      		when D => 
			if (m_waitrequest = '0') then
				state <= E;

			elsif (m_waitrequest = '1') then
				state <= D;
			end if;


		when E => 
			--REPLACING BLOCK HERE AND THEN GOING BACK TO B
			state <= B;


     		when F => 
			if (tag_success = '1') then
				state <= I;
			else	
				state <= G;
			end if;

    		when G => 
			if (s_read = '1') then
				state <= D;
				
			elsif (s_write = '1') then
				state <= H;

			elsif (m_waitrequest = '1') then
				state <= G;
			end if;
		
      		when H => 
			if (m_waitrequest = '0') then
				state <= I;

			elsif (m_waitrequest = '1') then
				state <= H;
			end if;

		when I => 
			--REPLACING BLOCK HERE AND THEN GOING BACK TO B
			state <= B;

	
	end case;
end process;


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
c_index

procedure write_to_cache is
begin
--TODO

end write_to_cache;


procedure compare_tag (c_index: in std_logic_vector (4 downto 0); 
		     c_tag: in std_logic_vector (3 downto 0);
		     outcome,valid,dirty: out std_logic) is
begin
	for i in cache_array range loop
      		if (i = to_integer(unsigned(c_index))) then

			if (cache_array(133) = '1') then
				valid <= '1';
				
				if(cache_array(131 downto 128) = c_tag) then
					outcome <= '1';
				else
					outcome <='0';
				end if;

				dirty <= cache_array(132);
			else
				valid <= '0';	
				outcome <='0';
				dirty <='0';
			end if;
		end if;
	end loop;

end compare_tag;

--Getting the word from the case based on index and offset. Returning a full word
procedure get_word (c_index: in std_logic_vector (4 downto 0); 
		    c_block_offset: in std_logic_vector (3 downto 0);
		    s_readdata: out std_logic_vector (31 downto 0)) is
begin
	
	word_ptr = 127 - 32 * to_integer(unsigned(c_block_offset(3 downto 2));
	s_readdata <= cache_array(to_integer(unsigned(c_index)),(word_ptr downto word_ptr - 31));

end get_word;


end arch;