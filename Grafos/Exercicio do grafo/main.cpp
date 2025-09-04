#include "Grafo.h"
#include "Aresta.h"
#include <iostream>

using namespace std;

int main() {

    
    try
    {
        Grafo g1(6);
        g1.imprime_grafo();

        Aresta e(0, 5);
        g1.insere_aresta(e);
        g1.insere_aresta(Aresta(2,4));
        g1.imprime_grafo();

        // cout << "\nDigite o número de vértices: "
        // cin >> num_vertice
    }
    catch(const std::exception& e)
    {
        std::cerr << e.what() << '\n';
    }
    

    
    return(0);
}
