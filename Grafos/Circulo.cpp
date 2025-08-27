#include <iostream>
#include "Circulo.h"


using namespace std;

Circulo::Circulo(double raio) {
  raio_ = raio;
}

double Circulo::calcula_area() {
    return 3.14 * (raio_ * raio_);
}

void Circulo::imprime_area() {
    cout << calcula_area() << "\n";  
};
