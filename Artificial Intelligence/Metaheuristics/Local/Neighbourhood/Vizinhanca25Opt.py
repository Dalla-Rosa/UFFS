import math
from Search_Heuristics.Local.Neighbourhood.Vizinhanca import Vizinhanca
from Search_Heuristics.Solucao import Solucao

class Vizinhanca25opt(Vizinhanca):
    def __init__(self, distancias: tuple[tuple[int]]):
        super().__init__("2.5-Opt", distancias, 3)

    def make_25_opt_move(self, tour: list, i: int, j: int, tipo: str):
        if tipo == "2-opt":
            tour[i+1:j+1] = reversed(tour[i+1:j+1])
        elif tipo == "node-shift":
            node = tour[i+1]
            del tour[i+1]
            tour.insert(j, node)

    def gain_from_25_opt(self, X1, X2, Y1, Y2, V0=None) -> int:
        del_2_length = self.distancias[X1][X2] + self.distancias[Y1][Y2]
        dX1Y1 = self.distancias[X1][Y1]
        dX2Y2 = self.distancias[X2][Y2]
        
        if del_2_length - (dX1Y1 + dX2Y2) > 0:
            return "2-opt", del_2_length - (dX1Y1 + dX2Y2)
        
        if V0 is not None:
            dX2Y1 = self.distancias[X2][Y1]
            if (del_2_length + self.distancias[X2][V0]) - (dX2Y2 + dX2Y1 + self.distancias[X1][V0]) > 0:
                return "node-shift", (del_2_length + self.distancias[X2][V0]) - (dX2Y2 + dX2Y1 + self.distancias[X1][V0])
        
        return None, 0

    def computar_qualidade(self, solucao: Solucao, i: int, j: int) -> tuple:
        qualidade = solucao.qualidade
        X1, X2 = solucao.ciclo[i], solucao.ciclo[(i+1) % len(solucao.ciclo)]
        Y1, Y2 = solucao.ciclo[j], solucao.ciclo[(j+1) % len(solucao.ciclo)]
        V0 = solucao.ciclo[(i+2) % len(solucao.ciclo)]

        tipo, ganho = self.gain_from_25_opt(X1, X2, Y1, Y2, V0)
        return qualidade - ganho, tipo

    def melhor_vizinho(self, solucao: Solucao, tabu: set) -> Solucao:
        melhor_qualidade = solucao.qualidade
        melhor_i, melhor_j = -1, -1
        melhor_tipo = None
        
        for i in range(len(solucao.ciclo) - 2):
            if solucao.ciclo[i] not in tabu:
                for j in range(i + 2, len(solucao.ciclo)):
                    if solucao.ciclo[j] not in tabu:
                        qualidade, tipo = self.computar_qualidade(solucao, i, j)
                        if tipo and qualidade < melhor_qualidade:
                            melhor_qualidade = qualidade
                            melhor_i, melhor_j = i, j
                            melhor_tipo = tipo
        
        if melhor_tipo is None:
            print("Nenhum vizinho melhor encontrado.") # um controle caso ele não encontrasse um vizinho melhor
            return solucao  

        novo_tour = solucao.ciclo[:]
        self.make_25_opt_move(novo_tour, melhor_i, melhor_j, melhor_tipo)
        return Solucao(melhor_qualidade, novo_tour, novo_tour[melhor_i], novo_tour[melhor_j])

    def primeiro_vizinho_melhor(self, solucao: Solucao, tabu: set) -> Solucao:
        for i in range(len(solucao.ciclo) - 2):
            if solucao.ciclo[i] not in tabu:
                for j in range(i + 2, len(solucao.ciclo)):
                    if solucao.ciclo[j] not in tabu:
                        qualidade, tipo = self.computar_qualidade(solucao, i, j)
                        if tipo and qualidade < solucao.qualidade:
                            novo_tour = solucao.ciclo[:]
                            self.make_25_opt_move(novo_tour, i, j, tipo)
                            return Solucao(qualidade, novo_tour, novo_tour[i], novo_tour[j])
        return solucao  
