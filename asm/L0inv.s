ori $s6, $0, 0x3000
ori $t8, $0, 1
sw $t8, 12($s6)
ori $a0, $0, 0x1000
ori $a1, $0, 0x2000
while_true:
inicioEspera:
lw $t0, 0($s6)
beq $t0, $0, inicioEspera
esperaPosterior:
lw $t0, 8($s6)
beq $t0, $0, esperaPosterior
xor $s0, $s0, $s0
for_i:
ori $s1, $s0, $0
xor $s2, $s2, $s2
xor $s3, $s3, $s3
for_n_1:
sll $s2, $s2, 1
andi $t0, $s1, 1
or  $s2, $s2, $t0
srl $s1, $s1, 1
addi $s3, $s3, 1
addi $t0, $s3, -8
bne $t0, $0, for_n_1
sll $s4, $s2, 1
addi $s1, $s0, 1
xor  $s2, $s2, $s2
xor  $s3, $s3, $s3
for_n_2:
sll $s2, $s2, 1
andi $t0, $s1, 1
or  $s2, $s2, $t0
srl $s1, $s1, 1
addi $s3, $s3, 1
addi $t0, $s3, -8
bne $t0, $0, for_n_2
sll $s5, $s2, 1
sll $s4, $s4, 2
sll $s5, $s5, 2
add $t0, $a0, $s4
lw $t1, 0($t0)
lw $t2, 4($t0)
add $t0, $a0, $s5
lw $t3, 0($t0)
lw $t4, 4($t0)
add $t5, $t1, $t3
sub $t6, $t1, $t3
add $t7, $t2, $t4
sub $t8, $t2, $t4
sll $t0, $s0, 3
add $t0, $t0, $a1
sw $t5, 0($t0)
sw $t7, 4($t0)
sw $t6, 8($t0)
sw $t8, 12($t0)
addi $s0, $s0, 2
addi $t0, $s0, -256
bne $t0, $0, for_i
sw $t8, 4($s6)
sw $t8, 12($s6)
ori $t0, $t0, 0x800
xor  $a0, $a0, $t0
xor  $a1, $a1, $t0
j while_true
