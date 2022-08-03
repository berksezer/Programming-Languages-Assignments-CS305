%{
#include <stdio.h>    
#include <stdlib.h>
#include <string.h>
#include "berksezer-hw3.h"

void yyerror (const char *msg) /* Called by yyparse on error */ {
return; }

int checkIdentifier(IdentNode); 
int checkRecipIdentifier(RecipListNode *);

void makeSetNodeFromIdent(IdentNode, StringNode);
RecipNode * makeRecipNodeFromIdentAdd(IdentNode, AdressNode);
RecipNode * makeRecipNodeFromStringAdd(StringNode, AdressNode);
RecipNode * makeRecipNodeFromAdd(AdressNode);

RecipListNode * addRecipToList(RecipNode *);
RecipListNode * addRecipListToList(RecipNode * , RecipListNode * );

SendNode * makeSendNodeFromString(StringNode, RecipListNode *);
SendNode * makeSendNodeFromIdent(IdentNode, RecipListNode *);

SendListNode * addSendToList (SendNode * );
SendListNode * addSendListToList (SendNode *, SendListNode *);

SendNode * makeStatementNodeFromSendNode(SendNode *);

void sendNotification(AdressNode, SendNode *);

SetNode ** sets;
int setsSize = 100;
int setIndex = 0;

int error = 0;

char ** errors;
int errorSize = 100;
int errorIndex = 0;

%}


%union {
    StringNode stringNode;
    IdentNode identNode;
    DateNode dateNode;
    SetNode * setNodePtr;
    int lineNum;
    RecipNode * recipNodePtr;
    AdressNode adressNode;
    RecipListNode * recipListNodePtr;
    SendNode * sendNodePtr;
    SendListNode * sendListNodePtr;
    StatementNode * statementNodePtr;

}


%token <stringNode> tSTRING
%token <identNode> tIDENT
%token <adressNode> tADDRESS
%token <dateNode> tDATE
%token tMAIL tENDMAIL tSCHEDULE tENDSCH tSEND tTO tFROM tSET tCOMMA tCOLON tLPR tRPR tLBR tRBR tAT tTIME
%start program


%type <setNodePtr> setStatement
%type <recipNodePtr> recipient;
%type <recipListNodePtr> recipientList;
%type <sendNodePtr> sendStatement;
%type <sendListNodePtr> sendStatements;
//%type <sendNodePtr> statementList;


%%

program : statements 
;

statements :                  
            | setStatement statements
            | mailBlock statements
;

mailBlock : tMAIL tFROM tADDRESS tCOLON statementList tENDMAIL {
                //sendNotification($3, $5);
            }
;

statementList : 
                | setStatement statementList
                | sendStatement statementList /*{
                    //$$ = makeStatementNodeFromSendNode($1);
                }*/
                | scheduleStatement statementList
;

sendStatements : sendStatement {
                    $$ = addSendToList($1);
                }
                 | sendStatement sendStatements {
                     $$ = addSendListToList($1, $2);
                 }
;

sendStatement : tSEND tLBR tIDENT tRBR tTO tLBR recipientList tRBR {
                    checkIdentifier($3);
                    //checkRecipIdentifier($7);
                    $$ = makeSendNodeFromIdent($3, $7);

                }
                | tSEND tLBR tSTRING tRBR tTO tLBR recipientList tRBR{
                    //checkRecipIdentifier($7);
                    $$ = makeSendNodeFromString($3,$7);
                }
;

recipientList : recipient  {
                $$ = addRecipToList($1);
            }
            | recipient tCOMMA recipientList {
                $$ = addRecipListToList($1,$3);
            }
;

recipient : tLPR tADDRESS tRPR {
                $$ = makeRecipNodeFromAdd($2);
            }
            | tLPR tSTRING tCOMMA tADDRESS tRPR{
                $$ = makeRecipNodeFromStringAdd($2,$4);
            }
            | tLPR tIDENT tCOMMA tADDRESS tRPR {
                checkIdentifier($2);
                $$ = makeRecipNodeFromIdentAdd($2,$4);
            }
;

scheduleStatement : tSCHEDULE tAT tLBR tDATE tCOMMA tTIME tRBR tCOLON sendStatements tENDSCH {

}
;

setStatement : tSET tIDENT tLPR tSTRING tRPR { 
        makeSetNodeFromIdent($2, $4);
        

    }
;


%%

void makeSetNodeFromIdent(IdentNode ident, StringNode currString) {
    SetNode * newNode = (SetNode *)malloc(sizeof(SetNode));
    newNode->identifier = ident.value;
    newNode->value = currString.value;
    newNode->lineNum = ident.lineNum;
   
    
    if(setIndex < setsSize) {
        sets[setIndex] = newNode;
        setIndex += 1;
    }

    
    else {
        setsSize = setsSize + setsSize;
        sets = realloc(sets, setsSize);
        sets[setIndex] = newNode;
        setIndex += 1;
    }
    


    
}

RecipNode * makeRecipNodeFromIdentAdd(IdentNode ident, AdressNode adress) {
    RecipNode * newNode = (RecipNode *)malloc(sizeof(RecipNode));

    newNode->identifier = ident.value;
    newNode->mail = adress.mail;

    int i = 0;

    SetNode * newIdentNode = (SetNode *)malloc(sizeof(SetNode));
    newIdentNode->identifier = ident.value;
    newIdentNode->lineNum = ident.lineNum;

    for(;i<setIndex;i++) {
        //printf("ident 1 %s - ident 2 %s\n", newNode->identifier, sets[i]->identifier);
        if(strcmp(newIdentNode->identifier, sets[i]->identifier) == 0) {
            newNode->name = sets[i]->value;
        }
    }



    
    return newNode;

}

RecipNode * makeRecipNodeFromStringAdd(StringNode string, AdressNode adress) {
    RecipNode * newNode = (RecipNode *)malloc(sizeof(RecipNode));

    newNode->name = string.value;
    newNode->mail = adress.mail;
    newNode->identifier = "-1";
    return newNode;

}

RecipNode * makeRecipNodeFromAdd(AdressNode adress) {
    RecipNode * newNode = (RecipNode *)malloc(sizeof(RecipNode));

    newNode->name = "-1";
    newNode->mail = adress.mail;
    newNode->identifier = "-1";
    return newNode;

}

RecipListNode * addRecipToList(RecipNode * recip) {
    RecipListNode * newNode = (RecipListNode *)malloc(sizeof(RecipListNode));
    
    newNode->RecipIndex = 0;
    newNode->RecipSize = 100;
    int RecipSize = newNode->RecipSize;
    newNode->recips = (RecipNode**)malloc(RecipSize * sizeof(RecipNode*));

    int index = newNode->RecipIndex;

    newNode->recips[index] = recip;
    index += 1;
    newNode->RecipIndex = index;

    return newNode;
}

SendListNode * addSendToList (SendNode * send) {
    SendListNode * newNode = (SendListNode *)malloc(sizeof(SendListNode));

    newNode->SendIndex = 0;
    newNode->SendSize = 100;
    int SendSize = newNode->SendSize;
    newNode->sends = (SendNode**)malloc(SendSize * sizeof(SendNode*));

    int index = newNode->SendIndex;
    newNode->sends[index] = send;
    index += 1;
    newNode->SendIndex = index;

    return newNode;
}

RecipListNode * addRecipListToList(RecipNode * recip, RecipListNode * recipList) {
  
            
    int index = recipList->RecipIndex;
    recipList->recips[index] = recip;
    index += 1;
    recipList->RecipIndex = index;
    
    /*
    else {
        RecipListNode * newNode = (RecipListNode *)malloc(sizeof(RecipListNode));
    
        newNode->RecipIndex = 0;
        newNode->RecipSize = 100;
        int RecipSize = newNode->RecipSize;
        newNode->recips = (RecipNode**)malloc(RecipSize * sizeof(RecipNode*));

        int index = newNode->RecipIndex;

        newNode->recips[index] = recip;
        index += 1;
        newNode->RecipIndex = index;
        recipList = newNode;
    }
    */
    return recipList;
}

SendListNode * addSendListToList (SendNode * send, SendListNode * sendList) {
    int index = sendList->SendIndex;
    sendList->sends[index] = send;
    index += 1;
    sendList->SendIndex = index;

    return sendList;
}

SendNode * makeSendNodeFromString(StringNode currString, RecipListNode * recipList) {
    SendNode * newNode = (SendNode *)malloc(sizeof(SendNode));

    newNode->recips = recipList;
    newNode->value = currString.value;
    newNode->identifier = "-1";

    return newNode;
}

SendNode * makeSendNodeFromIdent(IdentNode ident, RecipListNode * recipList) {
    SendNode * newNode = (SendNode *)malloc(sizeof(SendNode));

    newNode->recips = recipList;
    newNode->identifier = ident.value;

    int i = 0;

    SetNode * newIdentNode = (SetNode *)malloc(sizeof(SetNode));
    newIdentNode->identifier = ident.value;
    newIdentNode->lineNum = ident.lineNum;

    for(;i<setIndex;i++) {
        //printf("ident 1 %s - ident 2 %s\n", newNode->identifier, sets[i]->identifier);
        if(strcmp(newIdentNode->identifier, sets[i]->identifier) == 0) {
            newNode->value = sets[i]->value;
        }
    }

    return newNode;


}

SendNode * makeStatementNodeFromSendNode(SendNode * currSend) {
    //StatementNode * newNode = (StatementNode *)malloc(sizeof(StatementNode));
    //newNode->send = currSend;

    return currSend;
}

/*
void sendNotification(AdressNode adress, SendNode * statement) {
    
    
    RecipListNode * newRecipListNode = (RecipListNode *)malloc(sizeof(RecipListNode));
    newRecipListNode->RecipIndex = 0;
    newRecipListNode->RecipSize = 100;
    int RecipSize = newRecipListNode->RecipSize;
    newRecipListNode->recips = (RecipNode**)malloc(RecipSize * sizeof(RecipNode*));
    
    newRecipListNode = statement->recips;
    
    int recipIndex = newRecipListNode->RecipIndex;
    int i = 0;
    /*
    for(;i<recipIndex;i++) {
        char * src = "E-mail sent from %d to %s: %f\n";
        char * dest = (char *)malloc(strlen(src) + strlen(adress.mail) + statement->value + 10);

        RecipNode * newRecipNode = (RecipNode *)malloc(sizeof(RecipNode));
        newRecipNode = newRecipListNode->recips[i];

        if(newRecipNode->name != "-1") {
            sprintf(dest, src, adress.mail,newRecipNode->name, statement->value);
        }
        else {
            sprintf(dest, src, adress.mail,newRecipNode->mail, statement->value);
        }
        



    }

}*/



int checkIdentifier(IdentNode ident) {
    /* returns -1 -> when not found index when found*/
    
    int i = 0;

    SetNode * newNode = (SetNode *)malloc(sizeof(SetNode));
    newNode->identifier = ident.value;
    newNode->lineNum = ident.lineNum;

    for(;i<setIndex;i++) {
        //printf("ident 1 %s - ident 2 %s\n", newNode->identifier, sets[i]->identifier);
        if(strcmp(newNode->identifier, sets[i]->identifier) == 0) {
            return i;
        }
            
    }


    error = 1;

    

    char * src = "ERROR at line %d: %s is undefined\n";
    char * dest = (char *)malloc(strlen(src) + strlen(ident.value) + ident.lineNum + 10);
    sprintf(dest, src, ident.lineNum, ident.value);

    if(errorIndex < errorSize) {
        errors[errorIndex] = dest;
        errorIndex += 1;
    }
    else {
        errorSize = errorSize + errorSize;
        errors = realloc(errors, errorSize);
        errors[errorIndex] = dest;
        errorIndex += 1;
    }
    
}
/*
int checkRecipIdentifier(RecipListNode * recip) {
    //RecipListNode * newNode = (RecipListNode *)malloc(sizeof(RecipListNode));
    
    //newNode->RecipIndex = 0;
    //newNode->RecipSize = 100;
    //int RecipSize = newNode->RecipSize;
    //newNode->recips = (RecipNode**)malloc(RecipSize * sizeof(RecipNode*));

    int RecipSize = recip->RecipSize;
    int RecipIndex = recip->RecipIndex;
    int i = 0;

    RecipNode * newRecipNode = (RecipNode *)malloc(sizeof(RecipNode));

    for(;i<RecipIndex;i++) {
        newRecipNode = recip->recips[i];
        IdentNode newIdentNode;
        newIdentNode.value = newRecipNode->identifier;

        checkIdentifier(newIdentNode);
    }
}*/

int main () 
{   

   sets = (SetNode**)malloc(setsSize * sizeof(SetNode*)); 
   errors = (char**)malloc(errorSize * sizeof(char*));

   if (yyparse())
   {
      // parse error
      printf("ERROR\n");
      return 1;
    } 
    else 
    {
        // successful parsing
        if(error == 0) {
            int i = 0;
            /*
            for(;i<setIndex;i++) {
                printf("Expression first defined at line %d with identifier %s with value %d\n", sets[i]->lineNum, sets[i]->identifier, sets[i]->value );
            }
            */
            
        }
        else {
            int i = 0;
            for(;i<errorIndex;i++) {
                printf(errors[i]);
            }
        }
        //printf("OK\n");    
        return 0;
    } 
}
