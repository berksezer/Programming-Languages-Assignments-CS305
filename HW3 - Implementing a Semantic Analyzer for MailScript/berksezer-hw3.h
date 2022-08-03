#ifndef __MS_H
#define __MS_H

 
typedef struct SetNode
{
    char *value;
    char *identifier;
    int lineNum;


} SetNode;

typedef struct StringNode
{
    char *value;
    int lineNum;

} StringNode;

typedef struct IdentNode
{
    char *value;
    int lineNum;

} IdentNode;

typedef struct RecipNode 
{
    char *name;
    char *mail;
    char *identifier;
} RecipNode;

typedef struct AdressNode
{
    char *mail;
} AdressNode;

typedef struct RecipListNode
{
    RecipNode ** recips;
    int RecipIndex;
    int RecipSize;

   

} RecipListNode;

typedef struct SendNode 
{
    RecipListNode * recips;
    char *identifier;
    char *value;
} SendNode;

typedef struct SendListNode 
{
    SendNode ** sends;
    int SendIndex;
    int SendSize;
}SendListNode;

typedef struct StatementNode 
{
    SendNode * send;
}StatementNode;

typedef struct DateNode 
{
    char * day;
    char * month;
    char * year;
}DateNode;

#endif
