%{
    #include "bison.h"
    #include "bison.tab.h"
    int addr = 0;
    struct symbol_table_node* symbol_table = NULL;    
%}

number [0-9]+
variable  [a-zA-Z_]+

%%

"while" { return WHILE;}

"if" { return IF;}

"else" { return ELSE;}

"for" { return FOR; }

"|" { return PIPE;}

"startdecl" { return STARTDECL;} 

"enddecl" { return ENDDECL;} 

";" { return SEMICOLON; }

"decl" { return DECL; }

{number} {
    sscanf(yytext,"%d",&yylval.value);
    return NUMBER;
}

{variable} {
    struct symbol_table_node* s = put_in_symbol_table(yytext);
    yylval.tptr = s;
    return VARIABLE;
}

"+" { return PLUS;}

"-" { return MINUS;}

"/" { return DIVIDE; }
 
"*" { return MULTIPLY; }

"=" { return EQUAL;}

"<" { return LESSTHAN; }

"(" { return OPENROUNDBRACE; }

")" { return CLOSEROUNDBRACE; }

"{"  { return OPENCURLYBRACE; }

"}"  { return CLOSECURLYBRACE; }

"[" { return OPENSQUAREBRACE;}

"]" { return CLOSESQUAREBRACE; }

"\n"|"\r\n"|"\t"|" " {  }

.  { printf("Error..."); }

%%

struct symbol_table_node* get_from_symbol_table(char* name){
    struct symbol_table_node* temp = symbol_table;
    while(temp!=NULL){
        if(strcmp(temp->name, name)==0) return temp;
        temp=temp->next;
    }
    return NULL;
}

struct symbol_table_node* put_in_symbol_table(char* name){
    struct symbol_table_node* node = get_from_symbol_table(name);
    if(node!=NULL) return node;
    node = (struct symbol_table_node*)malloc(sizeof(struct symbol_table_node));
    strcpy(node->name, name);
    char address[1000];
    sprintf(address, "%d", addr);
    addr = addr + 4;
    strcpy(node->address, address);
    node->next = symbol_table;
    symbol_table = node;
    return node;
}

