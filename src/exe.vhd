library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exe is
generic(
	branch_predictor_buffer_entity_number_bit : INTEGER := 4 --range [1, 16]
);
port(
	clock : in std_logic;
		
	stall : in std_logic;

	operand1 : in std_logic_vector (31 downto 0);
	operand2 : in std_logic_vector (31 downto 0);

	shamt : in std_logic_vector (4 downto 0);
	immediate : in std_logic_vector (31 downto 0);

	alu_type : in std_logic_vector(4 downto 0);
	
	result_index_in : in std_logic_vector(4 downto 0);

	pc_pointer : in integer:=0;
	current_pc_for_jal : out integer:=0;
	pc_pointer_out : out integer:=0;

	alu_type_out: out std_logic_vector(4 downto 0);
	alu_result : out std_logic_vector (31 downto 0);
	
	operand2_out : out std_logic_vector (31 downto 0);
	stall_out : out std_logic;
	result_index_out : out std_logic_vector(4 downto 0);
	flush: OUT std_logic:= '0';
	jump_addr: IN std_logic_vector(25 DOWNTO 0);
	exe_forward_valid,load_hazard: OUT std_logic:= '0';
	load_forward: IN std_logic;
	op1_index,op2_index: IN std_logic_vector(4 DOWNTO 0):=(others=>'0');
	need_stall_dectection: IN std_logic_vector(1 DOWNTO 0) := "00"; --first represents op1, second represents op2
	load_data:IN std_logic_vector (31 downto 0);
	load_index: IN std_logic_vector (4 downto 0);
	branch_taken: IN std_logic := '0';
	branch_prediction_fail: OUT std_logic := '0';
	branch_prediction_succeed: OUT std_logic := '0';
	branch_prediction_fail_index: OUT INTEGER := 0
);
end exe;

architecture arch of exe is

signal hi_part : std_logic_vector (31 downto 0);
signal low_part : std_logic_vector (31 downto 0);
signal op1_index_delay,op2_index_delay,alu_type_delay, result_index_in_delay: std_logic_vector (4 downto 0):=(others=>'0');

begin
clock_process: process (clock, load_forward)
	variable sign_operand1 : integer;
	variable sign_operand2 : integer;
	variable sign_result : integer;
	variable sign_remainder: integer;
	variable sign_immediate : integer;
	variable sign_shamt : integer;
	
	variable instruction_type : integer;

	variable big_buffer: std_logic_vector (63 downto 0);
begin
	if (clock'event and clock = '1')or(rising_edge(load_forward)) then
	  	  --initializing pointer for pc
		current_pc_for_jal <= pc_pointer;
		
		--convert each field of the MIPS register into signed integer		
		sign_operand1 := to_integer(signed(operand1));
		sign_operand2 := to_integer(signed(operand2));

		sign_immediate := to_integer(signed(immediate));
		sign_shamt := to_integer(signed(shamt));

		instruction_type := to_integer(unsigned(alu_type));
		
		-- check if mem has forwarded data to process to exe
		if(load_forward= '1') then 
			if(op1_index_delay = load_index) then  -- check which operand need to be forwarded
				sign_operand1 := to_integer(signed(load_data));
			end if;
			if(op2_index_delay = load_index) then
				sign_operand2 := to_integer(signed(load_data));
			end if;
		end if;

		flush <= '0'; --clear flush signal

		if (stall = '1') then
			sign_result := 0;
			stall_out <= '1';
			alu_result <= std_logic_vector(to_signed(sign_result, 32));
		
		else	
			alu_type_out <= alu_type;
			operand2_out <= operand2;
			stall_out <= '0';
			result_index_out <= result_index_in;
			
			-- check whether this instruction could possibly forward useful data to the next
			if (alu_type="10100" OR alu_type="10110" OR alu_type="11000" 
			or alu_type="11001" or alu_type="11010" or alu_type="11011" 
			or alu_type="10101" or alu_type="10111" or alu_type="UUUUU" ) then --lw,sw, jump/branch, reserverd				
				exe_forward_valid <= '0';
			else  --jal, arithmetic
				exe_forward_valid <= '1';
			end if;

			alu_type_delay <= alu_type;
			result_index_in_delay <= result_index_in;
			op1_index_delay <= op1_index;
			op2_index_delay <= op2_index;
		
			if (instruction_type = 0) then --add
				sign_result := sign_operand1 + sign_operand2;
				alu_result <= std_logic_vector(to_signed(sign_result, 32));
			elsif (instruction_type = 1) then --sub
				sign_result := sign_operand1 - sign_operand2;
				alu_result <= std_logic_vector(to_signed(sign_result, 32));
			elsif (instruction_type = 2) then --add immediate
				sign_result := sign_operand1 + sign_immediate;
				alu_result <= std_logic_vector(to_signed(sign_result, 32));
			elsif (instruction_type = 3) then --multiply
				sign_result := sign_operand1 * sign_operand2;
				big_buffer := std_logic_vector(to_signed(sign_result, 64));
				hi_part <= big_buffer(63 downto 32);
				low_part <= big_buffer(31 downto 0);
 			elsif (instruction_type = 4) then --divide
				sign_result := sign_operand1 / sign_operand2;
				sign_remainder := sign_operand1 mod sign_operand2;
				low_part <= std_logic_vector(to_signed(sign_result, 32));
				hi_part <= std_logic_vector(to_signed(sign_remainder, 32));
			elsif (instruction_type = 5) then --set less than
				if (sign_operand1 < sign_operand2) then
					sign_result := 1;
				else
					sign_result := 0;
				end if;
				alu_result <= std_logic_vector(to_signed(sign_result, 32));
			elsif (instruction_type = 6) then --set less than immediate
				if (sign_operand1 < sign_immediate) then
					sign_result := 1;
				else
					sign_result := 0;
				end if;
				alu_result <= std_logic_vector(to_signed(sign_result, 32));
			elsif (instruction_type = 7) then --and
				alu_result <= operand1 and operand2;
			elsif (instruction_type = 8) then --or
				alu_result <= operand1 or operand2;
			elsif (instruction_type = 9) then --nor
				alu_result <= operand1 nor operand2;
			elsif (instruction_type = 10) then --xor
				alu_result <= operand1 xor operand2;
			elsif (instruction_type = 11) then --and imme
				alu_result <= operand1 and immediate;
			elsif (instruction_type = 12) then --or imme
				alu_result <= operand1 or immediate;
			elsif (instruction_type = 13) then --xor imme
				alu_result <= operand1 xor immediate;
			elsif (instruction_type = 14) then -- move from hi
				alu_result <= hi_part;
			elsif (instruction_type = 15) then -- move from low
				alu_result <= low_part;
			elsif (instruction_type = 16) then --load upper immediate
				alu_result <= immediate(15 downto 0) & "0000000000000000";
			elsif (instruction_type = 17) then --shift left logical
				alu_result <= std_logic_vector(signed(operand1) sll sign_shamt);
			elsif (instruction_type = 18) then --shift right logical
				alu_result <= std_logic_vector(signed(operand1) srl sign_shamt);
			elsif (instruction_type = 19) then --shift right arithmetic
				alu_result <= std_logic_vector(shift_right(signed(operand1), sign_shamt));
			elsif (instruction_type = 20) then --load word, calculating address
            			sign_result := sign_operand1 + sign_immediate;
				alu_result <= std_logic_vector(to_signed(sign_result, 32));
			elsif (instruction_type = 21) then --reserved 1
			elsif (instruction_type = 22) then --store word, calculating address
            			sign_result := sign_operand1 + sign_immediate;
				alu_result <= std_logic_vector(to_signed(sign_result, 32));
			elsif (instruction_type = 23) then --reserved 2
			elsif (instruction_type = 24) then --branch on equal
				if(branch_taken = '0' and sign_operand1 = sign_operand2) then
					flush <= '1';
					pc_pointer_out <= (pc_pointer/4 + sign_immediate + 2)*4; -- add 2 extra cycs to compensate the delays from IF to EXE
				end if;
				if((branch_taken = '0' and (sign_operand1 = sign_operand2)) OR (branch_taken = '1' and NOT(sign_operand1 = sign_operand2))) then
					branch_prediction_fail <= '1';
					branch_prediction_fail_index <= (pc_pointer/4 + sign_immediate + 2) mod (2**(branch_predictor_buffer_entity_number_bit));
				else
					branch_prediction_succeed <= '1';
				end if;
			elsif (instruction_type = 25) then --branch on not equal
				if(branch_taken = '0' and not(sign_operand1 = sign_operand2)) then
					flush <= '1';
					pc_pointer_out <= (pc_pointer/4 + sign_immediate + 2)*4;
				end if;
				if( (branch_taken = '0' and NOT(sign_operand1 = sign_operand2)) OR (branch_taken = '1' and (sign_operand1 = sign_operand2)) ) then
					branch_prediction_fail <= '1';
					branch_prediction_fail_index <= (pc_pointer/4 + sign_immediate + 2) mod (2**(branch_predictor_buffer_entity_number_bit));
				else
					branch_prediction_succeed <= '1';
				end if;
			elsif (instruction_type = 26) then --jump
				flush <= '1';
				pc_pointer_out <= 4 * to_integer(unsigned(jump_addr))+4;
			elsif (instruction_type = 27) then --jump register
				flush <= '1';
				pc_pointer_out <= 4 * sign_operand1+4;
			elsif (instruction_type = 28) then --jump and link
				flush <= '1';
				pc_pointer_out <= 4 * to_integer(unsigned(jump_addr))+4;
			end if;
		end if;

	end if;
	if (clock'event and clock = '0') then
		branch_prediction_fail <= '0';	
		branch_prediction_succeed <= '0';
	end if;
end process;

-- set the lw hazard detection signal (stall fetch and wait mem to forward)
load_hazard <= '1' when ((alu_type_delay = "10100") and (need_stall_dectection(1) = '1') and (op1_index = result_index_in_delay)) else
		'1' when ((alu_type_delay = "10100") and (need_stall_dectection(0) = '1') and (op2_index = result_index_in_delay)) else
		'0';
	
end architecture;
