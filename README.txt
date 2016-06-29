How to compile:
	Being in "compilers" folder, type "make" or "make tonyc" and the press ENTER.
	If you type "make clean", all automatically produced files except tonyc executable are deleted.
	If you type "make distclean", the result is the same with "make clean" except that tonyc executable is deleted too.

How to run:
	Our compiler follows instructions from the last page from tony2015.pdf, except that no optimization flag (-o) has been implemented. Example testcases in Tony language can be found in compilisers/scripts/Correct folder. You have the following choices in order to use our compiler: 
	1) If you want to give our compiler a tony file as an argument, you can type for example
		./tonyc ./scripts/Correct/test1.tony
	  This will produce test1.imm and test1.asm files in the folder where test1.tony is located.

	2) If you want to give our compiler either the option -i, then you type
		./tonyc -i
	  In this case our compiler expects a tony program in standard input and produces the relevant quads in standard output. The quads are shown in standard output only when the whole program has been given and ENTER is pressed. The execution of our compiler then stops if you press "Ctrl+d", which represents EOF.

	3) If you want to give our compiler either the option -f, then you type
		./tonyc -f
	  In this case our compiler expects a tony program in standard input and produces the relevant final code in standard output. The final code is shown in standard output only when the whole program has been given, ENTER is pressed and finally "Ctrl+d" is pressed as well to represent EOF.

You can also use our do.sh script in "scripts" folder to test the final code that is produced by our compiler, using dosbox. In this case, being in "scripts" folder you can type for example ./do.sh ./Correct/test1.tony. The .imm and .asm files are produced in "scripts" folders as "a.imm" and "a.asm" respectively.