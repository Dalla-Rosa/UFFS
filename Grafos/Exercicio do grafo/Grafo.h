#ifndef GRAFO_H
#define GRAFO_H 
#include <vector>
#include "Aresta.h"

class Grafo {
public:
 /*Constroi o grafo com número de vertices recebido e nenhuma aresta*/
    Grafo(int num_vertices);
    // ~Grafo(int num_vertices); é um destructor
     
    int num_vertices();
    int num_arestas();

    bool tem_aresta(Aresta e);

    void insere_aresta(Aresta e);
    void remove_aresta(Aresta e);
    void imprime_grafo();

private:
    int num_vertices_;
    int num_arestas_;
    std::vector<std::vector<int>> matriz_adj_;
};

#endif