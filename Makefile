makeAll:
	bison -d bison.y
	flex flex.l
	gcc bison.tab.c lex.yy.c -lfl

run:
	./a.out < test.txt

clean:
	rm a.out bison.tab.c lex.yy.c bison.tab.h -r -f