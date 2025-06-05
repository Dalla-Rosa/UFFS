.data
bem_vindo:            .asciz "Bem-vindo ao Blackjack!\n1 - Jogar\n2 - Sair\nEscolha: "
sair:                 .asciz "Encerrando o jogo... Até a próxima!\n"
invalida:             .asciz "Opção inválida. Tente novamente.\n"
turno_player:         .asciz "Sua vez. Escolha:\n1 - Pedir carta (Hit)\n2 - Parar (Stand)\n"
turno_dealer:         .asciz "Vez do dealer...\n"
vitoria_player:       .asciz "Você venceu!\n"
vitoria_dealer:       .asciz "Dealer venceu!\n"
empate:               .asciz "Empate!\n"
estouro_dealer:       .asciz "Dealer estourou!, o valor das cartas passou de 21!\n"
estouro_player:       .asciz "Player estourou!, o valor das cartas passou de 21!\n"
reinicio:             .asciz "Fim do jogo, gostaria de distribuir as cartas novamente?\n1 - Sim\n2 - Não\nEscolha: "
msg_mao_player:       .asciz "Sua mão: "
msg_mao_dealer:       .asciz "Mão do Dealer: "
msg_igual:            .asciz " = "
msg_carta_oculta:     .asciz " e uma carta oculta\n"
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
placar_geral_2:       .asciz "  Dealer: "
cartas_restantes:     .asciz "Cartas restantes no baralho:\n"
msg_cartas_sorteadas: .asciz "\nCartas sorteadas nesta sessão:\n"
dois_pontos:          .asciz ":"

contagem_baralho:     .space 13

.text
main:
        la t0, num_cartas_player
        la t1, total_player
        sw zero, 0(t0)  # Inicializa num_cartas_player com zero
        sw zero, 0(t1)  # Inicializa total_player com zero
        li a7, 4
        la a0, bem_vindo
        ecall

        li a7, 5
        ecall
        mv t0, a0

        li t1, 1
        beq t0, t1, inicio_jogo
        li t1, 2
        beq t0, t1, sair_jogo

        li a7, 4
        la a0, invalida
        ecall
        j main

# ==================== ROTINA DE SORTEIO ====================
sortear_carta:
    # Salva os endereços em temporários
    mv t0, a0      # t0 = endereço da mão
    mv t1, a1      # t1 = endereço do número de cartas
    mv t2, a2      # t2 = endereço do total

    la t3, contador_cartas
    lw t4, 0(t3)
    li t5, 52
    bge t4, t5, reiniciar_baralho

sorteio_loop_generico:
    li a0, 1       # mínimo para random
    li a1, 13      # máximo para random
    li a7, 42
    ecall
    mv t6, a0      # t6 = valor sorteado (1 a 13)

    li s0, 14
    bge t6, s0, sorteio_loop_generico

    # Verifica contagem da carta sorteada
    addi s1, t6, -1
    la s2, contagem_baralho
    add s1, s2, s1
    lb s3, 0(s1)

    li s4, 4
    beq s3, s4, sorteio_loop_generico

    addi s3, s3, 1
    sb s3, 0(s1)

    # Atualiza contador de cartas
    la s5, contador_cartas
    lw s6, 0(s5)
    addi s6, s6, 1
    sw s6, 0(s5)

    # Adiciona carta à mão
    lw s0, 0(t1)         # s0 = num_cartas (eu sei que n é certo usar s0 nesses casos mas foi oq deu k)
    li s1, 40
    bge s0, s1, fim_sortear_carta   # se já tem 40 cartas não adiciono mais

    add s2, t0, s0       # endereço da próxima carta
    sb t6, 0(s2)         # salva carta que sorteei
    addi s0, s0, 1
    sw s0, 0(t1)         # atualiza num_cartas

    
    lw s3, 0(t2)         # atualizo o total dessa bodega (funciona plmds)
    add s3, s3, t6
    sw s3, 0(t2)

fim_sortear_carta:
    ret

# ==================== DISTRIBUIÇÃO INICIAL ====================

inicio_jogo:
    # Zera contadores antes de distribuir
    la t0, num_cartas_player
    sw zero, 0(t0)
    la t1, num_cartas_dealer
    sw zero, 0(t1)
    la t2, total_player
    sw zero, 0(t2)
    la t3, total_dealer
    sw zero, 0(t3)

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

    jal exibir_mao_player
    jal exibir_mao_dealer_oculta

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
        jal exibir_mao_player
        jal verifica_mao
        ret

stand:
    li a7, 4
    la a0, turno_dealer
    ecall
    jal exibir_mao_dealer   
    j loop_dealer

loop_dealer:
    la t0, total_dealer
    lw t1, 0(t0)
    li t2, 17
    bge t1, t2, compara_finais

    # Dealer pede carta
    la a0, mao_dealer
    la a1, num_cartas_dealer
    la a2, total_dealer
    jal sortear_carta

    jal exibir_mao_dealer  

    j loop_dealer

# =============== EXIBIR MÃOS/PLACAR ===============

exibir_mao_player:
    li a7, 4
    la a0, msg_mao_player
    ecall

    la t0, mao_player
    la t1, num_cartas_player
    lw t2, 0(t1)      # t2 = num_cartas
    li t3, 0          # índice

exibir_mao_player_loop:
    bge t3, t2, exibir_mao_player_total
    add t4, t0, t3
    lb t5, 0(t4)
    mv a0, t5
    li a7, 1
    ecall

    addi t3, t3, 1
    bge t3, t2, exibir_mao_player_total

    li a7, 11
    li a0, '+'
    ecall

    j exibir_mao_player_loop

exibir_mao_player_total:
    li a7, 4
    la a0, msg_igual
    ecall

    la t6, total_player
    lw a0, 0(t6)
    li a7, 1
    ecall

    li a7, 11
    li a0, 10
    ecall
    ret

exibir_mao_dealer:
    li a7, 4
    la a0, msg_mao_dealer
    ecall

    la t0, mao_dealer
    la t1, num_cartas_dealer
    lw t2, 0(t1)      # t2 = num_cartas
    li t3, 0          # índice

exibir_mao_dealer_loop:
    bge t3, t2, exibir_mao_dealer_total
    add t4, t0, t3
    lb t5, 0(t4)
    mv a0, t5
    li a7, 1
    ecall

    addi t3, t3, 1
    bge t3, t2, exibir_mao_dealer_total

    # Exibe "+"
    li a7, 11
    li a0, '+'
    ecall

    j exibir_mao_dealer_loop

exibir_mao_dealer_total:
    # Exibe " = "
    li a7, 4
    la a0, msg_igual
    ecall

    la t6, total_dealer
    lw a0, 0(t6)
    li a7, 1
    ecall

    # Nova linha
    li a7, 11
    li a0, 10
    ecall
    ret


exibir_mao_dealer_oculta:
    li a7, 4
    la a0, msg_mao_dealer
    ecall

    la t0, mao_dealer
    lb t1, 0(t0)      # primeira carta do dealer
    mv a0, t1
    li a7, 1
    ecall

    li a7, 4
    la a0, msg_carta_oculta
    ecall

    # Nova linha
    li a7, 11
    li a0, 10
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

        # Nova linha para separar
        li a7, 11
        li a0, 10
        ecall

        li a7, 4
        la a0, cartas_restantes
        ecall

        la t0, contador_cartas
        lw t1, 0(t0)
        li a0, 52
        sub a0, a0, t1 # subtrai o total de cartas restantes
        li a7, 1 
        ecall

        # Nova linha
        li a7, 11
        li a0, 10
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
        jal exibir_placar
        li a7, 4
        la a0, reinicio
        ecall

        li a7, 5      # lê opção do usuário
        ecall
        mv t0, a0

        li t1, 1
        beq t0, t1, reiniciar_rodada
        li t1, 2
        beq t0, t1, sair_jogo

        li a7, 4
        la a0, invalida
        ecall
        j nova_rodada

reiniciar_rodada:
    la t2, num_cartas_player
    sw zero, 0(t2)
    la t3, num_cartas_dealer
    sw zero, 0(t3)
    la t4, total_player
    sw zero, 0(t4)
    la t5, total_dealer
    sw zero, 0(t5)
    la a0, mao_player
    jal zerar_mao
    la a0, mao_dealer
    jal zerar_mao
    j inicio_jogo

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
        j inicio_jogo

sair_jogo:
        jal exibir_cartas_sorteadas
        li a7, 4
        la a0, sair
        ecall
        li a7, 10
        ecall

exibir_cartas_sorteadas:
        li a7, 4
        la a0, msg_cartas_sorteadas
        ecall
        la t0, contagem_baralho
        li t1, 1          

exibir_cartas_sorteadas_loop:
        li t2, 13
        bgt t1, t2, fim_exibir_cartas_sorteadas
        addi t3, t1, -1
        add t4, t0, t3
        lb t5, 0(t4)
        beqz t5, proxima_carta
        mv a0, t1
        li a7, 1
        ecall
        li a7, 4
        la a0, dois_pontos
        ecall
        mv a0, t5
        li a7, 1
        ecall
        li a7, 11
        li a0, 32 # espaço
        ecall

proxima_carta:
        addi t1, t1, 1
        j exibir_cartas_sorteadas_loop

fim_exibir_cartas_sorteadas:
        li a7, 11
        li a0, 10
        ecall
        ret

zerar_mao:
    # a0 = endereço da mão
    li t0, 0
zerar_mao_loop:
    li t1, 40
    bge t0, t1, zerar_mao_fim
    add t2, a0, t0
    sb zero, 0(t2)
    addi t0, t0, 1
    j zerar_mao_loop
zerar_mao_fim:
    ret
