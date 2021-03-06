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
  	m_addr : out integer range 0 to ram_size-1;
	flush: IN std_logic;
	pc_in: IN integer range 0 to ram_size-1;
	pc_out: OUT integer range 0 to ram_size-1
);
end fetch;

architecture arch of fetch is
	type instruction_storage is array(3 downto 0) of std_logic_vector(7 downto 0);
	signal instruction_table : instruction_storage := (others => (others => '0'));
	signal pc : integer range 0 to ram_size-1:=4;
	signal count : integer range 0 to 5 := 0;

begin
  	clock_process: process (clock)
  	begin
	

    	if (clock'event and clock = '1') then
		if (reset = '1') then --reset the instruction
			m_addr <= 0;
			pc <=4;
			stall <= '1';
		elsif (reset = '0') then --takes the current instruction and the current program counter
			if (stall_in = '0') then
				instruction <= m_readdata;
				m_addr <= pc;
				pc_out <= pc - 4;
				if (pc < 32764) then
				pc <= pc + 4; --update the program counter
				end if;
				stall <= '0';
			else --stall and clear the instruction
				instruction <= "00000000000000000000000000000000";
				stall <= '1';
			end if;
		end if;
	

	elsif (clock'event and clock = '0') then -- handle flush(jump and branch here)
		if (reset = '0' and flush = '1') then -- branch predict taken fails
			pc <= pc_in ;
			m_addr <= pc_in - 4; 
			instruction <= (others=>'0'); --change the instruction into NOP
		end if;
	end if;

	end process;
	
	
	
 	
	--re_addressing: process (flush)
	--begin
		--if(flush'event and flush = '1') then
			--pc <= pc_in;
		--end if;
	--end process;
end architecture;
