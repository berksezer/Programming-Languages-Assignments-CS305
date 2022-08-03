%{
#include <stdio.h>
void yyerror (const char *msg) {
return; }
%}

%token tMAIL tENDMAIL tSCHEDULE tENDSCH tSEND tSET tTO tFROM tAT tCOMMA tCOLON tLPR tRPR tLBR tRBR tIDENT tSTRING tADDRESS tDATE tTIME
%start program 
%%

program :		  
	| prog
;

prog : mailBlock
     | setStatement
     | setStatement prog
     | mailBlock prog
  				
;

mailBlock :  tMAIL tFROM  tADDRESS tCOLON tENDMAIL
	   | tMAIL tFROM tADDRESS tCOLON statementList tENDMAIL   
;

statementList : statement
		| statement statementList
;

statement : setStatement
	  | sendStatement
	  | scheduleStatement
;

setStatement : tSET tIDENT tLPR tSTRING tRPR
;

sendStatement : tSEND tLBR tIDENT tRBR tTO recipientList
	      | tSEND tLBR tSTRING tRBR tTO recipientList   
;

sendList : sendStatement
	 | sendStatement sendList
;

scheduleStatement : tSCHEDULE tAT tLBR tDATE tCOMMA tTIME tRBR tCOLON sendList tENDSCH
;

recipient : tLPR tADDRESS tRPR
	  | tLPR tIDENT tCOMMA tADDRESS tRPR
	  | tLPR tSTRING tCOMMA tADDRESS tRPR
;

recipComma : recipient
	   | recipient tCOMMA recipComma
;


recipientList : tLBR recipComma tRBR 
;
 		
  
%%
int main() {
 if (yyparse()) {
 printf("ERROR\n");
 return 1;
 }
 else {
 printf("OK\n");
 return 0;
 }
}
   
