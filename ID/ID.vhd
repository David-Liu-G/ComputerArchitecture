LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ID IS
	GENERIC (
				register_number : INTEGER :=32
				);
			
	PORT( 
			clk: IN std_logic;
			current_PC_in: IN std_logic_vector(31 DOWNTO 0);
			instruction: IN std_logic_vector(31 DOWNTO 0);
			result_in: IN std_logic_vector(31 DOWNTO 0);
			result_index_in: IN std_logic_vector(4 DOWNTO 0);
			wb_in: IN std_logic;
			current_PC_out: OUT std_logic_vector(31 DOWNTO 0);
			op1,op2: OUT std_logic_vector(31 DOWNTO 0);
			result_index_out: OUT std_logic_vector(4 DOWNTO 0);
			immediate_32bit: OUT std_logic_vector(31 DOWNTO 0);
			branch_cal,I_type,store_mem,load_mem,wb_out: OUT std_logic;
			ALU_type: OUT std_logic_vector(1 DOWNTO 0);
			is_signed: OUT std_logic
		);
END ID;

ARCHITECTURE behavior OF ID IS
	TYPE register_file IS ARRAY(register_number-1 DOWNTO 1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL registers: register_file;
	SIGNAL op1_index,op2_index: std_logic_vector(4 DOWNTO 0);
	SIGNAL immediate_16bit: std_logic_vector(15 DOWNTO 0);
	SIGNAL instruction_signal: std_logic_vector(31 DOWNTO 0);
	SIGNAL is_signed_signal: std_logic;
	
	BEGIN
		
		shift_register: PROCESS (clk)
			BEGIN
				IF (rising_edge(clk)) THEN
					current_PC_out <= current_PC_in;
					instruction_signal <= instruction;
				END IF;
		END PROCESS;
		
		ops: PROCESS (op1_index,op2_index)
			BEGIN 
			IF ((op1_index = "00000") AND (NOT(op2_index = "00000"))) THEN
				op1 <= (others => '0');
				op2 <= registers(to_integer(unsigned(op2_index)));
			ELSIF ((NOT(op1_index = "00000")) AND (op2_index = "00000")) THEN 
				op1 <= registers(to_integer(unsigned(op1_index)));
				op2 <= (others => '0');
			ELSE 
				op1 <= registers(to_integer(unsigned(op1_index)));
				op2 <= registers(to_integer(unsigned(op2_index)));
			END IF;
		END PROCESS;
		
		instruction_decoder: PROCESS (instruction_signal)
			BEGIN
				-- DECODER LOGIC THERE
				CASE instruction_signal IS
					-- NOP
					WHEN (others=>'0') =>
						op1_index <= (others=>'0');
						op2_index <= (others=>'0');
						result_index_out <= (others=>'0');
						immediate_16bit <= (others=>'0');
						branch_cal <= '0';
						I_type <= '0';
						store_mem <= '0';
						load_mem <= '0';
						wb_out <= '0';
						ALU_type <= "00";
						is_signed_signal <= '1';
					-- TEST
					WHEN others =>
						op1_index <= "00001";
						op2_index <= "00010";
						result_index_out <= "00011";
						immediate_16bit <= (others=>'0');
						immediate_16bit(0) <= '1';
						branch_cal <= '1';
						I_type <= '1';
						store_mem <= '1';
						load_mem <= '1';
						wb_out <= '1';
						ALU_type <= "11";
						is_signed_signal <= '1';
				END CASE;	
			END PROCESS;
		is_signed <= is_signed_signal;
		
		wb: PROCESS (wb_in)
			BEGIN
				IF((wb_in = '1') AND (NOT(result_index_in = "00000"))) THEN
					registers(to_integer(unsigned(result_index_in))) <= result_in;
				END IF;
			END PROCESS;
			
		sign_extend: PROCESS (immediate_16bit)
			BEGIN
				IF((is_signed_signal = '1') AND (immediate_16bit(15) = '1')) THEN
						immediate_32bit <= "1111111111111111" & immediate_16bit;
					ELSE
						immediate_32bit <= "0000000000000000" & immediate_16bit;
				END IF;			
			END PROCESS;
			
END behavior;
		