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

placar_geral:         .asciz "Placar Geral:\nPlayer: "
placar_geral_2:       .asciz "\nDealer: \n"
cartas_restantes:     .asciz "Cartas restantes no baralho:\n"

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
        beq t0, t1, distribuir_inicial
        li t1, 2
        beq t0, t1, sair_jogo

        li a7, 4
        la a0, invalida
        ecall
        j main

# ==================== ROTINA DE SORTEIO ====================

sortear_carta:
    # a0: endereço da mão
    # a1: endereço do número de cartas
    # a2: endereço do total

    la t3, contador_cartas
    lw t4, 0(t3)
    li t5, 40
    bge t4, t5, reiniciar_baralho

sorteio_loop_generico:
    li a3, 1
    li a4, 14
    li a7, 42
    ecall
    mv t6, a0

    li t7, 14
    blt t6, t7, verifica_contagem_generico
    j sorteio_loop_generico

verifica_contagem_generico:
    addi t8, t6, -1
    la t9, contagem_baralho
    add t10, t9, t8
    lb t11, 0(t10)

    li t12, 4
    beq t11, t12, sorteio_loop_generico

    addi t11, t11, 1
    sb t11, 0(t10)

    lw t4, 0(t3)
    addi t4, t4, 1
    sw t4, 0(t3)

    lw t0, 0(a1)         # t0 = num_cartas
    add t1, a0, t0       # endereço da próxima carta
    sb t6, 0(t1)         # salva carta sorteada
    addi t0, t0, 1
    sw t0, 0(a1)         # atualiza num_cartas

    lw t2, 0(a2)
    add t2, t2, t6
    sw t2, 0(a2)

    ret

# ==================== DISTRIBUIÇÃO INICIAL ====================

distribuir_inicial:
    # Player recebe 2 cartas
    la a0, mao_player
    la a1, num_cartas_player
    la a2, total_player
    jal sortear_carta
    la a0, mao_player
    la a1, num_cartas_player
    la a2, total_player
    jal sortear_carta

    # Dealer recebe 2 cartas
    la a0, mao_dealer
    la a1, num_cartas_dealer
    la a2, total_dealer
    jal sortear_carta
    la a0, mao_dealer
    la a1, num_cartas_dealer
    la a2, total_dealer
    jal sortear_carta

    j verifica_mao

# ==================== VERIFICACOES DO JOGO ====================
verifica_mao:
        la t0, total_player
        lw t1, 0(t0)
        li t2, 21
        ble t1, t2, acao_player

        li a7, 4
        la a0, estouro_player
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
        la a0, mao_player
        la a1, num_cartas_player
        la a2, total_player
        jal sortear_carta

        addi sp, sp, -4
        sw ra, 0(sp)
        jal verifica_mao
        lw ra, 0(sp)
        addi sp, sp, 4
        ret

stand:
        li a7, 4
        la a0, turno_dealer
        ecall

        la t0, total_dealer
        lw t1, 0(t0)

        addi sp, sp, -4      
        sw ra, 0(sp)         

        jal exibir_mao_player

        lw ra, 0(sp)         
        addi sp, sp, 4       

        j loop_dealer

loop_dealer:
        li t2, 17
        bge t1, t2, compara_finais

        # Dealer pede carta
        la a0, mao_dealer
        la a1, num_cartas_dealer
        la a2, total_dealer
        jal sortear_carta

        # Exibe mão do dealer após cada carta
        addi sp, sp, -4
        sw ra, 0(sp)
        jal exibir_mao_dealer
        lw ra, 0(sp)
        addi sp, sp, 4

        # Atualiza t1 com novo total_dealer
        la t0, total_dealer
        lw t1, 0(t0)

        j loop_dealer

# =============== EXIBIR MÃOS/PLACAR ===============

exibir_mao_player:
        la t0, mao_player
        la t1, num_cartas_player
        lw t2, 0(t1)
        li t3, 0    # indice da carta

exibir_mao_loop_player:
        bge t3, t2, fim_exibir_mao_player # percorreu todas as cartas
        add t4, t0, t3 # calcula o endereco que esta a carta
        lb t5, 0(t4) # carrego a carta
        mv a0, t5
        li a7, 1 
        ecall

        li a7, 11
        li a0, '+'
        ecall 
        
        addi t3, t3, 1
        j exibir_mao_loop_player

fim_exibir_mao_player: #percorrido os vetores, realizar a soma
        li a7, 11
        li a0, '='
        ecall

        la t6, total_player
        lw a0, 0(t6)
        li a7, 1
        ecall
        ret

exibir_mao_dealer:
        la t0, mao_dealer
        la t1, num_cartas_dealer
        lw t2, 0(t1)
        li t3, 0    # indice da carta

exibir_mao_loop_dealer:
        bge t3, t2, fim_exibir_mao_dealer # percorreu todas as cartas
        add t4, t0, t3 # calcula o endereco que esta a carta
        lb t5, 0(t4) # carrego a carta
        mv a0, t5
        li a7, 1 
        ecall

        li a7, 11
        li a0, '+'
        ecall 
        
        addi t3, t3, 1
        j exibir_mao_loop_dealer

fim_exibir_mao_dealer: #percorrido os vetores, realizar a soma
        li a7, 11
        li a0, '='
        ecall

        la t6, total_dealer
        lw a0, 0(t6)
        li a7, 1
        ecall
        ret

exibir_placar:
        li a7, 4
        la a0, placar_geral
        ecall

        la t0, placar_player
        lw a0, 0(t0)
        li a7, 1
        ecall

        li a7, 4
        la a0, placar_geral_2
        ecall

        la t0, placar_dealer
        lw a0, 0(t0)
        li a7, 1
        ecall
        
        li a7, 4
        la a0, cartas_restantes
        ecall

        la t0, contador_cartas
        lw t1, 0(t0)
        li a0, 40
        sub a0, a0, t1 # subtrai o total de cartas restantes
        li a7, 1 
        ecall

        ret

# =============== FINAIS ===============

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

# =============== NOVA RODADA ===============

nova_rodada:
        la t2, num_cartas_player
        sw zero, 0(t2)
        la t3, num_cartas_dealer
        sw zero, 0(t3)
        la t4, total_player
        sw zero, 0(t4)
        la t5, total_dealer
        sw zero, 0(t5)

        li a7, 4
        la a0, reinicio
        ecall
        j distribuir_inicial

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
        j distribuir_inicial

sair_jogo:
        li a7, 4
        la a0, sair
        ecall
        li a7, 10
        ecall
