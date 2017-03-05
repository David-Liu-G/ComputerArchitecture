library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch_tb is
end fetch_tb;

architecture behavior of fetch_tb is

component fetch is
generic(
    ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic;

	stall : out std_logic;
	instruction : out std_logic_vector (31 downto 0);
  
  	m_waitrequest : in std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_read : out std_logic;
  	m_addr : out integer range 0 to ram_size-1
);
end component;

component exe is
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
end component;

component decoder is
port(
	clock : in std_logic;

	stall : in std_logic;
	stall_out : out std_logic;

	instruction : in std_logic_vector (31 downto 0);
	
	operand1 : out std_logic_vector (31 downto 0);
	operand2 : out std_logic_vector (31 downto 0);
	instruction_type : out integer range 0 to 26
);
end component;

component memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;
	
-- test signals 
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal fetch_stall_out : std_logic;
signal instruction : std_logic_vector (31 downto 0);

signal decoder_stall_out : std_logic;
signal exe_stall_out: std_logic;

signal operand1 : std_logic_vector (31 downto 0);
signal operand2 : std_logic_vector (31 downto 0);
signal instruction_type : integer := 0;
signal shamt : std_logic_vector (4 downto 0);

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic; 

signal alu_result : std_logic_vector (31 downto 0);

begin

-- Connect the components which we instantiated above to their
-- respective signals.

fet: fetch 
port map(
    clock => clk,
    reset => reset,

    stall => fetch_stall_out,
    instruction => instruction,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_waitrequest => m_waitrequest
);

MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
);

dec: decoder
port map (
	clock => clk,

	stall => fetch_stall_out,
	stall_out => decoder_stall_out,

	instruction => instruction,
	
	operand1 => operand1,
	operand2 => operand2,
	instruction_type => instruction_type
);

ex: exe
port map(
	clock => clk,
		
	stall => decoder_stall_out,

	operand1 => operand1,
	operand2 => operand2,

	shamt => shamt,

	alu_result => alu_result,

	instruction_type => instruction_type
	
);
				
clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

-- put your tests here
--wait for mem setup
wait for 20*clk_period;

reset <= '1';
wait for clk_period;
reset <= '0';

wait until (fetch_stall_out'event and fetch_stall_out = '0');
assert (instruction = X"00432820") severity error;
report "fetch finished";
wait for 3*clk_period;
assert (to_integer(signed(alu_result)) = 64) severity error;
report "get result";

wait until (fetch_stall_out'event and fetch_stall_out = '0');
assert (instruction = X"00E83020") severity error;
report "fetch finished";
wait for 3*clk_period;
assert (to_integer(signed(alu_result)) = 66) severity error;
report "get result";

wait until (fetch_stall_out'event and fetch_stall_out = '0');
assert (instruction = X"01242022") severity error;
report "fetch finished";
wait for 3*clk_period;
assert (to_integer(signed(alu_result)) = -44) severity error;
report "get result";

wait;
end process;
	
end;
