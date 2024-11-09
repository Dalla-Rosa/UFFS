from Search_Algorithms.Algorithm.Astar import Astar
from Search_Algorithms.Algorithm.BFS import BFS
from Search_Algorithms.Heuristics.Heuristica import Heuristic1, Heuristic2
from Search_Algorithms.Problem.Jogo8.Complexidade import Complexidade
from Search_Algorithms.Problem.Jogo8.Jogo8 import Jogo8


c = Complexidade.Dificil
i = 3
for _ in range(50):
    instancia = Jogo8(i, c)
    print(instancia.estado_inicial)
    print(c.name)

    algoritmos = [Astar(instancia.estado_inicial, instancia.estado_final, Heuristic2(instancia.estado_final)),
                  Astar(instancia.estado_inicial, instancia.estado_final, Heuristic1(instancia.estado_final)),
                  BFS(instancia.estado_inicial, instancia.estado_final)]

    for alg in algoritmos:
        alg.encontrar_solucao()
        print(f"\n{alg.nome}")
        print(f"Solução Ótima: {alg.solucao}")
        print(f"Custo da S*: {len(alg.solucao)}")
        print(f"Tempo de execução: {alg.tempo_execucao:.3f}s")
        print(f"Fator de Ramificação Médio: {(alg.ramificacao/alg.estados_analisados):.2f}")
        print(f"Quantidade de estados analisados: {alg.estados_analisados}")
