%{
#include <stdio.h>
void yyerror (const char *msg) /* Called by yyparse on error */ {
return; }
%}
%token tMAIL tENDMAIL tSCHEDULE tENDSCH tSEND tTO tFROM tSET tCOMMA tCOLON tLPR tRPR tLBR tRBR tAT tSTRING tIDENT tADDRESS tDATE tTIME
%start program
%%

program : statements
;

statements : 
            | setStatement statements
            | mailBlock statements
;

mailBlock : tMAIL tFROM tADDRESS tCOLON statementList tENDMAIL
;

statementList : 
                | setStatement statementList
                | sendStatement statementList
                | scheduleStatement statementList
;

sendStatements : sendStatement
                 | sendStatement sendStatements 
;

sendStatement : tSEND tLBR tIDENT tRBR tTO tLBR recipientList tRBR
                | tSEND tLBR tSTRING tRBR tTO tLBR recipientList tRBR
;

recipientList : recipient
            | recipient tCOMMA recipientList
;

recipient : tLPR tADDRESS tRPR
            | tLPR tSTRING tCOMMA tADDRESS tRPR
            | tLPR tIDENT tCOMMA tADDRESS tRPR
;

scheduleStatement : tSCHEDULE tAT tLBR tDATE tCOMMA tTIME tRBR tCOLON sendStatements tENDSCH
;

setStatement : tSET tIDENT tLPR tSTRING tRPR
;


%%
int main () 
{
   if (yyparse())
   {
      // parse error
      printf("ERROR\n");
      return 1;
    } 
    else 
    {
        // successful parsing
        printf("OK\n");
        return 0;
    } 
}