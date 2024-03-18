
struct att{
    int id_arquivo_att;
    char nome_att[20];
    char tipo;
    char opcional;
    int tamanho;
}; typedef struct att atributo;

int readFile(char nomeLog[20]);
