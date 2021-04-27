#!/bin/dash

# Testing on multiple command
# Order issue 
# p first then q
# should print the quit line

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

my_result=$(seq 1 5 | ./speed.pl '1p;1q')
ground_truth=$(seq 1 5 | 2041 speed '1p;1q')

if [ "$my_result" = "$ground_truth" ]
then
    echo "${GREEN} Test02 passed! ${NC}"
    exit 0
else
    echo "+++++++++++++++++++++++++++++++ Test02 ${RED}failed${NC}";

    echo "My output:"
    echo "$my_result"

    echo "==============================="

    echo "Correct answer:"
    echo "$ground_truth"
    echo "+++++++++++++++++++++++++++++++ Test02 ${RED}failed${NC}";

    echo "Debug on command: seq 1 5 | ./speed.pl '1p;1q'"
    exit 1
fi

