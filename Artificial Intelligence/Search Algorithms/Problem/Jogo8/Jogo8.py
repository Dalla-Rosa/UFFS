import random

from Search_Algorithms.Problem.Jogo8.Complexidade import Complexidade
from Search_Algorithms.Problem.Jogo8.Acao import Acao
from Search_Algorithms.Problem.Jogo8.Estado import Estado


class Jogo8:
    def __init__(self, tamanho: int, complexidade: Complexidade):
        self.estado_final: Estado = Estado(tamanho)
        self.complexidade: Complexidade = complexidade
        self.estado_inicial: Estado = self.criar_jogo()
        self.estado_atual: Estado = self.estado_inicial

    @staticmethod
    def transicao(estado: Estado, acao: Acao, copia: bool = True) -> Estado:
        novo_estado = Jogo8.copiar_estado(estado) if copia else estado
        aux = 0
        if acao == Acao.Cima:
            if estado.vazio in range(estado.tamanho):
                return novo_estado
            else:
                aux = novo_estado.vazio - estado.tamanho
        elif acao == Acao.Baixo:
            if estado.vazio in range(estado.tamanho ** 2 - 1, estado.tamanho ** 2 - 1 - estado.tamanho, -1):
                return novo_estado
            else:
                aux = novo_estado.vazio + estado.tamanho
        elif acao == Acao.Direita:
            if estado.vazio in range(estado.tamanho - 1, estado.tamanho ** 2, estado.tamanho):
                return novo_estado
            else:
                aux = novo_estado.vazio + 1
        elif acao == Acao.Esquerda:
            if estado.vazio in range(0, estado.tamanho ** 2, estado.tamanho):
                return novo_estado
            else:
                aux = novo_estado.vazio - 1
        novo_estado.tabuleiro[novo_estado.vazio] = novo_estado.tabuleiro[aux]
        novo_estado.tabuleiro[aux] = 0
        novo_estado.vazio = aux
        return novo_estado

    @staticmethod
    def copiar_estado(estado: Estado) -> Estado:
        novo_estado = Estado(estado.tamanho, True)
        novo_estado.tabuleiro = estado.tabuleiro.copy()
        novo_estado.vazio = estado.vazio
        return novo_estado

    def criar_jogo(self) -> Estado:
        novo_estado = Jogo8.copiar_estado(self.estado_final)
        for _ in range(novo_estado.tamanho ** self.complexidade.value):
            acao = random.randrange(len(Acao))
            novo_estado = Jogo8.transicao(novo_estado, Acao(acao), False)
        return novo_estado
