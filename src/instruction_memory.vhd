
--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY instruction_memory IS
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
	BEGIN
		--This is a cheap trick to initialize the SRAM in simulation
		IF(now < 1 ps)THEN
			For i in 0 to ram_size-1 LOOP
				ram_block(i) <= (others=>'0');--std_logic_vector(to_unsigned(i,8));
			END LOOP;
			--add
			--ram_block(0) <= std_logic_vector(to_unsigned(32, 8));
			--ram_block(1) <= std_logic_vector(to_unsigned(40, 8));
			--ram_block(2) <= std_logic_vector(to_unsigned(67, 8));
			--ram_block(3) <= std_logic_vector(to_unsigned(0, 8));
         --add			
			--ram_block(4) <= std_logic_vector(to_unsigned(32, 8));			
			--ram_block(5) <= std_logic_vector(to_unsigned(48, 8));			
			--ram_block(6) <= std_logic_vector(to_unsigned(232, 8));			
			--ram_block(7) <= std_logic_vector(to_unsigned(0, 8));
         --sub			
			--ram_block(8) <= std_logic_vector(to_unsigned(34, 8));
			--ram_block(9) <= std_logic_vector(to_unsigned(32, 8));	
			--ram_block(10) <= std_logic_vector(to_unsigned(36, 8));	
			--ram_block(11) <= std_logic_vector(to_unsigned(1, 8));
	      --sw instruction
			--ram_block(12) <= std_logic_vector(to_unsigned(0, 8));
			--ram_block(13) <= std_logic_vector(to_unsigned(0, 8));	
			--ram_block(14) <= std_logic_vector(to_unsigned(1, 8));	
			--ram_block(15) <= std_logic_vector(to_unsigned(172, 8));
			--lw instruction
			--ram_block(16) <= std_logic_vector(to_unsigned(0, 8));
			--ram_block(17) <= std_logic_vector(to_unsigned(0, 8));	
			--ram_block(18) <= std_logic_vector(to_unsigned(10, 8));	
			--ram_block(19) <= std_logic_vector(to_unsigned(140, 8));
		--jal
			--ram_block(20) <= std_logic_vector(to_unsigned(8, 8));
			--ram_block(21) <= std_logic_vector(to_unsigned(0, 8));	
			--ram_block(22) <= std_logic_vector(to_unsigned(0, 8));	
			--ram_block(23) <= std_logic_vector(to_unsigned(12, 8));
		--j 
			--ram_block(20) <= std_logic_vector(to_unsigned(4, 8));
			--ram_block(21) <= std_logic_vector(to_unsigned(0, 8));	
			--ram_block(22) <= std_logic_vector(to_unsigned(0, 8));	
			--ram_block(23) <= std_logic_vector(to_unsigned(8, 8));
		--sub again(for testing the j)
			--ram_block(24) <= std_logic_vector(to_unsigned(34, 8));
			--ram_block(25) <= std_logic_vector(to_unsigned(32, 8));	
			--ram_block(26) <= std_logic_vector(to_unsigned(36, 8));	
			--ram_block(27) <= std_logic_vector(to_unsigned(1, 8));
			
	       		--ram_block(28) <= std_logic_vector(to_unsigned(34, 8));
			--ram_block(29) <= std_logic_vector(to_unsigned(32, 8));	
			--ram_block(30) <= std_logic_vector(to_unsigned(36, 8));	
			--ram_block(31) <= std_logic_vector(to_unsigned(1, 8));
			
			--addi $1, $0, 5,
			--ram_block(0) <= "00000101";
			--ram_block(1) <= "00000000";
			--ram_block(2) <= "00000001";
			--ram_block(3) <= "00100000";
         		--addi $2, $0, 6,	
			--ram_block(7) <= "00100000";			
			--ram_block(6) <= "00000010";			
			--ram_block(5) <= "00000000";			
			--ram_block(4) <= "00000110";
         		--addi $3, $0, 7,	
			--ram_block(11) <= "00100000";
			--ram_block(10) <= "00000011";	
			--ram_block(9) <= "00000000";	
			--ram_block(8) <= "00000111";
	     		--add $1, $2, $3,
			--ram_block(15) <= "00000000";
			--ram_block(14) <= "01000011";	
			--ram_block(13) <= "00001000";	
			--ram_block(12) <= "00100000";
			--add $4, $1, $2,
			--ram_block(19) <= "00000000";
			--ram_block(18) <= "00100010";	
			--ram_block(17) <= "00100000";	
			--ram_block(16) <= "00100000";

			--lw $1, 0($0)
			ram_block(3) <= "10001100";
			ram_block(2) <= "00000001";
			ram_block(1) <= "00000000";
			ram_block(0) <= "00000000";
         		--add $2, $1, $1
			ram_block(7) <= "00000000";			
			ram_block(6) <= "00100001";			
			ram_block(5) <= "00010000";			
			ram_block(4) <= "00100000";
		end if;

		--This is the actual synthesizable SRAM block
		IF (clock'event AND clock = '1') THEN
			IF (memwrite = '1') THEN
				ram_block(address) <= writedata(7 downto 0);
				ram_block(address) <= writedata(15 downto 8);
				ram_block(address) <= writedata(23 downto 16);
				ram_block(address) <= writedata(31 downto 24);
			END IF;
		read_address_reg <= address;
		END IF;
	END PROCESS;
	readdata <= ram_block(address + 3) & ram_block(address + 2) & ram_block(address + 1) & ram_block(address);


	--The waitrequest signal is used to vary response time in simulation
	--Read and write should never happen at the same time.
	waitreq_w_proc: PROCESS (memwrite)
	BEGIN
		IF(memwrite'event AND memwrite = '1')THEN
			write_waitreq_reg <= '0', '1' after clock_period;

		END IF;
	END PROCESS;

	waitreq_r_proc: PROCESS (memread)
	BEGIN
		IF(memread'event AND memread = '1')THEN
			read_waitreq_reg <= '0', '1' after clock_period;
		END IF;
	END PROCESS;
	waitrequest <= write_waitreq_reg and read_waitreq_reg;


END rtl;
