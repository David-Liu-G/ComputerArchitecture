library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ifetch is
generic(
	ram_size : INTEGER := 32768;
	branch_predictor_buffer_entity_number_bit : INTEGER := 4 --range [0, 16]
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
	pc_out: OUT integer range 0 to ram_size-1;
	branch_taken: OUT std_logic;
	branch_prediction_fail: IN std_logic := '0';
	branch_prediction_succeed: IN std_logic := '0';
	branch_prediction_fail_index: IN INTEGER := 0
);
end ifetch;

architecture arch of ifetch is
	type instruction_storage is array(3 downto 0) of std_logic_vector(7 downto 0);
	type branch_predictor_storage is array (2**(branch_predictor_buffer_entity_number_bit) - 1 downto 0) of std_logic_vector(1 downto 0);
	signal instruction_table : instruction_storage := (others => (others => '0'));
	signal branch_predictor : branch_predictor_storage := (others => (others => '0'));
	signal pc : integer range 0 to ram_size-1:=4;
	signal count : integer range 0 to 5 := 0;

begin
  	clock_process: process (clock)
	variable branch_predictor_index: INTEGER:= 0;
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
				if("00"&m_readdata(31 DOWNTO 26) = X"04" OR "00"&m_readdata(31 DOWNTO 26) = X"05") then --check if this instruction is a branch
					branch_predictor_index := (pc/4 - 1) mod (2**(branch_predictor_buffer_entity_number_bit));
					IF( branch_predictor(branch_predictor_index) = "00" OR branch_predictor(branch_predictor_index) = "01") THEN
						branch_taken <= '0';	
						if (pc < 32764) then
							pc <= pc + 4; 
						end if;
					ELSE	-- "10" OR "11"
						branch_taken <= '1';
						pc <= pc + 4 + 4 * to_integer(signed(m_readdata(15 DOWNTO 0)));
						m_addr <= pc + 4 * to_integer(signed(m_readdata(15 DOWNTO 0)));
					END IF;
				elsif (pc < 32764) then
					pc <= pc + 4; --update the program counter (not branch)
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

	update_predictor: process (branch_prediction_fail, branch_prediction_succeed)
	variable success_number: INTEGER:= 0;
	variable fail_number: INTEGER:= 0;
	begin
		if(rising_edge(branch_prediction_fail)) then
			--fail_number := fail_number + 1;
			--report "fail " & integer'image(fail_number);
			CASE branch_predictor(branch_prediction_fail_index) IS
			WHEN "00" =>
				branch_predictor(branch_prediction_fail_index) <= "01";
			WHEN "01" => 
				branch_predictor(branch_prediction_fail_index) <= "10";
			WHEN "10" => 
				branch_predictor(branch_prediction_fail_index) <= "10";
			WHEN OTHERS =>
				branch_predictor(branch_prediction_fail_index) <= "11";
			END CASE;
		
		elsif(rising_edge(branch_prediction_succeed)) then
			--success_number := success_number + 1;
			--report "success " & integer'image(success_number);
			CASE branch_predictor(branch_prediction_fail_index) IS
			WHEN "00" =>
				branch_predictor(branch_prediction_fail_index) <= "00";
			WHEN "01" => 
				branch_predictor(branch_prediction_fail_index) <= "00";
			WHEN "10" => 
				branch_predictor(branch_prediction_fail_index) <= "11";
			WHEN OTHERS =>
				branch_predictor(branch_prediction_fail_index) <= "11";
			END CASE;
		end if;
	end process;
	
	
end architecture;
