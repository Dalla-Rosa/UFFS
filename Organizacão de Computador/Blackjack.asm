.data

# Bernardo Flores Dalla Rosa - 2211100035

# Mensagens para mostrar no console 

bem_vindo:            .asciz "\nBem-vindo ao Blackjack!\n1 - Jogar\n2 - Sair\nEscolha: "
sair:                 .asciz "\nEncerrando o jogo... Até a próxima!\n"
invalida:             .asciz "\nOpção inválida. Tente novamente.\n"
turno_player:         .asciz "\nSua vez.\n1 - Pedir carta (Hit)\n2 - Parar (Stand)\nEscolha: "
turno_dealer:         .asciz "\nVez do Dealer...\n"
vitoria_player:       .asciz "\nVocê venceu!\n"
vitoria_dealer:       .asciz "Dealer venceu!\n"
empate:               .asciz "\nEmpate!\n"
estouro_dealer:       .asciz "\nDealer estourou!, o valor das cartas passou de 21!\n"
estouro_player:       .asciz "\nPlayer estourou!, o valor das cartas passou de 21!\n"
reinicio:             .asciz "\nFim do jogo, gostaria de distribuir as cartas novamente?\n1 - Sim\n2 - Não\nEscolha: "
str_mao_player:       .asciz "\nSua mão: "
str_mao_dealer:       .asciz "Mão do Dealer: "
str_igual:            .asciz " = "
str_carta_oculta:     .asciz " e uma carta oculta"
placar_geral:         .asciz "\nPlacar Geral:\nPlayer: "
placar_geral_2:       .asciz "  Dealer: "
cartas_restantes:     .asciz "\nCartas restantes no baralho:\n"
str_cartas_sorteadas: .asciz "\nCartas sorteadas nesta sessão:\n"
dois_pontos:          .asciz ":"

# Auxiliares/vetores para guardar os resultados

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
    # Menu inicial do jogo
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
    # Sorteia uma carta e atualiza a mão e o número de cartas
    mv t0, a0                # t0 = endereço da mão
    mv t1, a1                # t1 = endereço do número de cartas
    mv t2, a2                # t2 = endereço do total (não usado aqui)

    la t3, contador_cartas   # t3 = endereço do contador de cartas
    lw t4, 0(t3)             # t4 = valor do contador de cartas
    li t5, 52
    bge t4, t5, reiniciar_baralho

sorteio_loop:
    li a1, 13                # a1 = valor máximo para sortear (13 cartas)
    li a7, 42                # syscall random
    ecall
    addi a0, a0, 1
    mv t6, a0                # t6 = valor sorteado (1 a 13)

    addi t4, t6, -1          # t4 = índice da carta (0 a 12)
    la t5, contagem_baralho  # t5 = base do vetor de contagem
    add t4, t5, t4           # t4 = endereço da carta sorteada em contagem_baralho
    lb t5, 0(t4)             # t5 = quantidade sorteada dessa carta

    li a0, 4
    beq t5, a0, sorteio_loop # se ja saiu 4 vezes, sorteia de novo

    addi t5, t5, 1
    sb t5, 0(t4)             # atualiza contagem da carta

    la t3, contador_cartas
    lw t4, 0(t3)
    addi t4, t4, 1
    sw t4, 0(t3)             # atualiza contador de cartas

    lw t5, 0(t1)             # t5 = numero de cartas na mao
    li t4, 40
    bge t5, t4, fim_sortear_carta

    add t4, t0, t5           # t4 = endereço para armazenar a carta sorteada
    sb t6, 0(t4)             # salva valor sorteado na mao
    addi t5, t5, 1
    sw t5, 0(t1)             # atualiza numero de cartas na mao

fim_sortear_carta:
    ret

# ==================== PROCESSO INICIAL DO JOGO ====================

inicio_jogo:
    # Zera variáveis e distribui cartas iniciais
    la t0, num_cartas_player
    sw zero, 0(t0)
    la t1, num_cartas_dealer
    sw zero, 0(t1)
    la t2, total_player
    sw zero, 0(t2)
    la t3, total_dealer
    sw zero, 0(t3)

    # Duas cartas para o player
    la a0, mao_player
    la a1, num_cartas_player
    la a2, total_player
    jal sortear_carta
    la a0, mao_player
    la a1, num_cartas_player
    la a2, total_player
    jal sortear_carta

    # Calcula total do player
    la a0, mao_player
    la a1, num_cartas_player
    la a2, total_player
    jal calcula_total_mao

    # Duas cartas para o dealer
    la a0, mao_dealer
    la a1, num_cartas_dealer
    la a2, total_dealer
    jal sortear_carta
    la a0, mao_dealer
    la a1, num_cartas_dealer
    la a2, total_dealer
    jal sortear_carta

    # Calcula total do dealer
    la a0, mao_dealer
    la a1, num_cartas_dealer
    la a2, total_dealer
    jal calcula_total_mao

    jal exibir_mao_player
    jal exibir_mao_dealer_oculta

    j verifica_mao

# ==================== VERIFICACÕES DO JOGO ====================

verifica_mao:
    # Verifica se o player estourou, senao segue para ação do player
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
    # Pergunta ao player se quer carta ou parar
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
    # Player pede carta, atualiza mão e total
    la a0, mao_player
    la a1, num_cartas_player
    la a2, total_player
    jal sortear_carta

    la a0, mao_player
    la a1, num_cartas_player
    la a2, total_player
    jal calcula_total_mao

    jal exibir_mao_player
    jal verifica_mao
    ret

stand:
    # Player para, vez do dealer
    li a7, 4
    la a0, turno_dealer
    ecall
    jal exibir_mao_dealer
    j loop_dealer

loop_dealer:
    # Dealer compra cartas até >= 17
    la t0, total_dealer
    lw t1, 0(t0)
    li t2, 17
    bge t1, t2, compara_finais

    la a0, mao_dealer
    la a1, num_cartas_dealer
    la a2, total_dealer
    jal sortear_carta

    la a0, mao_dealer
    la a1, num_cartas_dealer
    la a2, total_dealer
    jal calcula_total_mao

    jal exibir_mao_dealer
    j loop_dealer

# =============== EXIBIR MÃOS/PLACAR ===============

exibir_mao_player:
    # Mostra a mão do player (cartas + total)
    li a7, 4
    la a0, str_mao_player
    ecall

    la t0, mao_player
    la t1, num_cartas_player
    lw t2, 0(t1)
    li t3, 0

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
    la a0, str_igual
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
    # Mostra a mão do dealer (cartas + total)
    li a7, 4
    la a0, str_mao_dealer
    ecall

    la t0, mao_dealer
    la t1, num_cartas_dealer
    lw t2, 0(t1)
    li t3, 0

exibir_mao_dealer_loop:
    bge t3, t2, exibir_mao_dealer_total
    add t4, t0, t3
    lb t5, 0(t4)
    mv a0, t5
    li a7, 1
    ecall

    addi t3, t3, 1
    bge t3, t2, exibir_mao_dealer_total

    li a7, 11
    li a0, '+'
    ecall

    j exibir_mao_dealer_loop

exibir_mao_dealer_total:
    li a7, 4
    la a0, str_igual
    ecall

    la t6, total_dealer
    lw a0, 0(t6)
    li a7, 1
    ecall

    li a7, 11
    li a0, 10
    ecall
    ret

exibir_mao_dealer_oculta:
    # Mostra só a primeira carta do dealer e oculta a outra
    li a7, 4
    la a0, str_mao_dealer
    ecall

    la t0, mao_dealer
    lb t1, 0(t0)
    mv a0, t1
    li a7, 1
    ecall

    li a7, 4
    la a0, str_carta_oculta
    ecall

    li a7, 11
    li a0, 10
    ecall
    ret

exibir_placar:
    # Mostra o placar e cartas restantes
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

    li a7, 11
    li a0, 10 #ascii \n
    ecall

    li a7, 4
    la a0, cartas_restantes
    ecall

    la t0, contador_cartas
    lw t1, 0(t0)
    li a0, 52
    sub a0, a0, t1
    li a7, 1 
    ecall

    li a7, 11
    li a0, 10 #ascii \n
    ecall

    ret

# =============== FINAIS ===============

compara_finais:
    # Compara as mãos e determina o vencedor
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
    # Pergunta se o player quer jogar novamente ou sair
    jal exibir_placar
    li a7, 4
    la a0, reinicio
    ecall

    li a7, 5      
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
    # Zera variáveis para nova rodada
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
    # Zera o baralho quando acaba as cartas
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
    # Exibe cartas sorteadas e encerra o programa
    jal exibir_cartas_sorteadas
    li a7, 4
    la a0, sair
    ecall
    li a7, 10
    ecall

exibir_cartas_sorteadas:
    # Mostra quantas vezes cada carta saiu ao encerrar o jogo
    li a7, 4
    la a0, str_cartas_sorteadas
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
    li a0, 32 # tabela ascii espaço
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
    # Zera a memória da mão (limpa todas as cartas)
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

# ==================== CÁLCULO DO TOTAL DA MÃO ====================

calcula_total_mao:
    # Soma o valor das cartas da mão, tratando ases como 11 ou 1
    lw t0, 0(a1)                 # t0 = número de cartas
    mv t1, a0                    # t1 = endereço da mão
    li t2, 0                     # t2 = soma total
    li t3, 0                     # t3 = quantidade de ases
    li t4, 0                     # t4 = índice

soma_mao_loop:
    bge t4, t0, ajusta_ases
    add t5, t1, t4
    lb t6, 0(t5)
    li a3, 1
    beq t6, a3, achou_as         # se for as, trata depois
    li a3, 11
    blt t6, a3, soma_normal      # se for < 11, soma normal
    li t6, 10                    # se for J, Q, K, trata como 10

soma_normal:
    add t2, t2, t6
    addi t4, t4, 1
    j soma_mao_loop

achou_as:
    addi t2, t2, 11              # as conta como 11 inicialmente
    addi t3, t3, 1               # conta um as
    addi t4, t4, 1
    j soma_mao_loop

ajusta_ases:
    # Ajusta ases de 11 para 1 se o total passou de 21
    li a3, 21
    ble t2, a3, fim_calcula      # se total <= 21, termina
    blez t3, fim_calcula         # se não tem mais ases pra ajustar, termina
    addi t2, t2, -10             # troca um Ás de 11 para 1 (reduz 10 do total)
    addi t3, t3, -1              # um as foi ajustado
    j ajusta_ases

fim_calcula:
    sw t2, 0(a2)                 # salva o total calculado
    ret
