.data # segmento de dados

vetor: .space 64
conta: .word 0

.text

main:
	la t0, vetor
    	li t1, 64
    	li t2, 0    # contador de posição
    	li t3, 0    # ocorrencias de 1
    
loop:
	bgt t2, t1, fim
	lb t4, 0(t0)
	li t5, 1
	beq t4, t5, soma
	j proximo
soma:
	addi t3, t3, 1
proximo:
	addi t0, t0, 1
	addi t2, t2, 1
	j loop
fim:
	la t6, conta
	sw t3, 0(t6)
	li a7, 10
	ecall
