addi $1, $0, 1
addi $2, $0, 1
start: beq $1, $2, plus
minus: sub $2, $2, $1
j start
plus: add $2, $2, $1
j start
add $0, $0, $0
add $0, $0, $0
