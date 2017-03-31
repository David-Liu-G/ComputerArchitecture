addi $1, $0, 7
addi $2, $0, 4
addi $3, $0, 1
loop: bne $1, $2, notskip
j exit
notskip: sub $1, $1, $3
j loop
exit: add $5, $5, $5 