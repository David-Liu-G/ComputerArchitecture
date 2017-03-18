
--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
library std;
use std.textio.all;

ENTITY instruction_memory IS
	GENERIC(
		ram_size : INTEGER := 32768;
		ram_32_size : integer := 8192;
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
END instruction_memory;

ARCHITECTURE rtl OF instruction_memory IS
	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ram_block: MEM;
	SIGNAL read_address_reg: INTEGER RANGE 0 to ram_size-1;
	SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';
BEGIN
	--This is the main section of the SRAM model
	mem_process: PROCESS (clock)
	file infile : text is in "program.txt";
	variable inline : line;
	variable dataread : MEM;
	variable line_content : string (1 to 32); 
	BEGIN
		--This is a cheap trick to initialize the SRAM in simulation
		IF(now < 200 ps)THEN
			For i in 0 to ram_32_size-1 LOOP
				if (not endfile(infile)) then
					readline(infile, inline);
					read(inline, line_content);
					for j in 1 to 8 loop
						if (line_content(j) = '0') then
							ram_block(i*4+3)(8-j) <= '0';
						else
							ram_block(i*4+3)(8-j) <= '1';
						end if;
					end loop;
					for j in 9 to 16 loop
						if (line_content(j) = '0') then
							ram_block(i*4+2)(16-j) <= '0';
						else
							ram_block(i*4+2)(16-j) <= '1';
						end if;
					end loop;
					for j in 17 to 24 loop
						if (line_content(j) = '0') then
							ram_block(i*4+1)(24-j) <= '0';
						else
							ram_block(i*4+1)(24-j) <= '1';
						end if;
					end loop;
					for j in 25 to 32 loop
						if (line_content(j) = '0') then
							ram_block(i*4)(32-j) <= '0';
						else
							ram_block(i*4)(32-j) <= '1';
						end if;
					end loop;
				end if;
			END LOOP;
		end if;

	END PROCESS;
	readdata <= ram_block(address + 3) & ram_block(address + 2) & ram_block(address + 1) & ram_block(address);

END rtl;
