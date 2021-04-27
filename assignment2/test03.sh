#!/bin/dash

# Testing on multiple command
# Order issue 
# q first then p
# should not print the quit line

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

my_result=$(seq 1 5 | ./speed.pl '1q;1p')
ground_truth=$(seq 1 5 | 2041 speed '1q;1p')

if [ "$my_result" = "$ground_truth" ]
then
    echo "${GREEN} Test03 passed! ${NC}"
    exit 0
else
    echo "+++++++++++++++++++++++++++++++ Test03 ${RED}failed${NC}";

    echo "My output:"
    echo "$my_result"

    echo "==============================="

    echo "Correct answer:"
    echo "$ground_truth"
    echo "+++++++++++++++++++++++++++++++ Test03 ${RED}failed${NC}";

    echo "Debug on command: seq 1 5 | ./speed.pl '1q;1p'"
    exit 1
fi

