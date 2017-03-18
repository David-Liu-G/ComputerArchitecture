library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

entity five_stage_tb is
end five_stage_tb;

architecture behavior of five_stage_tb is

component instruction_memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
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
	
	stall_in : in std_logic;
	stall : out std_logic;
	instruction : out std_logic_vector (31 downto 0);
  
  	m_waitrequest : in std_logic;
	m_readdata : in std_logic_vector (31 downto 0);
	m_read : out std_logic;
  	m_addr : out integer range 0 to ram_size-1;
	flush: IN std_logic;
	pc_in: IN integer range 0 to ram_size-1;
	pc_out: OUT integer range 0 to ram_size-1
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
	stall_out: OUT std_logic;
	flush: IN std_logic;
	jump_addr: OUT std_logic_vector(25 DOWNTO 0);
	exe_forward_valid, mem_forward_valid: IN std_logic;
	exe_forward_index, mem_forward_index: IN std_logic_vector(4 DOWNTO 0);
	exe_data_to_forward, mem_data_to_forward: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	op1_index_out,op2_index_out: OUT std_logic_vector(4 DOWNTO 0);
	need_stall_dectection: OUT std_logic_vector(1 DOWNTO 0);
	id_read: IN std_logic;
	id_rf: OUT std_logic_vector (31 downto 0)
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

	alu_type : in std_logic_vector(4 downto 0);
	result_index_in : in std_logic_vector(4 downto 0);
	pc_pointer : in integer;
	current_pc_for_jal : out integer;
	pc_pointer_out : out integer;
	alu_type_out: out std_logic_vector(4 downto 0);
	alu_result : out std_logic_vector (31 downto 0);
	
	operand2_out : out std_logic_vector (31 downto 0);
	stall_out : out std_logic;
	result_index_out : out std_logic_vector(4 downto 0);
	flush: OUT std_logic;
	jump_addr: IN std_logic_vector(25 DOWNTO 0);
	exe_forward_valid,load_hazard: OUT std_logic;
	load_forward: IN std_logic;
	op1_index,op2_index: IN std_logic_vector(4 DOWNTO 0);
	need_stall_dectection: IN std_logic_vector(1 DOWNTO 0);
	load_data:IN std_logic_vector (31 downto 0);
	load_index: IN std_logic_vector (4 downto 0)
);
end component;

COMPONENT mem2 IS
GENERIC(DATA_WIDTH: INTEGER:=32;
        RAM_SIZE : INTEGER := 32768);
PORT (  clk, stall_in: IN STD_LOGIC;
       
        alu_type: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        alu_result: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	operand2: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	wb_index_in: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	is_load, need_wb, stall_out: OUT STD_LOGIC:= '0';
	current_pc_for_jal : in integer;
	wb_index_out: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
	wb_data_out: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	read_data: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	mem_forward_valid: OUT std_logic:= '0';
	exe_forward_valid: IN std_logic;
	mem_data_to_forward: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	load_hazard: IN std_logic:= '0';
	load_forward: OUT std_logic :='0';
	mem2_read: IN std_logic := '0';
	mem2_memories: OUT std_logic_vector (31 downto 0):= (others=>'0')
	);
END COMPONENT;

COMPONENT wb IS
port(	     clk: IN STD_LOGIC;
	     reg_index_in: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	     reg_data: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	     read_data: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	     reg_write_in, mem_to_reg, wb_stall_in: IN STD_LOGIC;
	     reg_write_out: OUT STD_LOGIC;
             reg_index_out: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
	     data_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	     );
END COMPONENT;
	
-- test signals 
signal f_reset : std_logic := '1';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (31 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (31 downto 0);
signal m_waitrequest : std_logic;

signal f_stall : std_logic := '1';
signal f_instruction : std_logic_vector (31 downto 0);
signal f_pc_out : integer:= 0;

signal d_shamt : std_logic_vector(4 downto 0);
signal d_op1, d_op2: std_logic_vector(31 downto 0);
signal d_immediate : std_logic_vector(31 downto 0);
signal d_alu_type : std_logic_vector(4 downto 0);
signal d_stall : std_logic := '1';
signal d_pc : integer;
signal d_result_index : std_logic_vector(4 downto 0);
signal d_jump_addr: std_logic_vector(25 downto 0);
signal d_op1_index,d_op2_index: std_logic_vector(4 DOWNTO 0):="00000";
signal d_need_stall_dectection: std_logic_vector(1 DOWNTO 0):= "00";

signal e_alu_result : std_logic_vector (31 downto 0);
signal e_alu_type : std_logic_vector(4 downto 0);
signal e_operand2 : std_logic_vector(31 downto 0);
signal e_stall : std_logic;
signal e_result_index : std_logic_vector(4 downto 0);
signal e_flush: std_logic := '0';
signal e_pc_out: integer:= 0;
signal e_current_pc_for_jal: integer:= 0;
signal e_forward_valid: std_logic:= '0';

signal mem_stall : std_logic := '0';
signal mem_data_m_waitrequest : std_logic;
signal reg_write, mem_to_reg : std_logic;
signal mem_read_data : std_logic_vector(31 downto 0);
signal mem_reg_data : std_logic_vector(31 downto 0);
signal mem_reg_index_out : std_logic_vector(4 downto 0);
signal mem_forward_valid: std_logic:= '0';
signal mem_data_to_forward : std_logic_vector(31 downto 0);
signal mem_load_forward: std_logic:='0';
signal mem_load_index: std_logic_vector (4 downto 0);

signal wb_stall_in : std_logic;
signal wb_result_in : std_logic_vector(31 downto 0);
signal wb_result_index_in : std_logic_vector(4 downto 0);
signal wb_in_dump : std_logic;

signal load_hazard: std_logic:= '0';

signal mem2_read,id_read: std_logic:= '0';
signal mem2_memories,id_rf : std_logic_vector(31 downto 0);




begin

-- Connect the components which we instantiated above to their
-- respective signals.

ins_mem : instruction_memory
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

    stall_in => load_hazard,
    instruction => f_instruction,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_waitrequest => m_waitrequest,
	flush => e_flush,
	pc_in => e_pc_out,
	pc_out => f_pc_out
);

dec: ID
port map (
	clk => clk,
	current_PC_in => f_pc_out,
	instruction => f_instruction,
	result_in => wb_result_in,
	result_index_in => wb_result_index_in,
	stall_in => f_stall,
	wb_in => wb_in_dump,

	current_PC_out => d_pc,
	shamt => d_shamt,
	op1 => d_op1,
	op2 => d_op2,
	result_index_out => d_result_index,
	immediate_32bit => d_immediate,
	ALU_type => d_alu_type,
	stall_out => d_stall,
	flush => e_flush,
	jump_addr => d_jump_addr,
	exe_forward_valid => e_forward_valid, 
	mem_forward_valid => mem_forward_valid, 
	exe_forward_index => e_result_index, 
	mem_forward_index => mem_reg_index_out,
	exe_data_to_forward => e_alu_result, 
	mem_data_to_forward => mem_data_to_forward,
	op1_index_out => d_op1_index,
	op2_index_out => d_op2_index,
	need_stall_dectection => d_need_stall_dectection,
	id_read => id_read,
	id_rf => id_rf
);

ex: exe
port map(
	clock => clk,
		
	stall => d_stall,

	operand1 => d_op1,
	operand2 => d_op2,

	shamt => d_shamt,
	immediate => d_immediate,
	alu_type => d_alu_type,
	result_index_in => d_result_index,
	pc_pointer => d_pc,
	current_pc_for_jal => e_current_pc_for_jal,
	pc_pointer_out => e_pc_out,
	alu_type_out => e_alu_type,
	alu_result => e_alu_result,
	operand2_out => e_operand2,
	stall_out => e_stall,
	result_index_out => e_result_index,

	flush => e_flush,
	jump_addr => d_jump_addr,

	exe_forward_valid => e_forward_valid,
	load_hazard => load_hazard,
	load_forward => mem_load_forward,
	op1_index => d_op1_index,
	op2_index => d_op2_index,
	need_stall_dectection => d_need_stall_dectection,
	load_data => mem_data_to_forward,
	load_index => mem_reg_index_out
);

meme: mem2
PORT MAP(  clk => clk,
	stall_in => e_stall,

        alu_type => e_alu_type,
	alu_result => e_alu_result,
	operand2 => e_operand2,
	wb_index_in => e_result_index,
	need_wb => reg_write,
	is_load => mem_to_reg,
	stall_out => wb_stall_in,
	current_pc_for_jal => e_current_pc_for_jal,
	wb_index_out => mem_reg_index_out,
	wb_data_out => mem_reg_data,
	read_data => mem_read_data,
	mem_forward_valid => mem_forward_valid,
	exe_forward_valid => e_forward_valid,
	mem_data_to_forward =>mem_data_to_forward,
	load_hazard => load_hazard,
	load_forward => mem_load_forward,
	mem2_read => mem2_read,
	mem2_memories => mem2_memories
	);

writeback: wb
port map (clk =>clk,
	  reg_index_in => mem_reg_index_out,
	  reg_data => mem_reg_data,
	  read_data => mem_read_data,
	  reg_write_in => reg_write, 	  mem_to_reg => mem_to_reg, 
	  wb_stall_in => wb_stall_in,
	  reg_write_out => wb_in_dump,
          reg_index_out => wb_result_index_in,
	  data_out => wb_result_in
	  );
				
clk_process : process
begin
  clk <= '1';
  wait for clk_period/2;
  clk <= '0';
  wait for clk_period/2;
end process;

test_process : process
      file file_pointer : text;
        variable line_content : string(1 to 32);
        variable bin_value : std_logic_vector(31 downto 0);
      variable line_num, line_num1 : line;
        variable i,j : integer := 0;
        variable char : character:='0'; 

begin

-- put your tests here
--wait for mem setup
wait for 2*clk_period;
wait until (clk = '1');

f_reset <= '0';

wait for 10000 ns;
file_open(file_pointer,"register_file.txt",WRITE_MODE);      
        --We want to store binary values from 0000 to 1111 in the file.
      for i in 0 to 31 loop 
	wait until (falling_edge(clk));
	id_read <= '1';
	wait until (rising_edge(clk));
        bin_value := id_rf;
	id_read <= '0';

        --convert each bit value to character for writing to file.
        for j in 0 to 31 loop
            if(bin_value(j) = '0') then
                line_content(32-j) := '0';
            else
                line_content(32-j) := '1';
            end if; 
        end loop;
        write(line_num1,line_content); --write the line.
      writeline (file_pointer,line_num1); --write the contents into the file.
      end loop;
      file_close(file_pointer); --Close the file after writing.
        wait;


 file_open(file_pointer,"memory.txt",WRITE_MODE);      
        --We want to store binary values from 0000 to 1111 in the file.
      for i in 0 to 8191 loop 
	wait until (falling_edge(clk));
	mem2_read <= '1';
	wait until (rising_edge(clk));
        bin_value := mem2_memories;
	mem2_read <= '0';

        --convert each bit value to character for writing to file.
        for j in 0 to 31 loop
            if(bin_value(j) = '0') then
                line_content(32-j) := '0';
            else
                line_content(32-j) := '1';
            end if; 
        end loop;
        write(line_num,line_content); --write the line.
      writeline (file_pointer,line_num); --write the contents into the file.
      end loop;
      file_close(file_pointer); --Close the file after writing.
        wait;

wait;

wait;
end process;

end behavior;
