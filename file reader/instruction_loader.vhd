LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use STD.textio.all; --Dont forget to include this library for file operations.

ENTITY instruction_loader IS
	GENERIC(
		ram_size : INTEGER := 32768;
		clock_period : time := 1 ns
	);

	Port(	instuction_segment: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			address: OUT INTEGER RANGE 0 TO ram_size-1;
			memwrite: OUT STD_LOGIC;
			waitrequest: IN STD_LOGIC;
			loading: OUT STD_LOGIC
	);
END instruction_loader;

ARCHITECTURE beha OF instruction_loader IS 

    
BEGIN
   --Read process
    process 
        file file_pointer : text;
        variable line_content : string(1 to 32);
		  variable line_num : line;
        variable j : integer := 0;
        variable char : character:='0'; 
		  variable bin_value : std_logic_vector(31 downto 0):=(others=>'0');
		  variable address_pointer : integer:= 0;
   begin
	loading <= '1';
        --Open the file read.txt from the specified location for reading(READ_MODE).
      file_open(file_pointer,"program.txt",READ_MODE);    
      while not endfile(file_pointer) loop --till the end of file is reached continue.
      readline (file_pointer,line_num);  --Read the whole line from the file
        --Read the contents of the line from  the file into a variable.
      READ (line_num,line_content); 
        --For each character in the line convert it to binary value.
        --And then store it in a signal named 'bin_value'.
        for j in 1 to 32 loop        
            char := line_content(j);
            if(char = '0') then
                bin_value(32-j) := '0';
            else
                bin_value(32-j) := '1';
            end if; 		
        end loop; 
	
				memwrite <= '1', '0' after 2*clock_period;
				instuction_segment <= bin_value(7 DOWNTO 0);
				address <= address_pointer;
				
				wait until (rising_edge(waitrequest));				
				memwrite <= '1', '0' after 2*clock_period;
				instuction_segment <= bin_value(15 DOWNTO 8);
				address_pointer := address_pointer + 1;
				address <= address_pointer;
				
				wait until (rising_edge(waitrequest));
				memwrite <= '1', '0' after 2*clock_period;
				instuction_segment <= bin_value(23 DOWNTO 16);
				address_pointer := address_pointer + 1;
				address <= address_pointer;
	
				wait until (rising_edge(waitrequest));
				memwrite <= '1', '0' after 2*clock_period;
				instuction_segment <= bin_value(31 DOWNTO 24);
				address_pointer := address_pointer + 1;
				address <= address_pointer;
				
				wait until (rising_edge(waitrequest));
				address_pointer := address_pointer + 1;  
      end loop;
      file_close(file_pointer);  --after reading all the lines close the file. 
		loading <='0';
        wait;
    end process;

end beha;