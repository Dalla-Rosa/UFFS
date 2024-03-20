#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_NAME_LENGTH 20
#define MAX_ATTRIBUTES 10
#define MAX_ATTRIBUTE_NAME_LENGTH 20
#define MAX_LINE_LENGTH 1024

typedef struct {
    int id;
    char logical_name[MAX_NAME_LENGTH];
    char physical_name[MAX_NAME_LENGTH];
} TableEntry;

typedef struct {
    int id;
    char att_name[MAX_ATTRIBUTE_NAME_LENGTH];
    char type;
    char mandatory;
    int size;
} AttributeEntry;

void readTableData(char *logicalTableName, TableEntry *tableData) {
    FILE *file = fopen("table.dic", "rb");
    if (file == NULL) {
        printf("Error: Could not open table.dic\n");
        exit(1);
    }

    while (fread(tableData, sizeof(TableEntry), 1, file) == 1) {
        if (strcmp(tableData->logical_name, logicalTableName) == 0) {
            fclose(file);
            return;
        }
    }

    fclose(file);
    printf("Logical table name not found in table.dic\n");
    exit(1);
}

void readAttributeData(AttributeEntry *attributeData, int tableId, int *numAttributes) {
    FILE *file = fopen("att.dic", "rb");
    if (file == NULL) {
        printf("Error: Could not open att.dic\n");
        exit(1);
    }

    *numAttributes = 0;
    while (fread(&attributeData[*numAttributes], sizeof(AttributeEntry), 1, file) == 1) {
        if (attributeData[*numAttributes].id == tableId) {
            (*numAttributes)++;
            if (*numAttributes >= MAX_ATTRIBUTES) {
                printf("Error: Too many attributes in att.dic\n");
                exit(1);
            }
        }
    }

    fclose(file);
}

void readData(char *fileName, AttributeEntry *attributeData, int numAttributes) {
    FILE *file = fopen(fileName, "rb");
    if (file == NULL) {
        printf("Error: Could not open data file\n");
        exit(1);
    }

    // Print header box
    printf("╔");
    for (int i = 0; i < numAttributes; i++) {
        for (int j = 0; j < attributeData[i].size + 2; j++) {
            printf("═");
        }
        if (i < numAttributes - 1) {
            printf("╦");
        }
    }
    printf("╗\n");

    // Print attribute names
    printf("║");
    for (int i = 0; i < numAttributes; i++) {
        printf(" %-*s ║", attributeData[i].size, attributeData[i].att_name);
    }
    printf("\n");

    // Print header box
    printf("╠");
    for (int i = 0; i < numAttributes; i++) {
        for (int j = 0; j < attributeData[i].size + 2; j++) {
            printf("═");
        }
        if (i < numAttributes - 1) {
            printf("╬");
        }
    }
    printf("╣\n");

    // Read and print data
    while (!feof(file)) {
        printf("║");
        for (int i = 0; i < numAttributes; i++) {
            switch (attributeData[i].type) {
                case 'I': {
                    int intValue;
                    fread(&intValue, sizeof(int), 1, file);
                    printf(" %*d ║", attributeData[i].size - 1, intValue);
                    break;
                }
                case 'D': {
                    double doubleValue;
                    fread(&doubleValue, sizeof(double), 1, file);
                    printf(" %*.*lf ║", attributeData[i].size - 1, 6, doubleValue);
                    break;
                }
                case 'S': {
                    char stringValue[MAX_LINE_LENGTH];
                    fread(stringValue, attributeData[i].size, 1, file);
                    stringValue[attributeData[i].size] = '\0'; // Null-terminate the string
                    printf(" %-*s ║", attributeData[i].size - 1, stringValue);
                    break;
                }
                default:
                    printf("Unknown type\n");
                    break;
            }
        }
        printf("\n");
    }

    // Print footer box
    printf("╚");
    for (int i = 0; i < numAttributes; i++) {
        for (int j = 0; j < attributeData[i].size + 2; j++) {
            printf("═");
        }
        if (i < numAttributes - 1) {
            printf("╩");
        }
    }
    printf("╝\n");

    fclose(file);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <logical_table_name>\n", argv[0]);
        return 1;
    }

    char *logicalTableName = argv[1];
    TableEntry tableData;
    readTableData(logicalTableName, &tableData);

    AttributeEntry attributeData[MAX_ATTRIBUTES];
    int numAttributes;
    readAttributeData(attributeData, tableData.id, &numAttributes);

    readData(tableData.physical_name, attributeData, numAttributes);

    return 0;
}
