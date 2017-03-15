-- Entity name: data_memory
-- Description:
-- Author: group 3 
-- Date: Feb 28, 2017

LIBRARY ieee ; -- allows use of the std_logic_vector type
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all ;

ENTITY mem2 IS
GENERIC(DATA_WIDTH: INTEGER:=32;
        RAM_SIZE : INTEGER := 32768);
PORT (  clk, stall_in: IN STD_LOGIC;
        
        alu_type: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        alu_result: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	operand2: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	wb_index_in: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	is_load,need_wb, stall_out: OUT STD_LOGIC:= '0';
	current_pc_for_jal : in integer;
	wb_index_out: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
	wb_data_out: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	read_data: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	mem_forward_valid: OUT std_logic:= '0';
	exe_forward_valid: IN std_logic;
	mem_data_to_forward: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
	load_hazard: IN std_logic:= '0';
	 load_forward: OUT std_logic :='0'
	);
END mem2;

ARCHITECTURE Structure OF mem2 IS

	TYPE MEM IS ARRAY((ram_size/4)-1 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block: MEM:= (others=>(others=> '0'));

BEGIN

	--This is the main section of the SRAM model
	--mem_process: PROCESS (clk)
	--BEGIN
		----This is a cheap trick to initialize the SRAM in simulation
		--IF(now < 1 ps)THEN
			--For i in 0 to ram_size-1 LOOP
				--ram_block(i) <= std_logic_vector(to_unsigned(i,8));
			--END LOOP;
		--end if;	
	--END PROCESS;

	

	PROCESS (clk)
	begin
		if (rising_edge(clk)) then
			if (stall_in = '1') then
				stall_out <= '1';
			else 
				stall_out <= '0';

				mem_data_to_forward <= alu_result;
				mem_forward_valid <= exe_forward_valid;
				load_forward <= '0';

				if (alu_type="10100") then --lw
					read_data <= ram_block(to_integer(unsigned(alu_result)));
					wb_index_out <= wb_index_in;
					is_load <= '1';
					need_wb <= '1';
					if(load_hazard='1')then	
						mem_data_to_forward <= ram_block(to_integer(unsigned(alu_result)));
						load_forward <= '1';
					end if;
				elsif (alu_type="10110") then --sw
					ram_block(to_integer(unsigned(alu_result))) <= operand2;
					is_load <= '0';
					need_wb <= '0';
					
				elsif (alu_type="11000" or alu_type="11001" or alu_type="11010" or alu_type="11011") then 
					is_load <= '0';
					need_wb <= '0';
					
				elsif ( alu_type= "11100") then--jal
					wb_index_out <= "11111";
					wb_data_out <= std_logic_vector(to_unsigned(current_pc_for_jal,32));
					is_load <= '0';
					need_wb <= '1';
					
				elsif (alu_type="10101" or alu_type="10111") then --rservered
					is_load <= '0';
					need_wb <= '0';
					
				else --arithmetic, logical, transfer, and shift ops
					if(alu_type/="UUUUU") then --eliminate undefined situation
						wb_index_out <= wb_index_in;
						wb_data_out <= alu_result;
						is_load <= '0';
						need_wb <= '1';
						
					end if;
				end if;

				
			end if;
		end if;
	end process;
	
END Structure;