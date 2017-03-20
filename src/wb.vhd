library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wb is
	port(clk: IN STD_LOGIC;
	     reg_index_in: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	     reg_data: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	     read_data: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	     reg_write_in, mem_to_reg, wb_stall_in: IN STD_LOGIC;
	     reg_write_out: OUT STD_LOGIC;
             reg_index_out: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
	     data_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	     );
end wb;

architecture beha of wb is
begin
	process (clk)
	begin
		if(rising_edge(clk) and wb_stall_in = '0') then
			reg_index_out <= reg_index_in;
			reg_write_out <=reg_write_in;
			if(mem_to_reg = '1') then --get data from data memory when memtoreg is enabled
				data_out <= read_data;
			else -- else get data from ALU(or register) directly
				data_out <= reg_data;
			end if;
		else 
			--set everything to 0 when clk is disabled or instruction is stalled
			reg_index_out <= (others=>'0');
			reg_write_out <= '0'; 
			data_out <= (others=>'0');
		end if;
	end process;

end beha;
