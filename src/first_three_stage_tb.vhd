library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch_tb is
end fetch_tb;

architecture behavior of fetch_tb is

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

component ID is
port(
	clk: IN std_logic;
	current_PC_in: IN integer;
	instruction: IN std_logic_vector(31 DOWNTO 0);
	result_in: IN std_logic_vector(31 DOWNTO 0);
	result_index_in: IN std_logic_vector(4 DOWNTO 0);
	stall_in,wb_in: IN std_logic;

	current_PC_out: OUT integer;
	shamt: OUT std_logic_vector(4 DOWNTO 0);
	op1,op2: OUT std_logic_vector(31 DOWNTO 0);
	result_index_out: OUT std_logic_vector(4 DOWNTO 0);
	immediate_32bit: OUT std_logic_vector(31 DOWNTO 0);
	ALU_type: OUT std_logic_vector(4 DOWNTO 0);
	stall_out: OUT std_logic
);
end component;

component exe is
port(
	clock : in std_logic;
		
	stall : in std_logic;

	operand1 : in std_logic_vector (31 downto 0);
	operand2 : in std_logic_vector (31 downto 0);

	shamt : in std_logic_vector (4 downto 0);
	immediate : in std_logic_vector (31 downto 0);

	alu_result : out std_logic_vector (31 downto 0);

	alu_type : in std_logic_vector(4 downto 0);
	alu_type_out: out std_logic_vector(4 downto 0)
);
end component;
	
-- test signals 
signal f_reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic;

signal f_stall : std_logic := '1';
signal f_instruction : std_logic_vector (31 downto 0);

signal pc_dump : integer;
signal result_in_dump : std_logic_vector(31 downto 0);
signal result_index_in_dump : std_logic_vector(4 downto 0);
signal wb_in_dump : std_logic;

signal d_shamt : std_logic_vector(4 downto 0);
signal d_op1, d_op2: std_logic_vector(31 downto 0);
signal d_immediate : std_logic_vector(31 downto 0);
signal d_alu_type : std_logic_vector(4 downto 0);
signal d_stall : std_logic := '1';

signal e_alu_result : std_logic_vector (31 downto 0);


begin

-- Connect the components which we instantiated above to their
-- respective signals.

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

fet: fetch 
port map(
    clock => clk,
    reset => f_reset,

    stall => f_stall,
    instruction => f_instruction,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_waitrequest => m_waitrequest
);

dec: ID
port map (
	clk => clk,
	current_PC_in => pc_dump,
	instruction => f_instruction,
	result_in => result_in_dump,
	result_index_in => result_index_in_dump,
	stall_in => f_stall,
	wb_in => wb_in_dump,

	--current_PC_out: OUT integer;
	shamt => d_shamt,
	op1 => d_op1,
	op2 => d_op2,
	--result_index_out: OUT std_logic_vector(4 DOWNTO 0);
	immediate_32bit => d_immediate,
	ALU_type => d_alu_type,
	stall_out => d_stall
);

ex: exe
port map(
	clock => clk,
		
	stall => d_stall,

	operand1 => d_op1,
	operand2 => d_op2,

	shamt => d_shamt,
	immediate => d_immediate,

	alu_result => e_alu_result,

	alu_type => d_alu_type
	--alu_type_out: out std_logic_vector(4 downto 0);
	
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

f_reset <= '1';
wait for clk_period;
f_reset <= '0';

wait until (f_stall'event and f_stall = '0');
assert (f_instruction = X"00432820") severity error;
report "fetch finished";
wait for 2.1*clk_period;
assert (to_integer(signed(e_alu_result)) = 64) severity error;
report "get result";

wait until (f_stall'event and f_stall = '0');
assert (f_instruction = X"00E83020") severity error;
report "fetch finished";
wait for 2.1*clk_period;
assert (to_integer(signed(e_alu_result)) = 66) severity error;
report "get result";

wait until (f_stall'event and f_stall = '0');
assert (f_instruction = X"01242022") severity error;
report "fetch finished";
wait for 2.1*clk_period;
assert (to_integer(signed(e_alu_result)) = -44) severity error;
report "get result";

wait;
end process;
	
end;

