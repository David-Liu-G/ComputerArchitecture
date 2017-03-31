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
			instruction: IN std_logic_vector(31 DOWNTO 0):=(others=>'0');
			result_in: IN std_logic_vector(31 DOWNTO 0);
			result_index_in: IN std_logic_vector(4 DOWNTO 0);
			current_PC_out: OUT integer;
			shamt: OUT std_logic_vector(4 DOWNTO 0);
			op1,op2: OUT std_logic_vector(31 DOWNTO 0);
			result_index_out: OUT std_logic_vector(4 DOWNTO 0);
			immediate_32bit: OUT std_logic_vector(31 DOWNTO 0);
			ALU_type: OUT std_logic_vector(4 DOWNTO 0);
			stall_in,wb_in: IN std_logic;
			stall_out: OUT std_logic;
			flush: IN std_logic;
			jump_addr: OUT std_logic_vector(25 DOWNTO 0);
			exe_forward_valid, mem_forward_valid: IN std_logic;
			exe_forward_index, mem_forward_index: IN std_logic_vector(4 DOWNTO 0);
			exe_data_to_forward, mem_data_to_forward: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			op1_index_out,op2_index_out: OUT std_logic_vector(4 DOWNTO 0):=(others=>'0');
			need_stall_dectection: OUT std_logic_vector(1 DOWNTO 0) :="00"; --first represents op1, second represents op2
			id_read: IN std_logic := '0';
			id_rf: OUT std_logic_vector (31 downto 0):= (others=>'0');
			branch_taken_out: OUT std_logic;
			branch_taken_in: IN std_logic
		);
END ID;

ARCHITECTURE behavior OF ID IS
	--SIGNAL op1_temp,op2_temp: std_logic_vector(31 DOWNTO 0);
	SIGNAL op1_index_temp,op2_index_temp: std_logic_vector(4 DOWNTO 0):=(others=>'0');
	SIGNAL ALU_type_temp,result_index_out_temp: std_logic_vector(4 DOWNTO 0);
	TYPE register_file IS ARRAY(register_number-1 DOWNTO 1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL registers: register_file:= (others=>(others=>'0'));
	
	BEGIN		
		ID_PROCESS: PROCESS (clk)
			
			VARIABLE immediate_16bit: std_logic_vector(15 DOWNTO 0);
			VARIABLE op1_index,op2_index:  std_logic_vector(4 DOWNTO 0):=(others=>'0');
			VARIABLE opcode,funct: std_logic_vector(7 DOWNTO 0);
			VARIABLE rs,rt,rd: std_logic_vector(4 DOWNTO 0);
			VARIABLE address: std_logic_vector(25 DOWNTO 0);
			VARIABLE result_buff: std_logic_vector(31 DOWNTO 0);
			
			--5 bit code representing each instruction

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
	                                 -- initialization of the instruction format
						stall_out <= '0';
						current_PC_out <= current_PC_in; --takes the PC from the previous stage
						shamt <= instruction(10 DOWNTO 6);
						jump_addr <= instruction(25 DOWNTO 0);
						branch_taken_out <= branch_taken_in;
						
						opcode := ("00"&instruction(31 DOWNTO 26));
						rs := instruction(25 DOWNTO 21);
						rt := instruction(20 DOWNTO 16);
						rd := instruction(15 DOWNTO 11);
						funct := ("00"&instruction(5 DOWNTO 0));
						immediate_16bit := instruction(15 DOWNTO 0);
						
                                             --op code and function code corrosponding to each instrcution

						IF (opcode = X"00" AND funct = X"20") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out_temp <=  rd; 	
							ALU_type_temp <= type_add;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"00" AND funct = X"22") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out_temp <=  rd; 
							ALU_type_temp <= type_sub;	
							need_stall_dectection <= "11";							
						ELSIF (opcode = X"08") THEN
							op1_index :=  rs;
							result_index_out_temp <=  rt; 	
							ALU_type_temp <= type_addi;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"00" AND funct = X"18") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							ALU_type_temp <= type_mult;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"00" AND funct = X"1A") THEN
							op1_index :=  rs;
							op2_index :=  rt;	
							ALU_type_temp <= type_div;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"00" AND funct = X"2A") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out_temp <=  rd; 	
							ALU_type_temp <= type_slt;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"0A") THEN
							op1_index :=  rs;
							result_index_out_temp <= rt; 
							ALU_type_temp <= type_slti;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"00" AND funct = X"24") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out_temp <=  rd; 	
							ALU_type_temp <= type_and;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"00" AND funct = X"25") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out_temp <=  rd; 
							ALU_type_temp <= type_or;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"00" AND funct = X"27") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out_temp <=  rd;  	
							ALU_type_temp <= type_nor;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"00" AND funct = X"26") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							result_index_out_temp <=  rd;  	
							ALU_type_temp <= type_xor;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"0C") THEN
							op1_index :=  rs;
							result_index_out_temp <= rt; 	
							ALU_type_temp <= type_andi;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"0D") THEN
							op1_index :=  rs;
							result_index_out_temp <= rt; 	
							ALU_type_temp <= type_ori;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"0E") THEN
							op1_index :=  rs;
							result_index_out_temp <= rt;  	
							ALU_type_temp <= type_xori;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"00" AND funct = X"10") THEN
							result_index_out_temp <=  rd;
							ALU_type_temp <= type_mfhi;
							need_stall_dectection <= "00";
						ELSIF (opcode = X"00" AND funct = X"12") THEN
							result_index_out_temp <=  rd;	
							ALU_type_temp <= type_mflo;
							need_stall_dectection <= "00";
						ELSIF (opcode = X"0F") THEN
							result_index_out_temp <=  rt;
							ALU_type_temp <= type_lui;
							need_stall_dectection <= "00";
						ELSIF (opcode = X"00" AND funct = X"00") THEN
							op1_index :=  rt; 
							result_index_out_temp <=  rd;
							ALU_type_temp <= type_sll;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"00" AND funct = X"02") THEN
							op1_index :=  rt; 
							result_index_out_temp <=  rd;
							ALU_type_temp <= type_srl;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"00" AND funct = X"03") THEN
							op1_index :=  rt; 
							result_index_out_temp <=  rd; 	
							ALU_type_temp <= type_sra;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"23") THEN
							op1_index :=  rs;
							result_index_out_temp <=  rt;
							ALU_type_temp <= type_lw;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"2B") THEN
							op1_index :=  rs;
							op2_index :=  rt;
							ALU_type_temp <= type_sw;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"04") THEN
							op1_index :=  rs;
							op2_index :=  rt;	
							ALU_type_temp <= type_beq;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"05") THEN
							op1_index :=  rs;
							op2_index :=  rt;		
							ALU_type_temp <= type_bne;
							need_stall_dectection <= "11";
						ELSIF (opcode = X"02") THEN	
							ALU_type_temp <= type_j;
							need_stall_dectection <= "00";
						ELSIF (opcode = X"00" AND funct = X"08") THEN
							op1_index :=  rs;	
							ALU_type_temp <= type_jr;
							need_stall_dectection <= "10";
						ELSIF (opcode = X"03") THEN
							ALU_type_temp <= type_jal;
							need_stall_dectection <= "00";
						ELSE 	
							--NOP (when the 32 bit code does not fit into any of those scenarios above)
							op1_index := "00000";
							op2_index := "00000";
							result_index_out_temp <=  "00000";
							ALU_type_temp <= type_add; 	
							need_stall_dectection <= "00";
						END IF;
						
					        --load the results to their respective op
						op1_index_out <= op1_index;
						op2_index_out <= op2_index;
						op1_index_temp <= op1_index;
						op2_index_temp <= op2_index;
						
                                                --sign extension
						IF(immediate_16bit(15) = '1') THEN
							immediate_32bit <= "1111111111111111" & immediate_16bit;
						ELSE
							immediate_32bit <= "0000000000000000" & immediate_16bit;
						END IF;	
						
					END IF;
			END IF;
		END PROCESS;

		PROCESS(wb_in) --takes the output from the write back stage
			BEGIN
				IF(rising_edge(wb_in) AND (NOT(result_index_in = "00000"))) THEN
					registers(to_integer(unsigned(result_index_in))) <= result_in;
				END IF;
		END PROCESS;

		
		-- handling forwarding (from the higher priority to the lower)
		-- from mem (not lw)
		-- from alu
		-- from register $0
		-- from register file (not $0)


	        --comparing the address of each op, forward to exe/mem stage if there exists dependency

		op1 <=	(others=>'0') when flush = '1' else
			exe_data_to_forward when (exe_forward_valid = '1' and exe_forward_index = op1_index_temp) else
			mem_data_to_forward when (mem_forward_valid = '1' and mem_forward_index = op1_index_temp) else
		        (others=>'0') when op1_index_temp = "00000" else
			registers(to_integer(unsigned(op1_index_temp))); 

		op2 <=	(others=>'0') when flush = '1' else
			exe_data_to_forward when (exe_forward_valid = '1' and exe_forward_index = op2_index_temp) else
			mem_data_to_forward when (mem_forward_valid = '1' and mem_forward_index = op2_index_temp) else
		        (others=>'0') when op2_index_temp = "00000" else
			registers(to_integer(unsigned(op2_index_temp)));

		
		-- flush the wrong predicted instructions into NOP 

               
	        --pass the result and instruction if the branch prediction is correct

		result_index_out <= result_index_out_temp when flush = '0' else
		        (others=>'0'); 

		ALU_type <= ALU_type_temp when flush = '0' else
		        (others=>'0'); 
												
	process(id_read)-- process to export register file into txt
	variable counter: integer := 0;
	begin
		if(rising_edge(id_read)) then
			if( not (counter =0)) then
				id_rf <= registers(counter);
			else
				id_rf <= (others=>'0');
			end if;
			counter:= counter +1;
			if(counter > 31) then
				counter :=0;
			end if;
		end if;
	end process;		
END behavior;
		
