addi $1, $0, 1
addi $2, $0, 0 # counter for number of loops ran
start: add $2, $2, $1 # counter ++
beq $0, $0, dest
sub $0, $0, $0
sub $0, $0, $0
sub $0, $0, $0
dest: j start
add $0, $0, $0
add $0, $0, $0
