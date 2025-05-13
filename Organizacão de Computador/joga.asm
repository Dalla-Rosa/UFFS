.data

msg0: .string "Informe um número de 0 a 9:"
msg1: .string "Acertou!"
msg2: .string "Errou!"

.text

main:
	la a0, msg0
	li a7, 4
	ecall
	li a7, 5
	ecall
	call joga
	j fim
joga:
	addi sp, sp, -4
	sw ra, 0(sp)
	mv t0, a0 
	li a0, 10
	call randnum
	beq t0, a0, acertou
	la a0, msg2
	li a7, 4
	ecall
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
randnum:
	addi sp, sp, -4
	sw ra, 0(sp)
	mv a1, a0
	li a7, 42
	ecall
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
acertou:
	la a0, msg1
	li a7, 4
	ecall
	lw ra, 0(sp)
	addi sp, sp, 4
	ret	
fim: 
	li a7, 10
	ecall
