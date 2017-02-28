-- Entity name: data_memory
-- Description:
-- Author: group 3 
-- Date: Feb 28, 2017

LIBRARY ieee ; -- allows use of the std_logic_vector type
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all ;

ENTITY data_memory IS
GENERIC(DATA_WIDTH: INTEGER:=32;
        RAM_SIZE : INTEGER := 32768);
PORT ( clk, branch_taken_in: IN STD_LOGIC;
       instruction_type: IN INTEGER RANGE 0 TO 27;
       alu_result: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		 operand2: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		 reg_index_in: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 branch_taken_out, reg_write, mem_to_reg, waitrequest: OUT STD_LOGIC;
		 reg_index_out: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 reg_data: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		 read_data: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		 test_m_waitrequest: OUT STD_LOGIC);
END data_memory;

ARCHITECTURE Structure OF data_memory IS

COMPONENT memory_control IS
GENERIC(DATA_WIDTH: INTEGER:=32;
		  RAM_SIZE : INTEGER := 32768);
PORT (clk, branch_taken_in, m_waitrequest: IN STD_LOGIC;
      instruction_type: IN INTEGER RANGE 0 TO 27;
		alu_result: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		m_readbyte: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		operand2: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		reg_index_in: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		branch_taken_out, reg_write, mem_write, mem_read, mem_to_reg, waitrequest: OUT STD_LOGIC;
		reg_index_out: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		m_writebyte: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		read_data: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		reg_data: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		m_addr: OUT INTEGER RANGE 0 TO RAM_SIZE-1
		);
END COMPONENT;

COMPONENT memory IS
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
END COMPONENT;

SIGNAL l1, l3, l4, l7: STD_LOGIC;
SIGNAL l2, l5: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL l6: INTEGER RANGE 0 TO RAM_SIZE-1;

BEGIN

	G1: memory_control port map(clk=>l7, branch_taken_in=>branch_taken_in, m_waitrequest=>l1, instruction_type=>instruction_type, alu_result=>alu_result, m_readbyte=>l2, operand2=>operand2, reg_index_in=>reg_index_in, branch_taken_out=>branch_taken_out, reg_write=>reg_write, mem_write=>l3, mem_read=>l4, mem_to_reg=>mem_to_reg, waitrequest=>waitrequest, reg_index_out=>reg_index_out, m_writebyte=>l5, read_data=>read_data, reg_data=>reg_data, m_addr=>l6);
	G2: memory port map(clock=>l7, writedata=>l5, address=>l6, memwrite=>l3, memread=>l4, readdata=>l2, waitrequest=>l1);
	
	l7<=clk;
	test_m_waitrequest<=l1;
	
END Structure;