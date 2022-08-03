# Programming-Languages-Assignments-CS305

This repistory contains all the assignments that I have written for the course CS 305 Programming Languages.

The summaries of the assignments can be seen below:

## Implementing a Lexical Analyzer (Scanner) for MailScript

I have implemented a scanner for MailScript language
using flex. Your scanner will be used to produce the tokens in a MailScript
program. This is a scripting language that will be used for e-mail automation.
MailScript is loosely based on AppleScript, which is a scripting language that facilitates automated control over scriptable Mac applications.
MailScript uses a block structure. Each block starts with the keywords “Mail
from” followed by the e-mail of the user and a colon symbol. Each block
ends with the keywords “end Mail”. One can use the keyword “send”
in order to send e-mails to certain users. Also they can create a sub-block
called “schedule” and specify a certain date for the e-mails to be sent. One
can ”set” variables in and out of block.

## Writing a context free grammar and implement a simple parser for MailScript

I have writen a context free grammar and implemented a simple parser
for MailScript language for which I designed a scanner in the previous assignment.

##  Implementing a Semantic Analyzer for MailScript

I have implemented a tool which includes a simple semantic analyzer
for MailScript language. The tool first checks if a given MailScript program has any syntax error, grammatically.
If there are no syntax errors, the tool will perform some semantic checks for simple
cases and if these checks are passed, it will generate notifications for certain statements.

## Scheme Procedures

In this assignment I have implemented various Scheme procedures.

##  Implement a Scheme Interpreter

In this assignment I have implemented a Scheme interpreter.
