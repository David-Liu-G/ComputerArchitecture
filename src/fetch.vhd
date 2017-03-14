library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic := '1';

	stall_in : in std_logic := '1';
	stall : out std_logic := '1';
	instruction : out std_logic_vector (31 downto 0);
  
  	m_waitrequest : in std_logic;
	m_readdata : in std_logic_vector (31 downto 0);
	m_read : out std_logic;
  	m_addr : out integer range 0 to ram_size-1
);
end fetch;

architecture arch of fetch is
	type instruction_storage is array(3 downto 0) of std_logic_vector(7 downto 0);
	signal instruction_table : instruction_storage := (others => (others => '0'));

	type state_type is (pre, start, fetch_init, fetch_wait, termination);
	signal state, next_state : state_type := pre;
	signal pc : integer range 0 to ram_size-1;
	signal count : integer range 0 to 5 := 0;

begin
  	clock_process: process (clock)
  	begin
    	if (clock'event and clock = '1') then
		if (reset = '1') then
			m_addr <= 0;
			pc <= 4;
			stall <= '1';
		elsif (reset = '0') then
			if (stall_in = '0') then
				instruction <= m_readdata;
				m_addr <= pc;
				if (pc < 50) then
					pc <= pc + 4;
				end if;
				stall <= '0';
			else
				instruction <= "00000000000000000000000000000000";
				stall <= '1';
			end if;
		end if;
	end if;
	end process;
end architecture;
