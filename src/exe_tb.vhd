library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exe_tb is
end exe_tb;

architecture behavior of exe_tb is

component exe is
port(
	clock : in std_logic;
		
	stall : in std_logic;

	operand1 : in std_logic_vector (31 downto 0);
	operand2 : in std_logic_vector (31 downto 0);

	shamt : in std_logic_vector (4 downto 0);

	alu_result : out std_logic_vector (31 downto 0);

	instruction_type : in integer range 0 to 27;
	instruction_type_out: out integer range 0 to 27
);
end component;
	
-- test signals 

signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal operand1 : std_logic_vector (31 downto 0);
signal operand2 : std_logic_vector (31 downto 0);
signal alu_result : std_logic_vector (31 downto 0);

signal instruction_type : integer range 0 to 27;

signal stall : std_logic;
signal shamt : std_logic_vector (4 downto 0);

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: exe 
port map(
    	clock => clk,
	operand1 => operand1,
	operand2 => operand2,
	alu_result => alu_result,
	instruction_type => instruction_type,
	stall => stall,
	shamt => shamt
);

clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
variable sign_result : integer;

begin
--test add
wait for clk_period;
operand1 <= std_logic_vector(to_signed(3, 32));
operand2 <= std_logic_vector(to_signed(5, 32));
instruction_type <= 1;

wait for clk_period;

sign_result := to_integer(signed(alu_result));
assert (sign_result = 8) severity error;
report "finished 1";

--test sub
operand1 <= std_logic_vector(to_signed(75, 32));
operand2 <= std_logic_vector(to_signed(120, 32));
instruction_type <= 2;

wait for clk_period;

sign_result := to_integer(signed(alu_result));
assert (sign_result = -45) severity error;
report "fnished 2";

wait;
end process;
	
end;
