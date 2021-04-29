%{
    #include "bison.h" 
    int yylex(void);
    int yyparse(void);
    void yyerror(char* error);       
    int label;
    int reg;
    struct ASTNode* astNode;
    FILE* fp;
%}

%union {
    struct symbol_table_node* tptr;
    struct ASTNode* astNode;
    int value;
}

%type <astNode> STATEMENTS STATEMENT EXPRESSION X DECLARELIST
%token <tptr> VARIABLE
%token <value> NUMBER
%token LESSTHAN WHILE OPENCURLYBRACE OPENROUNDBRACE CLOSECURLYBRACE CLOSEROUNDBRACE EQUAL PLUS MINUS MULTIPLY DIVIDE IF ELSE FOR PIPE OPENSQUAREBRACE CLOSESQUAREBRACE STARTDECL ENDDECL SEMICOLON DECL

%% 


PROGRAM: STATEMENTS {
    astNode = $1;
}

STATEMENTS: %empty {
    $$ = NULL;
}
| STATEMENT STATEMENTS  {
    $$ = makeNewNode(2, 0, 10);
    $$->children[0] = $1;
    $$->children[1] = $2;
}

STATEMENT: WHILE OPENROUNDBRACE VARIABLE LESSTHAN VARIABLE CLOSEROUNDBRACE OPENCURLYBRACE STATEMENTS CLOSECURLYBRACE  {
    $$ = makeNewNode(1, 2, 9);
    $$->children[0] = $8;
    $$->tptr[0] = $3;    
    $$->tptr[1] = $5;    
} 
| IF OPENROUNDBRACE VARIABLE LESSTHAN VARIABLE CLOSEROUNDBRACE OPENCURLYBRACE STATEMENTS CLOSECURLYBRACE ELSE OPENCURLYBRACE STATEMENTS CLOSECURLYBRACE {
    $$ = makeNewNode(2, 2, 11);
    $$->children[0] = $8;
    $$->children[1] = $12;
    $$->tptr[0] = $3;
    $$->tptr[1] = $5;
}
| FOR OPENROUNDBRACE VARIABLE EQUAL EXPRESSION PIPE VARIABLE LESSTHAN VARIABLE PIPE VARIABLE EQUAL EXPRESSION CLOSEROUNDBRACE OPENCURLYBRACE STATEMENTS CLOSECURLYBRACE {
    $$ = makeNewNode(3, 4, 12);
    $$->children[0] = $5;
    $$->children[1] = $13;
    $$->children[2] = $16;
    $$->tptr[0] = $3;    
    $$->tptr[1] = $7;
    $$->tptr[2] = $9;
    $$->tptr[3] = $11; 
}
| VARIABLE EQUAL EXPRESSION {
    $$ = makeNewNode(1, 1, 8); 
    $$->children[0] = $3; 
    $$->tptr[0] = $1;    
}
| VARIABLE OPENSQUAREBRACE VARIABLE CLOSESQUAREBRACE EQUAL EXPRESSION {
    $$ = makeNewNode(1, 2, 14);
    $$->tptr[0] = $1;
    $$->tptr[1] = $3;    
    $$->children[0] = $6;
}
| STARTDECL DECLARELIST ENDDECL {
    $$ = $2;
}

DECLARELIST: DECL VARIABLE OPENSQUAREBRACE NUMBER CLOSESQUAREBRACE SEMICOLON DECLARELIST {
    $$ = makeNewNode(1, 1, 15);
    $$->children[0] = $7;
    $$->tptr[0] = $2;
    $$->value = $4;
}
| %empty {
    $$ = NULL;
}

EXPRESSION: X  { $$ = makeNewNode(0, 0, 3); $$->children[0] = $1; }
| X PLUS X {
    $$ = makeNewNode(2, 0, 4);
    $$->children[0] = $1;
    $$->children[1] = $3;
}
| X MINUS X {
    $$ = makeNewNode(2, 0, 5);
    $$->children[0] = $1;
    $$->children[1] = $3;
}
| X MULTIPLY X {
    $$ = makeNewNode(2, 0, 6);
    $$->children[0] = $1;
    $$->children[1] = $3;
}
| X DIVIDE X {
    $$ = makeNewNode(2, 0, 7);
    $$->children[0] = $1;
    $$->children[1] = $3;
}
| VARIABLE OPENSQUAREBRACE VARIABLE CLOSESQUAREBRACE {
    $$ = makeNewNode(0,2,13);
    $$->tptr[0] = $1;
    $$->tptr[1] = $3;    
}

X: VARIABLE {
    $$ = makeNewNode(0, 1, 2);
    $$->tptr[0] = $1;
}
| NUMBER { 
     $$ = makeNewNode(0, 0, 1);
     $$->value = $1;
}

%%


struct ASTNode* makeNewNode(int num_children, int symbol_table_entries, int type){
    struct ASTNode* newNode = (struct ASTNode*)malloc(sizeof(struct ASTNode));
    newNode->num_children = num_children;
    newNode->symbol_table_entries = symbol_table_entries;
    newNode->children = (struct ASTNode**)malloc(sizeof(struct ASTNode*)*newNode->num_children);
    newNode->tptr = (struct symbol_table_node**)malloc(sizeof(struct symbol_table_node*)*newNode->symbol_table_entries);
    newNode->type = type;
    return newNode;
}

void yyerror(char* error){
    printf("%s\n", error);
}

int main(void){
    label = 0;
    reg = 0;
    astNode = NULL;
    fp = fopen("out.asmb", "w+");
    fprintf(fp,".data\n.text\nli $t8,268500992\n");
    yyparse();
    generateCode(astNode);
    fprintf(fp,"li $v0,1\nmove $a0,$t0\nsyscall");
    return 0;
}

void generateCode(struct ASTNode* astNode){
    if(astNode==NULL) return;
    if(astNode->type==1){
        fprintf(fp, "li $t%d,%d\n", reg, astNode->value);  reg = 1 - reg;
    } else if(astNode->type == 2){
        fprintf(fp, "lw $t%d,%s($t8)\n", reg, astNode->tptr[0]->address);  reg = 1 - reg;
    } else if(astNode->type == 3){
        generateCode(astNode->children[0]);
        reg = 1 - reg;
    } else if(astNode->type == 4){
        generateCode(astNode->children[0]);
        generateCode(astNode->children[1]);
        fprintf(fp,"add $t0,$t0,$t1\n");
    } else if(astNode->type == 5){
        generateCode(astNode->children[0]);
        generateCode(astNode->children[1]);
        fprintf(fp,"sub $t0,$t0,$t1\n");
    } else if(astNode->type == 6){
        generateCode(astNode->children[0]);
        generateCode(astNode->children[1]);
        fprintf(fp,"mul $t0,$t0,$t1\n");
    } else if(astNode->type == 7){
        generateCode(astNode->children[0]);
        generateCode(astNode->children[1]);
        fprintf(fp,"div $t0,$t0,$t1\n");
    } else if(astNode->type == 8){
        generateCode(astNode->children[0]);
        fprintf(fp,"sw $t0,%s($t8)\n", astNode->tptr[0]->address);
    } else if(astNode->type == 9){
        int label1 = ++label;        
        fprintf(fp,"while_condition_%d:\n", label1);            
        fprintf(fp,"lw $t0,%s($t8)\n", astNode->tptr[0]->address);
        fprintf(fp,"lw $t1,%s($t8)\n", astNode->tptr[1]->address);
        fprintf(fp,"bge $t0,$t1,while_end_%d\n", label1);
        generateCode(astNode->children[0]);
        fprintf(fp,"j while_condition_%d\n",label1);
        fprintf(fp,"while_end_%d:\n", label1);
    } else if(astNode->type == 10) {
        generateCode(astNode->children[0]);
        generateCode(astNode->children[1]);
    } else if(astNode->type == 11){
        int label1 = ++label; 
        fprintf(fp,"lw $t0,%s($t8)\n", astNode->tptr[0]->address);
        fprintf(fp,"lw $t1,%s($t8)\n", astNode->tptr[1]->address);
        fprintf(fp,"bge $t0,$t1,else_part_%d\n", label1);
        generateCode(astNode->children[0]);
        fprintf(fp,"j outer_part_ifelse_%d\n",label1);
        fprintf(fp,"else_part_%d:\n", label1);
        generateCode(astNode->children[1]);
        fprintf(fp,"outer_part_ifelse_%d:\n", label1);
    } else if(astNode->type == 12) {
        int label1 = ++label;
        generateCode(astNode->children[0]);        
        fprintf(fp,"sw $t0,%s($t8)\n",astNode->tptr[0]->address);
        fprintf(fp,"for_condition_%d:\n",label1);
        fprintf(fp,"lw $t0,%s($t8)\n", astNode->tptr[1]->address);
        fprintf(fp,"lw $t1,%s($t8)\n", astNode->tptr[2]->address);
        fprintf(fp,"bge $t0,$t1,outer_part_for_%d\n", label1);
        generateCode(astNode->children[2]);
        generateCode(astNode->children[1]);
        fprintf(fp,"sw $t0,%s($t8)\n",astNode->tptr[3]->address);
        fprintf(fp,"j for_condition_%d\n", label1);
        fprintf(fp,"outer_part_for_%d:\n", label1);
    } else if(astNode->type == 13){                        
        fprintf(fp, "lw $t1,%s($t8)\n", astNode->tptr[0]->address);
        fprintf(fp, "lw $t2,%s($t8)\n", astNode->tptr[1]->address);
        fprintf(fp,"sll $t2,$t2,2\n"); // calcuate offest (x4)
        fprintf(fp,"add $t2,$t2,$t1\n"); // base + offest
        fprintf(fp,"lw $t0,0($t2)\n"); //store result of expression to array
    } else if(astNode->type == 14){         
        generateCode(astNode->children[0]);       
        fprintf(fp,"lw $t1,%s($t8)\n",astNode->tptr[0]->address); // Store base address in $t1
        fprintf(fp,"lw $t2,%s($t8)\n",astNode->tptr[1]->address);
        fprintf(fp,"sll $t2,$t2,2\n"); // calcuate offest (x4)
        fprintf(fp,"add $t2,$t2,$t1\n"); // base + offest
        fprintf(fp,"sw $t0,0($t2)\n"); //store result of expression to array
    } else {                
        fprintf(fp, "subu $sp,$sp,%d\n", (astNode->value)*4);
        fprintf(fp, "sw $sp,%s($t8)\n", astNode->tptr[0]->address);
        generateCode(astNode->children[0]);
    }
}