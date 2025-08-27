#include "Circulo.h"
#include <stack>
#include <vector>
#include <iostream>

using namespace std;

class Pilha {
private:

    vector<int> vetor = {6,7};
    stack<int> numPilha;

public:
    Pilha() {
        for (int v : {1, 2, 3, 4, 5}) {
            numPilha.push(v);
        }

        cout << "Pilha iniciada: " << numPilha.top();

        for (int v : vetor) {
            numPilha.push(v);
        }

        cout << "\nAdicionado os numeros do vetor a pilha";
    }

    void imprime() {
        while (!numPilha.empty() && numPilha.size() > 4) {
                cout << "\nNumero atual: " << numPilha.top();
                numPilha.pop();
        }

    }
};

int main() {    
    Pilha p;
    p.imprime();

    return 0;
}
