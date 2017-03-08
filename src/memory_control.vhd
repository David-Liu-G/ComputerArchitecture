--entity name: memory_control.vhd
--entity description: 
--authors: group 3
--date: Feb 28, 2016

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY memory_control IS
GENERIC(DATA_WIDTH: INTEGER:=32;
		  RAM_SIZE : INTEGER := 32768;
		  clock_period : time := 1 ns);
PORT (clk, m_waitrequest, stall_in: IN STD_LOGIC;
      branch_taken_in: IN INTEGER;
      alu_type: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		alu_result: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		m_readbyte: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		operand2: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		reg_index_in: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_write, mem_write, mem_read, mem_to_reg, wb_stall_out, mem_stall_out: OUT STD_LOGIC;
		branch_taken_out: OUT INTEGER; 
		reg_index_out: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		m_writebyte: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		read_data: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		reg_data: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
		m_addr: OUT INTEGER RANGE 0 TO RAM_SIZE-1
		);
END memory_control;

ARCHITECTURE behavior OF memory_control IS

TYPE BUF IS ARRAY(3 downto 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL buf_block: BUF:= (others=>(others=> '0')); 

TYPE state_type IS (idle, start_read, reading, start_write, write1, write2, write3, r_termination, w_termination);
SIGNAL STATE: state_type;
SIGNAL address: STD_LOGIC_VECTOR(14 DOWNTO 0):=(others=> '0');
SIGNAL count: INTEGER RANGE 0 TO 3;

BEGIN
	address<=alu_result(14 downto 2)&"00";
	
	--write or read a word (4-byte)
	STATE_TRANS: PROCESS (CLK, m_waitrequest, stall_in, alu_type, alu_result, reg_index_in, operand2)
	BEGIN
		if(clk'event and clk='1') then
		branch_taken_out<=branch_taken_in;
		
			case STATE is
				when idle =>
					if(stall_in<='0') then
					   wb_stall_out<='0' after clock_period;
						mem_stall_out<='0' after clock_period;
						if (alu_type="10100") then --lw
							STATE<=start_read;
						elsif (alu_type="10110") then --sw
							STATE<=start_write;
						elsif (alu_type="11000" or alu_type="11001" or alu_type="11010" or alu_type="11011" or alu_type="11100" or alu_type="10101" or alu_type="10111") then --temporary cases, will be expanded later
							reg_write<='0';
							mem_to_reg<='0';
						else --arithmetic, logical, transfer, and shift ops
							if(alu_type/="UUUUU") then --eliminate undefined situation
								reg_write<='1' after clock_period;
								reg_data<=alu_result after clock_period;
								reg_index_out<=reg_index_in after clock_period;
								mem_to_reg<='0' after clock_period;
							end if;
						end if;
					else
						wb_stall_out<='1' after clock_period;
						mem_stall_out<='0' after clock_period;
					end if;
				
				when start_read =>
					count<=0;
					mem_read<='1';
					mem_write<='0';
					wb_stall_out<='1' after clock_period;
					mem_stall_out<='1';
					buf_block(count)<=m_readbyte;
					if (m_waitrequest='0') then
						STATE<=reading;
						mem_read<='0';
						count<=count+1;
					end if;
				
				when reading =>
					if (m_waitrequest='0') then
					   mem_read<='0';
						if (count<3) then
							STATE<=reading;
							count<=count+1;
						else 
							STATE<=r_termination;
						end if;
					else
						mem_read<='1';
						buf_block(count)<=m_readbyte;
					end if;
				
				when start_write =>
				   count<=0;
					mem_read<='0';
					mem_write<='1';
					wb_stall_out<='1' after clock_period;
					mem_stall_out<='1';
					m_writebyte<=operand2(7 downto 0);
					if (m_waitrequest='0') then
						STATE<=write1;
						mem_write<='0';
					end if;
					
				when write1 =>
					if (m_waitrequest='0') then
					   STATE<=write2;
						mem_write<='0';
					else
					   mem_write<='1';
						count<=1;
						m_writebyte<=operand2(15 downto 8);
					end if;
				
				when write2 =>
					if (m_waitrequest='0') then
			         STATE<=write3;
						mem_write<='0';
					else
						mem_write<='1';
						count<=2;
						m_writebyte<=operand2(23 downto 16);
					end if;
					
				when write3 =>
					if (m_waitrequest='0') then
					   STATE<=w_termination;
						mem_write<='0';
					else
						mem_write<='1';
						count<=3;
						m_writebyte<=operand2(31 downto 24);
					end if;
					
				when r_termination =>
					read_data<=buf_block(3)&buf_block(2)&buf_block(1)&buf_block(0);
					reg_index_out<=reg_index_in;
					--wb_stall_out<='0';
					--mem_stall_out<='0';
					reg_write<='1';
					mem_to_reg<='1';
					mem_read<='0';
					STATE<=idle;
					
				when w_termination =>
					read_data<=(others=>'0');
					--wb_stall_out<='0';
					--mem_stall_out<='0';
					reg_write<='0';
					mem_to_reg<='0';
					STATE<=idle;
					
			end case;
		end if;
	END PROCESS;
	
	m_addr<=to_integer(unsigned(address))+count;
	
END behavior;