library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
port(
	clock : in std_logic;

	stall : in std_logic;
	stall_out : out std_logic;

	instruction : in std_logic_vector (31 downto 0);
	
	operand1 : out std_logic_vector (31 downto 0);
	operand2 : out std_logic_vector (31 downto 0);
	instruction_type : out integer range 0 to 26
);
end decoder;

architecture arch of decoder is

type register_type is array (31 downto 0) of std_logic_vector(31 downto 0);
signal registers : register_type;

begin
	registers(0) <= std_logic_vector(to_signed(0, 32));
	registers(1) <= std_logic_vector(to_signed(5, 32));
	registers(2) <= std_logic_vector(to_signed(12, 32));
	registers(3) <= std_logic_vector(to_signed(52, 32));
	registers(4) <= std_logic_vector(to_signed(32, 32));
	registers(5) <= std_logic_vector(to_signed(13, 32));
	registers(6) <= std_logic_vector(to_signed(3, 32));
	registers(7) <= std_logic_vector(to_signed(72, 32));
	registers(8) <= std_logic_vector(to_signed(-6, 32));
	registers(9) <= std_logic_vector(to_signed(-12, 32));

  	clock_process: process (clock)
	variable rs : integer;
	variable rt : integer;
	variable rd : integer;

  	begin
    	if (clock'event and clock = '1') then
      		if (stall = '1') then
			stall_out <= '1';
		else
			stall_out <= '0';
			if (instruction(31 downto 26) = "000000") then
				rs := to_integer(unsigned(instruction(25 downto 21)));
				rt := to_integer(unsigned(instruction(20 downto 16)));
				operand1 <= registers(rs);
				operand2 <= registers(rt);
				if (instruction(5 downto 0) = "100000") then
					instruction_type <= 0;
				elsif (instruction(5 downto 0) = "100010") then
					instruction_type <= 1;
				end if;
			end if;
		end if;
  	end if;
	end process;

end architecture;
