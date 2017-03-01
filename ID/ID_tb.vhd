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
-- Generated on "03/01/2017 17:05:55"
                                                            
-- Vhdl Test Bench template for design  :  ID
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY ID_vhd_tst IS
END ID_vhd_tst;
ARCHITECTURE ID_arch OF ID_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL ALU_type : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL branch_cal : STD_LOGIC;
SIGNAL clk : STD_LOGIC;
SIGNAL current_PC_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL current_PC_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL I_type : STD_LOGIC;
SIGNAL immediate_32bit : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL is_signed : STD_LOGIC;
SIGNAL load_mem : STD_LOGIC;
SIGNAL op1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL op2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL result_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL result_index_in : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL result_index_out : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL store_mem : STD_LOGIC;
SIGNAL wb_in : STD_LOGIC;
SIGNAL wb_out : STD_LOGIC;
COMPONENT ID
	PORT (
	ALU_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	branch_cal : OUT STD_LOGIC;
	clk : IN STD_LOGIC;
	current_PC_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	current_PC_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	I_type : OUT STD_LOGIC;
	immediate_32bit : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	is_signed : OUT STD_LOGIC;
	load_mem : OUT STD_LOGIC;
	op1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	op2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	result_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	result_index_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	result_index_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
	store_mem : OUT STD_LOGIC;
	wb_in : IN STD_LOGIC;
	wb_out : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : ID
	PORT MAP (
-- list connections between master ports and signals
	ALU_type => ALU_type,
	branch_cal => branch_cal,
	clk => clk,
	current_PC_in => current_PC_in,
	current_PC_out => current_PC_out,
	I_type => I_type,
	immediate_32bit => immediate_32bit,
	instruction => instruction,
	is_signed => is_signed,
	load_mem => load_mem,
	op1 => op1,
	op2 => op2,
	result_in => result_in,
	result_index_in => result_index_in,
	result_index_out => result_index_out,
	store_mem => store_mem,
	wb_in => wb_in,
	wb_out => wb_out
	);
clock : PROCESS                                               
-- variable declarations                                     
BEGIN    
	
	LOOP																
		clk	<=	'1';
		wait for 10 ns;
		clk	<=	'0';
		wait for 10 ns;
	END LOOP;
END PROCESS clock;   
                                        
always : PROCESS                                                                                   
BEGIN                                                         
        -- code executes for every event on sensitivity list
		    -- code executes for every event on sensitivity list
	wait for 10 ns;
	current_PC_in <= (others=>'1'); 
	instruction <= "00000000000000000000000000000001";
	result_in <= (others=>'1');
	result_index_in <= "00001";
	wb_in <= '1';
	
	wait for 10 ns;
	current_PC_in <= "10101010101010101010101010101010"; 
	instruction <= (others=>'1');
	result_in <= (others=>'0');
	result_index_in <= "00010";
	wb_in <= '1';
		  
WAIT;                                                        
END PROCESS always;                                          
END ID_arch;