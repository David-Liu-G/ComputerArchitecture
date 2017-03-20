LIBRARY ieee ; -- allows use of the std_logic_vector type
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all ;

ENTITY mem IS
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
	load_forward: OUT std_logic :='0';
	mem_read: IN std_logic := '0';
	mem_memories: OUT std_logic_vector (31 downto 0):= (others=>'0')
	);
END mem;

ARCHITECTURE Structure OF mem IS

	TYPE MEM IS ARRAY((ram_size/4)-1 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block: MEM:= (others=>(others=> '0'));

BEGIN


	PROCESS (clk)
	begin
		if (rising_edge(clk)) then
			if (stall_in = '1') then
				stall_out <= '1';
			else 
				stall_out <= '0';
				
				-- set forward signal valid to notify the id
				mem_data_to_forward <= alu_result;  -- exe calculated data to forward
				mem_forward_valid <= exe_forward_valid;
				load_forward <= '0'; -- this is asserted when lw data is ready to forward

				if (alu_type="10100") then --lw
					read_data <= ram_block(to_integer(unsigned(alu_result)));
					wb_index_out <= wb_index_in;
					is_load <= '1';
					need_wb <= '1';
					if(load_hazard='1')then	
						mem_data_to_forward <= ram_block(to_integer(unsigned(alu_result))); --loaded data to forward
						load_forward <= '1';-- data ready
					end if;
				elsif (alu_type="10110") then --sw
					ram_block(to_integer(unsigned(alu_result))) <= operand2;
					is_load <= '0';
					need_wb <= '0';
					
				elsif (alu_type="11000" or alu_type="11001" or alu_type="11010" or alu_type="11011") then --beq,bne,j,jr
					is_load <= '0';
					need_wb <= '0';
					
				elsif ( alu_type= "11100") then--jal
					wb_index_out <= "11111";
					wb_data_out <= std_logic_vector(to_unsigned(current_pc_for_jal,32));
					is_load <= '0';
					need_wb <= '1';
					
				elsif (alu_type="10101" or alu_type="10111") then --reservered
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

	process(mem_read)-- process to export memory into txt
	variable counter: integer := 0;
	begin
		if(rising_edge(mem_read)) then
			mem_memories <= ram_block(counter);
			counter:= counter +1;
			if(counter > (ram_size/4)-1) then
				counter :=0;
			end if;
		end if;
	end process;
	
END Structure;