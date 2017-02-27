library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;

	fetch_waitrequest : out std_logic;
	instruction : out std_logic_vector (31 downto 0);
  
  	m_waitrequest : in std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_read : out std_logic;
  	m_addr : out integer range 0 to ram_size-1
);
end fetch;

architecture arch of fetch is
	type instruction_storage is array(3 downto 0) of std_logic_vector(7 downto 0);
	signal instruction_table : instruction_storage := (others => (others => '0'));

	type state_type is (start, fetch_init, fetch_wait, termination);
	signal state, next_state : state_type := start;
	signal pc : integer range 0 to ram_size-1 := 0;
	signal count : integer range 0 to 5 := 0;

begin
  	clock_process: process (clock)
  	begin
    	if (clock'event and clock = '1') then
      		state <= next_state;
  		end if;
	end process;
	
fetch_process: process (state, m_waitrequest)
begin
	if (state = start) then
    		m_addr <= pc;
		if (pc < 12) then
  			next_state <= fetch_init;
		else
			next_state <= start;
		end if;
  		fetch_waitrequest <= '1';
  	end if;
	
	if (state = fetch_init) then
  		m_read <= '1';
		count <= count + 1;
		next_state <= fetch_wait;
	end if;

	if (state = fetch_wait) then
  		if (m_waitrequest = '0') then
    			m_read <= '0';
			if (count < 5) then
      				instruction_table(count - 1) <= m_readdata;
				m_addr <= pc + count;
				next_state <= fetch_init;
			else
				count <= 0;
				next_state <= termination;
			end if;
		end if;
	end if;

	if (state = termination) then
		pc <= pc + 4;
		fetch_waitrequest <= '0';
		instruction <= instruction_table(3) & instruction_table(2) & instruction_table(1) & instruction_table(0);
		next_state <= start;
	end if;

end process;
end architecture;
