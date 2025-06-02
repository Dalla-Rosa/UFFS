.data
bem_vindo:            .asciz "Bem-vindo ao Blackjack!\n1 - Jogar\n2 - Sair\nEscolha: "
sair:                 .asciz "Encerrando o jogo... Até a próxima!\n"
invalida:             .asciz "Opção inválida. Tente novamente.\n"
turno_player:         .asciz "Sua vez. Escolha:\n1 - Pedir carta (Hit)\n2 - Parar (Stand)\n"
turno_dealer:         .asciz "Vez do dealer...\n"
vitoria_player:       .asciz "Você venceu!\n"
vitoria_dealer:       .asciz "Dealer venceu!\n"
empate:               .asciz "Empate!\n"
estouro_dealer:	      .asciz "Dealer estourou!, o valor das cartas passou de 21!\n"
estouro_player:       .asciz "Player estourou!, o valor das cartas passou de 21!\n"
reinicio:             .asciz "Fim do jogo, gostaria de distribuir as cartas novamente?\n"
contador_cartas:      .word 0

mao_player:           .space 40
num_cartas_player:    .word 0
mao_dealer:           .space 40
num_cartas_dealer:    .word 0

total_player:         .word 0
total_dealer:         .word 0

placar_player:        .word 0
placar_dealer:        .word 0

contagem_baralho:     .space 13

.text
main:
    	li a7, 4
    	la a0, bem_vindo
    	ecall

    	li a7, 5
    	ecall
    	mv t0, a0

    	li t1, 1
    	beq t0, t1, sortear_carta
    	li t1, 2
    	beq t0, t1, sair_jogo

   	li a7, 4
    	la a0, invalida
    	ecall
    	j main

sortear_carta:
    	la t0, contador_cartas
    	lw t1, 0(t0)
    	li t2, 40
    	bge t1, t2, reiniciar_baralho

sorteio_loop:
    	li a0, 1
	li a1, 14
    	li a7, 42
    	ecall
    	mv t3, a0

    	li t2, 14
    	blt t3, t2, verifica_contagem
    	j sorteio_loop

verifica_contagem:
    	addi t4, t3, -1
    	la t5, contagem_baralho
    	add t6, t5, t4
    	lb t7, 0(t6)

    	li t8, 4
    	beq t7, t8, sortear_carta

    	addi t7, t7, 1
    	sb t7, 0(t6)

    	la t0, contador_cartas
    	lw t1, 0(t0)
    	addi t1, t1, 1
    	sw t1, 0(t0)

    	j verifica_mao

verifica_mao:
    	la t0, total_player
    	lw t1, 0(t0)
    	li t2, 21
    	ble t1, t2, acao_player

    	li a7, 4
    	la a0, estouro
    	ecall

    	la t3, placar_dealer
    	lw t4, 0(t3)
    	addi t4, t4, 1
    	sw t4, 0(t3)

    	j nova_rodada

acao_player:
    	li a7, 4
    	la a0, turno_player
    	ecall

    	li a7, 5
    	ecall

    	li a1, 1
    	beq a1, a0, hit
    	li a1, 2
    	beq a1, a0, stand

    	li a7, 4
    	la a0, invalida
    	ecall
    	j acao_player

hit:
    	j sortear_carta

stand:
    	li a7, 4
    	la a0, turno_dealer
    	ecall

    	la t0, total_dealer
    	lw t1, 0(t0)
loop_dealer:
    	li t2, 17
    	bge t1, t2, compara_finais
    	j sortear_carta_dealer

sortear_carta_dealer:
    	j sortear_carta  
	
compara_finais:
    	la t0, total_player
    	lw t1, 0(t0)
    	la t2, total_dealer
    	lw t3, 0(t2)


    	li t4, 21

    	bgt t3, t4, dealer_estourou
    	bgt t1, t4, player_estourou
    	bgt t1, t3, player_vence
    	bgt t3, t1, dealer_vence
    	beq t1, t3, empate_jogo
    	j nova_rodada

dealer_estourou:
    	li a7, 4
    	la a0, estouro_dealer
    	ecall

    	la t0, placar_player
    	lw t1, 0(t0)
    	addi t1, t1, 1
    	sw t1, 0(t0)
    	j nova_rodada
    	
player_estourou:
    	li a7, 4
    	la a0, estouro_player   
 	ecall
 	
 	la t0, placar_dealer
 	lw t1, 0(t0)
 	addi t1, t1, 1
 	sw t1, 0(t0)
 	j nova_rodada
 	

player_vence:
    	li a7, 4
    	la a0, vitoria_player
    	ecall

    	la t0, placar_player
    	lw t1, 0(t0)
	addi t1, t1, 1
    	sw t1, 0(t0)
    	j nova_rodada

dealer_vence:
    	li a7, 4
    	la a0, vitoria_dealer
    	ecall

    	la t0, placar_dealer
    	lw t1, 0(t0)
    	addi t1, t1, 1
    	sw t1, 0(t0)
    	j nova_rodada

empate_jogo:
    	li a7, 4
    	la a0, empate
    	ecall
    	j nova_rodada

nova_rodada:
    	la t2, num_cartas_player
    	sw zero, 0(t2)
    	la t3, num_cartas_dealer
    	sw zero, 0(t3)

    	li a7, 4
    	la a0, reinicio
    	ecall
    	j sortear_carta

reiniciar_baralho:
    	la t0, contagem_baralho
    	li t1, 0
    
limpar_loop:
    	li t2, 13
    	bge t1, t2, zerar_contador
    	add t3, t0, t1
    	sb zero, 0(t3)
    	addi t1, t1, 1
   	j limpar_loop

zerar_contador:
    	la t0, contador_cartas
    	sw zero, 0(t0)
    	j sortear_carta

sair_jogo:
    	li a7, 4
    	la a0, sair
   	ecall
    	li a7, 10
    	ecall