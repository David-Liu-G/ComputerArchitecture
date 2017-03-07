LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ID IS
	GENERIC (
				register_number : INTEGER :=32
				);
			
	PORT( 
			clk: IN std_logic;
			current_PC_in: IN integer;
			instruction: IN std_logic_vector(31 DOWNTO 0);
			result_in: IN std_logic_vector(31 DOWNTO 0);
			result_index_in: IN std_logic_vector(4 DOWNTO 0);
			current_PC_out: OUT integer;
			shamt: OUT std_logic_vector(4 DOWNTO 0);
			op1,op2: OUT std_logic_vector(31 DOWNTO 0);
			result_index_out: OUT std_logic_vector(4 DOWNTO 0);
			immediate_32bit: OUT std_logic_vector(31 DOWNTO 0);
			ALU_type: OUT std_logic_vector(4 DOWNTO 0);
			stall_in,wb_in: IN std_logic;
			stall_out: OUT std_logic
		);
END ID;

ARCHITECTURE behavior OF ID IS
	TYPE register_file IS ARRAY(register_number-1 DOWNTO 1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL registers: register_file:= (X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",
	                                   X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",
	                                   X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",std_logic_vector(to_signed(-12, 32)),std_logic_vector(to_signed(-6, 32)),
	                                   std_logic_vector(to_signed(72, 32)),std_logic_vector(to_signed(3, 32)),std_logic_vector(to_signed(13, 32)),std_logic_vector(to_signed(32, 32)),std_logic_vector(to_signed(52, 32)),std_logic_vector(to_signed(12, 32)),std_logic_vector(to_signed(5, 32)));
	
	BEGIN		
		ID_PROCESS: PROCESS (clk)
			
			VARIABLE immediate_16bit: std_logic_vector(15 DOWNTO 0);
			VARIABLE op1_index,op2_index:  std_logic_vector(4 DOWNTO 0);
			VARIABLE opcode,funct: std_logic_vector(7 DOWNTO 0);
			VARIABLE rs,rt,rd: std_logic_vector(4 DOWNTO 0);
			VARIABLE address: std_logic_vector(25 DOWNTO 0);
			VARIABLE op1_buff,op2_buff,result_buff: std_logic_vector(31 DOWNTO 0);
			
			CONSTANT type_add: std_logic_vector(4 DOWNTO 0):= 			"00000";
			CONSTANT type_sub: std_logic_vector(4 DOWNTO 0):= 			"00001";
			CONSTANT type_addi: std_logic_vector(4 DOWNTO 0):= 		"00010";
			CONSTANT type_mult: std_logic_vector(4 DOWNTO 0):= 		"00011";
			CONSTANT type_div: std_logic_vector(4 DOWNTO 0):= 			"00100";
			CONSTANT type_slt: std_logic_vector(4 DOWNTO 0):= 			"00101";
			CONSTANT type_slti: std_logic_vector(4 DOWNTO 0):=			"00110";
			CONSTANT type_and: std_logic_vector(4 DOWNTO 0):= 			"00111";
			CONSTANT type_or: std_logic_vector(4 DOWNTO 0):= 			"01000";
			CONSTANT type_nor: std_logic_vector(4 DOWNTO 0):= 			"01001";
			CONSTANT type_xor: std_logic_vector(4 DOWNTO 0):= 			"01010";
			CONSTANT type_andi: std_logic_vector(4 DOWNTO 0):= 		"01011";
			CONSTANT type_ori: std_logic_vector(4 DOWNTO 0):= 			"01100";
			CONSTANT type_xori: std_logic_vector(4 DOWNTO 0):=			"01101";
			CONSTANT type_mfhi: std_logic_vector(4 DOWNTO 0):= 		"01110";
			CONSTANT type_mflo: std_logic_vector(4 DOWNTO 0):= 		"01111";
			CONSTANT type_lui: std_logic_vector(4 DOWNTO 0):= 			"10000";
			CONSTANT type_sll: std_logic_vector(4 DOWNTO 0):= 			"10001";
			CONSTANT type_srl: std_logic_vector(4 DOWNTO 0):= 			"10010";
			CONSTANT type_sra: std_logic_vector(4 DOWNTO 0):= 			"10011";
			CONSTANT type_lw: std_logic_vector(4 DOWNTO 0):= 			"10100";
			CONSTANT type_reserved1: std_logic_vector(4 DOWNTO 0):= 	"10101";
			CONSTANT type_sw: std_logic_vector(4 DOWNTO 0):=  			"10110";
			CONSTANT type_reserved2: std_logic_vector(4 DOWNTO 0):= 	"10111";
			CONSTANT type_beq: std_logic_vector(4 DOWNTO 0):= 			"11000";
			CONSTANT type_bne: std_logic_vector(4 DOWNTO 0):= 			"11001";
			CONSTANT type_j: std_logic_vector(4 DOWNTO 0):= 			"11010";
			CONSTANT type_jr: std_logic_vector(4 DOWNTO 0):= 			"11011";
			CONSTANT type_jal: std_logic_vector(4 DOWNTO 0):= 			"11100";

			
			BEGIN
				IF (rising_edge(clk)) THEN
					IF(stall_in = '1') THEN
						stall_out <= '1';
					else
					
						stall_out <= '0';
						current_PC_out <= current_PC_in;
						shamt <= instruction(10 DOWNTO 6);
						
						opcode := ("00"&instruction(31 DOWNTO 26));
						rs := instruction(25 DOWNTO 21);
						rt := instruction(20 DOWNTO 16);
						rd := instruction(15 DOWNTO 11);
						funct := ("00"&instruction(5 DOWNTO 0));
						immediate_16bit := instruction(15 DOWNTO 0);
						address := instruction(25 DOWNTO 0);
						
						IF (opcode = X"00" AND funct = X"20") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out <=  rd; 	
							ALU_type <= type_add;
						ELSIF (opcode = X"00" AND funct = X"22") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out <=  rd; 
							ALU_type <= type_sub;
						ELSIF (opcode = X"08") THEN
							op1_index :=  rs;
							result_index_out <=  rt; 	
							ALU_type <= type_addi;
						ELSIF (opcode = X"00" AND funct = X"18") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							ALU_type <= type_mult;
						ELSIF (opcode = X"00" AND funct = X"1A") THEN
							op1_index :=  rs;
							op2_index :=  rt;	
							ALU_type <= type_div;
						ELSIF (opcode = X"00" AND funct = X"2A") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out <=  rd; 	
							ALU_type <= type_slt;
						ELSIF (opcode = X"0A") THEN
							op1_index :=  rs;
							result_index_out <= rt; 
							ALU_type <= type_slti;
						ELSIF (opcode = X"00" AND funct = X"24") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out <=  rd; 	
							ALU_type <= type_and;
						ELSIF (opcode = X"00" AND funct = X"25") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out <=  rd; 
							ALU_type <= type_or;
						ELSIF (opcode = X"00" AND funct = X"27") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out <=  rd;  	
							ALU_type <= type_nor;
						ELSIF (opcode = X"00" AND funct = X"26") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out <=  rd;  	
							ALU_type <= type_xor;
						ELSIF (opcode = X"0C") THEN
							op1_index :=  rs;
							result_index_out <= rt; 	
							ALU_type <= type_andi;
						ELSIF (opcode = X"0D") THEN
							op1_index :=  rs;
							result_index_out <= rt; 	
							ALU_type <= type_ori;
						ELSIF (opcode = X"0E") THEN
							op1_index :=  rs;
							result_index_out <= rt;  	
							ALU_type <= type_xori;
						ELSIF (opcode = X"00" AND funct = X"10") THEN
							result_index_out <=  rd;
							ALU_type <= type_mfhi;
						ELSIF (opcode = X"00" AND funct = X"12") THEN
							result_index_out <=  rd;	
							ALU_type <= type_mflo;
						ELSIF (opcode = X"0F") THEN
							result_index_out <=  rt;
							ALU_type <= type_lui;
						ELSIF (opcode = X"00" AND funct = X"00") THEN
							op1_index :=  rt; 
							result_index_out <=  rd;
							ALU_type <= type_sll;
						ELSIF (opcode = X"00" AND funct = X"02") THEN
							op1_index :=  rt; 
							result_index_out <=  rd;
							ALU_type <= type_srl;
						ELSIF (opcode = X"00" AND funct = X"03") THEN
							op1_index :=  rt; 
							result_index_out <=  rd; 	
							ALU_type <= type_sra;
						ELSIF (opcode = X"23") THEN
							op1_index :=  rs;
							result_index_out <=  rt;
							ALU_type <= type_lw;
						ELSIF (opcode = X"2B") THEN
							op1_index :=  rt;
							result_index_out <=  rs;
							ALU_type <= type_sw;
						ELSIF (opcode = X"04") THEN
							op1_index :=  rs;
							op2_index :=  rt;	
							ALU_type <= type_beq;
						ELSIF (opcode = X"05") THEN
							op1_index :=  rs;
							op2_index :=  rt;		
							ALU_type <= type_bne;
						ELSIF (opcode = X"02") THEN	
							ALU_type <= type_j;
						ELSIF (opcode = X"00" AND funct = X"08") THEN
							op1_index :=  rs;	
							ALU_type <= type_jr;
						ELSIF (opcode = X"03") THEN
							ALU_type <= type_jal;
						END IF;
					

						IF((op1_index = "00000") AND (op2_index = "00000")) THEN
							op1_buff := (others => '0');
							op2_buff := (others => '0');
						ELSIF (op1_index = "00000") THEN
							op1_buff := (others => '0');
							op2_buff := registers(to_integer(unsigned(op2_index)));
						ELSIF (op2_index = "00000") THEN 
							op1_buff := registers(to_integer(unsigned(op1_index)));
							op2_buff := (others => '0');
						ELSE 
							op1_buff := registers(to_integer(unsigned(op1_index)));
							op2_buff := registers(to_integer(unsigned(op2_index)));
						END IF;	
						
						op1 <= op1_buff;
						op2 <= op2_buff;
						IF((wb_in = '1') AND (NOT(result_index_in = "00000"))) THEN
						  registers(to_integer(unsigned(result_index_in))) <= result_in;
						END IF;
						
						IF(immediate_16bit(15) = '1') THEN
							immediate_32bit <= "1111111111111111" & immediate_16bit;
						ELSE
							immediate_32bit <= "0000000000000000" & immediate_16bit;
						END IF;	
						
					END IF;
			END IF;
		END PROCESS;
			
END behavior;
		