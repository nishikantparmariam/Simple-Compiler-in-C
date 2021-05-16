makeAll:
	bison -d bison.y
	flex flex.l
	gcc bison.tab.c lex.yy.c -lfl

test1:
	./a.out < sample1.prog
	
test2:
	./a.out < sample2.prog	

clean:
	rm a.out bison.tab.c lex.yy.c bison.tab.h -r -f
