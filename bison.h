#include <stdlib.h>
#include <stdio.h>

struct symbol_table_node {
    char name[1000];
    char address[1000];
    struct symbol_table_node* next;
};

struct ASTNode {
    int num_children;
    struct ASTNode** children;
    int symbol_table_entries;
    struct symbol_table_node** tptr;
    int value;
    int type;
};

struct symbol_table_node* get_from_symbol_table(char *name);
struct symbol_table_node* put_in_symbol_table(char *name);
struct ASTNode* makeNewNode(int num_children, int symbol_table_entries, int type);
void generateCode(struct ASTNode* astNode);