-- Copyright (C) 2016  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "02/28/2017 23:08:47"
                                                            
-- Vhdl Test Bench template for design  :  data_memory
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY data_memory_vhd_tst IS
END data_memory_vhd_tst;
ARCHITECTURE data_memory_arch OF data_memory_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL branch_taken_in : STD_LOGIC;
SIGNAL instruction_type : INTEGER RANGE 0 TO 27;
SIGNAL reg_index_in: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL operand2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL branch_taken_out : STD_LOGIC;
SIGNAL reg_index_out: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL read_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL reg_data: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL reg_write : STD_LOGIC;
SIGNAL mem_to_reg : STD_LOGIC;
SIGNAL waitrequest : STD_LOGIC;
SIGNAL test_m_waitrequest: STD_LOGIC;

COMPONENT data_memory
	PORT (
	alu_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	branch_taken_in : IN STD_LOGIC;
	branch_taken_out : OUT STD_LOGIC;
	clk : IN STD_LOGIC;
	instruction_type : IN INTEGER RANGE 0 TO 27;
	mem_to_reg : OUT STD_LOGIC;
	operand2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	reg_data: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	reg_write : OUT STD_LOGIC;
	waitrequest : OUT STD_LOGIC;
	reg_index_in: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	reg_index_out: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
	test_m_waitrequest: OUT STD_LOGIC);
END COMPONENT;
BEGIN
	i1 : data_memory
	PORT MAP (
-- list connections between master ports and signals
	alu_result => alu_result,
	branch_taken_in => branch_taken_in,
	branch_taken_out => branch_taken_out,
	clk => clk,
	instruction_type => instruction_type,
	mem_to_reg => mem_to_reg,
	operand2 => operand2,
	read_data => read_data,
	reg_data => reg_data,
	reg_write => reg_write,
	waitrequest => waitrequest,
	reg_index_in => reg_index_in,
	reg_index_out => reg_index_out,
	test_m_waitrequest => test_m_waitrequest
	);
CLOCK: PROCESS
BEGIN --50 MHZ clock
	clk <= '1';
	WAIT FOR 0.5 ns;
	LOOP 
		clk <= NOT clk;
		WAIT FOR 0.5 ns;
	END LOOP; 
END PROCESS CLOCK;
                                                       
-- code that executes only once                                                                           
always : PROCESS                                                                                 
BEGIN
   REPORT "start simulating";
	branch_taken_in<='0';
	
	--sw
	instruction_type<=22;
	reg_index_in<="00000";
	alu_result<="00000000000000000000000000000000";
	operand2<="10101010101010101010101010101010";
	WAIT FOR 46 ns;
	
	--lw
	instruction_type<=21;
	reg_index_in<="00001";
	WAIT FOR 46 ns;
	
	--add
	instruction_type<=1;
	alu_result<="01010101010101010101010101010101";
	reg_index_in<="00010";
	WAIT FOR 1 ns;
	
	--sub
	instruction_type<=2;
	alu_result<="10101010101010101010101010101010";
	reg_index_in<="00011";
	
	--REPORT "done simulating";
	
WAIT;                                                        
END PROCESS always;                                           
END data_memory_arch;
