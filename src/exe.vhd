 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exe is
port(
	clock : in std_logic;
		
	stall : in std_logic;

	operand1 : in std_logic_vector (31 downto 0);
	operand2 : in std_logic_vector (31 downto 0);

	shamt : in std_logic_vector (4 downto 0);

	alu_result : out std_logic_vector (31 downto 0);

	instruction_type : in integer range 0 to 26;
	instruction_type_out: out integer range 0 to 26
);
end exe;

architecture arch of exe is

signal hi_part : std_logic_vector (31 downto 0);
signal low_part : std_logic_vector (31 downto 0);

begin
clock_process: process (clock)
	variable sign_operand1 : integer;
	variable sign_operand2 : integer;
	variable sign_result : integer;
	variable sign_remainder: integer;

	variable big_buffer: std_logic_vector (63 downto 0);
begin
	if (clock'event and clock = '1') then
		sign_operand1 := to_integer(signed(operand1));
		sign_operand2 := to_integer(signed(operand2));
		if (stall = '1') then
			sign_result := 0;
			alu_result <= std_logic_vector(to_signed(sign_result, 32));
		elsif (instruction_type = 0) then --add
			sign_result := sign_operand1 + sign_operand2;
			alu_result <= std_logic_vector(to_signed(sign_result, 32));
		elsif (instruction_type = 1) then --sub
			sign_result := sign_operand1 - sign_operand2;
			alu_result <= std_logic_vector(to_signed(sign_result, 32));
		elsif (instruction_type = 2) then --add immediate
			sign_result := sign_operand1 + sign_operand2;
			alu_result <= std_logic_vector(to_signed(sign_result, 32));
		elsif (instruction_type = 3) then --multiply
			sign_result := sign_operand1 * sign_operand2;
			big_buffer := std_logic_vector(to_signed(sign_result, 64));
			hi_part <= big_buffer(63 downto 32);
			low_part <= big_buffer(31 downto 0);
 		elsif (instruction_type = 4) then --divide
			sign_result := sign_operand1 / sign_operand2;
			sign_remainder := sign_operand1 mod sign_operand2;
			low_part <= std_logic_vector(to_signed(sign_result, 32));
			hi_part <= std_logic_vector(to_signed(sign_remainder, 32));
		elsif (instruction_type = 5) then --set less than
			if (sign_operand1 < sign_operand2) then
				sign_result := 1;
			else
				sign_result := 0;
			end if;
			alu_result <= std_logic_vector(to_signed(sign_result, 32));
		elsif (instruction_type = 6) then --set less than immediate
			if (sign_operand1 < sign_operand2) then
				sign_result := 1;
			else
				sign_result := 0;
			end if;
			alu_result <= std_logic_vector(to_signed(sign_result, 32));
		elsif (instruction_type = 7) then --and
			alu_result <= operand1 and operand2;
		elsif (instruction_type = 8) then --or
			alu_result <= operand1 or operand2;
		elsif (instruction_type = 9) then --nor
			alu_result <= operand1 nor operand2;
		elsif (instruction_type = 10) then --xor
			alu_result <= operand1 xor operand2;
		elsif (instruction_type = 11) then --and imme
			alu_result <= operand1 and operand2;
		elsif (instruction_type = 12) then --or imme
			alu_result <= operand1 or operand2;
		elsif (instruction_type = 13) then --xor imme
			alu_result <= operand1 xor operand2;
		elsif (instruction_type = 14) then -- move from hi
			alu_result <= hi_part;
		elsif (instruction_type = 15) then -- move from low
			alu_result <= low_part;
		elsif (instruction_type = 16) then --load upper immediate
			alu_result <= operand2(15 downto 0) & "0000000000000000";
		elsif (instruction_type = 17) then --shift left logical
			sign_operand2 := to_integer(signed(operand2));
			alu_result <= std_logic_vector(signed(operand1) sll sign_operand2);
		elsif (instruction_type = 18) then --shift right logical
			sign_operand2 := to_integer(signed(operand2));
			alu_result <= std_logic_vector(signed(operand1) srl sign_operand2);
		elsif (instruction_type = 19) then --shift right arithmetic
			sign_operand2 := to_integer(signed(operand2));
			alu_result <= std_logic_vector(shift_right(signed(operand1), sign_operand2));
		elsif (instruction_type = 20) then --load word, do nothing
 
		elsif (instruction_type = 21) then -- store word

		elsif (instruction_type = 22) then --branch on equal
		elsif (instruction_type = 23) then --branch on not equal
		elsif (instruction_type = 24) then --jump
		elsif (instruction_type = 25) then --jump register
		elsif (instruction_type = 26) then --jump and link
		end if;
	end if;
end process;
	
end architecture;