# COMP9044-Software Construction
### Course works on UNSW COMP9044

## **Assignment 1 - Implement girt using Shell**
### Inroduction 
> Your task in this assignment is to implement Girt, a subset of the version control system Git.

> Git is a very complex program which has many individual commands. You will implement only a few of the most important commands. You will also be given a number of simplifying assumptions, which make your task easier.

> Girt is a contraction of git restricted subset You must implement Girt in Shell.

> Interestingly, early versions of Git made heavy use of Shell and Perl.

##### **Key ideas**
Implement similar operations:
* girt init
* girt-add filenames...
* girt-commit -m message
* girt-log
* girt-show [commit]:filename
* girt-commit [-a] -m message
* girt-rm [--force] [--cached] filenames...
* girt-status

### **Runing code**
Example:
> ./girt-init
> ./girt-add [filenames]

## **Assignment 2 - Implement sed using Perl**
### Inroduction 
>  Your task in this assignment is to implement Speed.

> A subset of the important Unix/Linux tool Sed.

> You will do this in Perl hence the name Speed

> Sed is a very complex program which has many commands.
  You will implement only a few of the most important commands.
  You will also be given a number of simplifying assumptions, which make your task easier.

> Speed is a POSIX-compatible subset of sed with extended regular expressions (EREs).

> You must implement Speed in Perl only.

##### **Key ideas**
* similar to Sed in linux

### **Runing code**
Example:
> seq 1 5 | ./speed.pl '5d' 
> ./speed.pl -n -f CommandFile inputfile1 inputfile2 ...





