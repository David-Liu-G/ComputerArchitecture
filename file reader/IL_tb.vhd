LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY IL_tb IS
END IL_tb;

ARCHITECTURE hehavior OF IL_tb IS 
   
component memory is 
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
end component;

component instruction_loader IS
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
END component;
	
	SIGNAL clock: std_logic := '0';
	SIGNAL writedata,readdata: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL address: INTEGER RANGE 0 TO 32768-1;
	SIGNAL memwrite,memread: STD_LOGIC;
	SIGNAL waitrequest: STD_LOGIC;
	SIGNAL loading: STD_LOGIC;
		
BEGIN

	clock_process: PROCESS
		BEGIN
			loop
				clock <= NOT(clock);
				WAIT FOR 0.5 ns;
			end loop;
	END PROCESS;
	
	mem: memory
		port map(clock => clock,
			 writedata => writedata,
			 address => address,
			 memwrite => memwrite,
			 waitrequest => waitrequest,
			 readdata => readdata,
      			 memread => memread
			 );
					
	loader: instruction_loader
		port map(instuction_segment => writedata,
			 address => address,
			 memwrite => memwrite,
			 waitrequest => waitrequest,
			 loading =>loading
			 );

END hehavior;