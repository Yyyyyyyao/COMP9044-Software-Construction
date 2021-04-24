#!/bin/dash

## echo sgner sg| 2041 speed 'sXsgXzgXg'

1q;1p
1p;1q


seq 1 5 | ./speed.pl 2,2d


echo '$q;/2/d' > commandsFile
seq 1 5 | speed.pl -f commandsFile


echo '1,/.1/p;/5/,/9/s/.//' > commandsFile
echo '/.{2}/,/.9/p;85q'    >> commandsFile
seq 1 100 | speed.pl -n -f commandsFile




echo '/2/    d # comment' > commandsFile
echo '# comment'         >> commandsFile
echo '4    q'            >> commandsFile
seq 1 2   > two.txt
seq 1 5   > five.txt
speed.pl -f commandsFile two.txt five.txt