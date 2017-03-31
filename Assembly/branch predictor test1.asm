addi $1, $0, 5
addi $2, $0, 3
loop: beq $1, $2 , end
addi $2, $2, 1
j loop
addi  $0, $0, 0
addi  $0, $0, 0
end: sub $0, $0, 0