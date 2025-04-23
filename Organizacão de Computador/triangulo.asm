	.data
a:		  .space 4
b:	          .space 4
c:		  .space 4

num1:		  .string "Informe o primeiro numero:"
num2:	  	  .string "Informe o segundo numero:"
num3:		  .string "Informe o terceiro numero:"

nao_eh_triangulo: .string "Os valores correspondentes nao formam um triangulo!"
eh_triangulo: 	  .string "Os valores correspondentes formam um triangulo!"
	
	.text	
main:
	la a0, num1
	li a7, 4 #printa a mensagem 1
	ecall
	
	li a7, 5 #lê o input de um inteiro
	ecall
	
	mv s0, a0
	
	la a0, num2
	li a7, 4 #printa a mensagem 2
	ecall
	
	li a7, 5 #lê o input de um inteiro
	ecall
	
	mv s1, a0
	
	la a0, num3
	li a7, 4 #printa a mensagem 3
	ecall
	
	li a7, 5 #lê o input de um inteiro
	ecall
	
	mv s2, a0
	
	call testa_numero_1
	
testa_numero_1:
	bgt s0, s1, testa_numero_2
	
testa_numero_2:
	bgt s0, s2, determina_maior
	
determina_maior:
	add s3, s1, s2
	bgt s3, s0, mensagem_triangulo
	call mensagem_nao_triangulo
	
mensagem_triangulo:
	la a0, eh_triangulo
	li a7, 4
	ecall
	r
	j fim
	
mensagem_nao_triangulo:
	la a0, nao_eh_triangulo
	li a7, 4
	ecall
	j fim
	
fim:
	li a7, 10
	ecall



	
	
