#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_NAME_LENGTH 20
#define MAX_ATTRIBUTES 10
#define MAX_ATTRIBUTE_NAME_LENGTH 20

typedef struct {
    int table_id;
    char name[MAX_NAME_LENGTH];
    char physical_name[MAX_NAME_LENGTH];
} TableEntry;

typedef struct {
    int table_id;
    char name[MAX_ATTRIBUTE_NAME_LENGTH];
    char type;
    char optional;
    int size;
} AttributeEntry;

int readTableDic(TableEntry *tableDic) {
    FILE *file = fopen("table.dic", "r");
    if (file == NULL) {
        printf("Error: Could not open table.dic\n");
        exit(1);
    }
    printf("entrou\n");
    int numTables = 0;
    while (fscanf(file, "<%d, \"%19[^\"]\", \"%19[^\"]\">\n", &tableDic[numTables].table_id, tableDic[numTables].name, tableDic[numTables].physical_name) == 3) {
        printf("%d \n", numTables);
        numTables++;
        if (numTables >= MAX_NAME_LENGTH) {
            printf("Error: Too many entries in table.dic\n");
            exit(1);
        }
    }

    fclose(file);
    return numTables;
}

void readAttributeDic(AttributeEntry *attributeDic, int *numAttributes, int tableId) {
    FILE *file = fopen("att.dic", "r");
    if (file == NULL) {
        printf("Error: Could not open att.dic\n");
        exit(1);
    }

    *numAttributes = 0;
    while (fscanf(file, "<%d, \"%19[^\"]\", '%c', '%c', %d>\n", &attributeDic[*numAttributes].table_id, attributeDic[*numAttributes].name, &attributeDic[*numAttributes].type, &attributeDic[*numAttributes].optional, &attributeDic[*numAttributes].size) == 5) {
        if (attributeDic[*numAttributes].table_id == tableId) {
            (*numAttributes)++;
            if (*numAttributes >= MAX_ATTRIBUTES) {
                printf("Error: Too many attributes in att.dic\n");
                exit(1);
            }
        }
    }

    fclose(file);
}

void readData(char *fileName, AttributeEntry *attributeDic, int numAttributes) {
    FILE *file = fopen(fileName, "r");
    if (file == NULL) {
        printf("Error: Could not open data file\n");
        exit(1);
    }

    while (!feof(file)) {
        for (int i = 0; i < numAttributes; i++) {
            char data[MAX_NAME_LENGTH];
            if (fread(data, 1, attributeDic[i].size, file) != attributeDic[i].size) {
                printf("Error reading data file\n");
                exit(1);
            }
            data[attributeDic[i].size] = '\0';
            printf("%s ", data);
        }
        printf("\n");
    }

    fclose(file);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <logical_table_name>\n", argv[0]);
        return 1;
    }

    char *logicalTableName = argv[1];
    TableEntry tableDic[MAX_NAME_LENGTH];
    int numTables = readTableDic(tableDic);

    int tableId = -1;
    for (int i = 0; i < numTables; i++) {
        printf("%d \n", tableDic[i].table_id);
        if (strcmp(tableDic[i].name, logicalTableName) == 0) {
            tableId = tableDic[i].table_id;
            break;
        }
    }

    if (tableId == -1) {
        printf("Logical table name not found in table.dic\n");
        return 1;
    }

    AttributeEntry attributeDic[MAX_ATTRIBUTES];
    int numAttributes;
    readAttributeDic(attributeDic, &numAttributes, tableId);

    if (numAttributes == 0) {
        printf("No attributes found for table %s\n", logicalTableName);
        return 1;
    }

    readData(tableDic[tableId - 1].physical_name, attributeDic, numAttributes);

    return 0;
}