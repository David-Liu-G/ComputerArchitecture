addi $1, $0, 1
addi $2, $0, 0 # counter = 0
start: add $2, $2, $1 # counter ++
beq $0, $0, dest
sub $0, $0, $0
sub $0, $0, $0
sub $0, $0, $0
dest: jump start
add $0, $0, $0
add $0, $0, $0
