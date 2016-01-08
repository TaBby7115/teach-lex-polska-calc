%{
/*
This file is part of Reverse Notation Calc.

    Reverse Notation Calc is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

*/

#include "mystack.h"
int int_value;

#define TYPE_NUMBER 50545
#define TYPE_SET 5454.454

typedef enum {
    LexNumber=1001,
    LexPlus,
    LexMinus,
    LexDiv,
    LexMult,
    LexEnd,
    LexUnknown,
	LexSet,
    LexEntry,
    LexEntersection,
} LexType;

my_stack stack;

double value;
int k;
int end_file;
double set[100];
double set2[100];
int j,k;
%}

%s SKIPERROR

digit     [0-9]
number    (-?{digit}+\.?{digit}*)+
set     \[({number}(\,{number})*)?\]

%%

{set} {		  
		  fprintf(stderr, "found set\n");}
{set}.{number}.\? 	{
		  	char *i = yytext;
		  	j = 0;
		  	while (*i != ']') {
		   		if (isdigit(*i)) {
	      				if(*(i-1) != '-') {
	        				set[j] = strtod(i, &i);}
	      				else {
	       					set[j] = strtod(i, &i) * -1;}
	    						if(isinteger(set[j])){
	    	  						fprintf(stderr, "found \"%d\" from set\n", (int)set[j]);}
	     						else {
	    	  						fprintf(stderr, "found \"%.2f\" from set\n", set[j]);}
		  						j++;
			 				}
			 	else {
			  		i++;
			 		}
		  		}
	    		while (*i) {
		     		if (isdigit(*i)) {
	     	   			if(*(i-1) != '-') {
			   			set[j] = strtod(i, &i);}
			 		else {
			   			set[j] = strtod(i, &i) * -1;}
			 			if(isinteger(set[j])){
		     	     				fprintf(stderr, "found \"%d\" to add to set\n", (int)set[j]);}
		     	   			else{
		     	     				fprintf(stderr, "found \"%.2f\" to add to set\n", set[j]);}
		     	   			j++;
			     		}
			     	else {
			    		i++;
			     	}
		   	}	  
		  	return LexEntry;}

{set}.{set}.\* {
		   	char* i = yytext;
		  	j = 0;
			k=0;
		  	while (*i != ']') {
		    		if(isdigit(*i)){
		      			if(*(i-1) != '-') {
		      				set[j] = strtod(i, &i);}
		      			else {
		        			set[j] = strtod(i, &i) * -1;}
		      				if(isinteger(set[j])){
		        				fprintf(stderr, "found \"%d\" from 1st set\n", (int)set[j]);}
		      				else {
		        				fprintf(stderr, "found \"%.2f\" from 1st set\n", set[j]);}
		      				j++;}
		    		else {
		      			i++;}
		  	}
		  	i++;
		  	while (*i != ']') {
		    		if(isdigit(*i)){
		      			if(*(i-1) != '-') {
		      				set2[k] = strtod(i, &i);}
		      			else {
		        			set2[k] = strtod(i, &i) * -1;}
		      				if(isinteger(set2[k])){
		        				fprintf(stderr, "found \"%d\" from 2nd set\n", (int)set2[k]);}
		      				else {
		        				fprintf(stderr, "found \"%.2f\" from 2nd set\n", set2[k]);}
		      					k++;}
		    		else {
		      			i++;}
		  	}
		  	return LexEntersection;}

{number}	{
		value=strtod(yytext, &yytext);
		if(isinteger(value)){
				fprintf(stderr, "found %d\n", (int)value);}
		else{
  	    		fprintf(stderr, "found %.2f\n", value);}	
		return LexNumber; }
\?		{
          fprintf(stderr, "entry\n");
 	      return LexEntry; }
\+		{
		  fprintf(stderr, "plus\n");
		  return LexPlus; }
\-		{
		  fprintf(stderr, "minus\n");
		  return LexMinus; }
\/		{
		  fprintf(stderr, "div\n");
		  return LexDiv; }
\*		{
		  fprintf(stderr, "mult\n");
		  return LexMult; }
^[ \t]*\n	{
		  fprintf(stderr, "empty line\n");
		}
\n		{
		  fprintf(stderr, "CR\n");
		  return LexEnd; }
[ \t]		{ }
.		{ return LexUnknown; }

<SKIPERROR>[^\n]* {}
%%

int isinteger(double n)
{
    return n - (double)(int)n == 0.0;
}

        int process_command(int token)
	{
	    fprintf(stderr, "token: %d\n", token);

	    switch (token) {
	    case LexSet:
		      while(k != j)
		      {
		       	my_stack_push(&stack, set[k]);
		      	k++;
		      }
		      my_stack_push(&stack, j);
		      my_stack_push(&stack, TYPE_SET);
		if (my_stack_is_full(&stack)) {
		    return -1;
		}
		break;
	    case LexNumber:
		my_stack_push(&stack, value);
		if (my_stack_is_full(&stack)) {
		    return -1;
		}
		break;
	    case LexPlus: {
		if (my_stack_is_empty(&stack)) {
		    return -1;
		}
		double a=my_stack_pull(&stack);

        if (my_stack_is_empty(&stack)) {
		    return -1;
		}
		double b=my_stack_pull(&stack);

        my_stack_push(&stack, a+b);
		if (my_stack_is_full(&stack)) {
		    return -1;
		}
		break;}
	    case LexMinus: {
		if (my_stack_is_empty(&stack)) {
		    return -1;
		}
		double a=my_stack_pull(&stack);

        if (my_stack_is_empty(&stack)) {
		    return -1;
		}
		double b=my_stack_pull(&stack);

        my_stack_push(&stack, b-a);
		if (my_stack_is_full(&stack)) {
		    return -1;
		}
		break;}
	    case LexDiv: {
		if (my_stack_is_empty(&stack)) {
		    return -1;
		}
		double a=my_stack_pull(&stack);


        if (my_stack_is_empty(&stack)) {
		    return -1;
		}
		double b=my_stack_pull(&stack);


        my_stack_push(&stack, b/a);
		if (my_stack_is_full(&stack)) {
		    return -1;
		}
		break;}
	    case LexMult: {
		if (my_stack_is_empty(&stack)) {
			return -1;
		}
		double a=my_stack_pull(&stack);
		if (my_stack_is_empty(&stack)) {
			return -1;
		}
		double b=my_stack_pull(&stack);

    my_stack_push(&stack, b*a);
		if (my_stack_is_full(&stack)) {
			return -1;
		}
		break;}
	    case LexEntry: {
		if (my_stack_is_empty(&stack)) {
		    return -1;
		}
		
		double type1=my_stack_pull(&stack);
		if ( type1 != TYPE_NUMBER) {
		    return -1;
		}
		
		double myNumber = my_stack_pull(&stack);
		if (my_stack_is_empty(&stack)) {
		    return -1;
		}
		
		double type2=my_stack_pull(&stack);
		if (type2 != TYPE_SET) {
		    return -1;
		}		
		
		int entry = 0;
		if(my_stack_pull(&stack) == TYPE_SET)
		{
			int i;
			int n = my_stack_pull(&stack);
			for(i = 0; n == my_stack_pull(&stack) - 1; i++)
			{
				if(n == my_stack_pull(&stack)-1)
				{
				entry = 0;
					return 1;
					}
				else {
					entry = 1;}
			}
			return 0;
		}
		my_stack_push(&stack, entry);
		my_stack_push(&stack, TYPE_NUMBER);
		
		if (my_stack_is_full(&stack)) {
		    return -1;
		}
		break;}			
	    case LexEnd:
		if(stack.count == 1){         
		  	my_stack_push(&stack, TYPE_NUMBER);
		}
	    case 0:
		return 0;
	    case LexUnknown:
		return -1;

	    }
	    return 1;
	}

int calc_line()
{
    int token = yylex();
    if (token == 0) {
        return 1;
    }

    while (1) {
        int cmd_res = process_command(token);
        if (cmd_res == 0) {
            break;
        }
        else if (cmd_res == -1) {
            fprintf(stderr, "Syntax error\n");
            return 0;
        }
        token = yylex();
    }

    if (my_stack_is_empty(&stack)) {
        fprintf(stderr, "Stack is empty but required value\n");
        return 0;
    }

    if( (stack.count == 2) && (my_stack_pull(&stack) == TYPE_NUMBER) ) {
	      	double result = my_stack_pull(&stack);
		if(isinteger(result)){
	      		fprintf(yyout, "%d ", (int)result);}
	    	else{
	    	    	fprintf(yyout, "%.2f ", result);}
		}
	else if( (stack.count > 2) && (my_stack_pull(&stack) == TYPE_SET) ) {
	    	k = 0;
	    	fprintf(yyout, "set(%d, ",(int)my_stack_pull(&stack));
	    	while (stack.count) {
	    	  	set[k] = my_stack_pull(&stack);
	    	  	k++;
	    	}
	    	k--;
	    	while (k) {
	    	  	if(isinteger(set[k])){
	    	    		fprintf(yyout, "%d, ", (int)set[k]);}
	    	  	else{
	    	    		fprintf(yyout, "%.2f, ", set[k]);}
	    	  		k--;
	    	}
	    	if(isinteger(set[k])){
	    	    fprintf(yyout, "%d) ", (int)set[k]);}
	  	else{
	  	    fprintf(yyout, "%.2f) ", set[k]);}
	}

    if (!my_stack_is_empty(&stack)) {
        fprintf(stderr, "Stack not empty after calculation\n");
        return 0;
    }

    return 1;
}

void calc()
{
    while (!end_file) {
        fprintf(stderr, "parse line\n");
        if (calc_line() == 0) {
            printf("FAIL\n");
            BEGIN(SKIPERROR);
            yylex();
            BEGIN(INITIAL);
        }
        else {
            printf("OK\n");
        }
        fprintf(stderr, "line parsed\n");
    }
}

int main(void)
{
    my_stack_init(&stack, 100);
    end_file = 0;

    calc();

    my_stack_done(&stack);
    return 0;
}

int yywrap(void)
{
    end_file = 1;
    return 1;
}
