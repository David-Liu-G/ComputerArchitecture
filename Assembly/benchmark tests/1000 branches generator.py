import random

file = open ("1000 random branches.asm","w")

for i in range(1000):

    if random.random() < 0.89: # gcc 11% not taken
        file.write('next' + str(i) + ': beq $0,$0, next' + str(i) + '\n')
    else:
        file.write('next' + str(i) + ': bne $0,$0, next' + str(i) + '\n')

file.close()