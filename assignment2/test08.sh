#!/bin/dash

# Testing on delete lines
# if the start address of the substitude is a regex
# And the matched line is deleted
# the substitude should not start
# output should be:
# 1
# 2
# 4
# 5

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

my_result=$(seq 1 5 | ./speed.pl '3d;/3/,5s/./?/')
ground_truth=$(seq 1 5 | 2041 speed '3d;/3/,5s/./?/')

# echo "$ground_truth";
if [ "$my_result" = "$ground_truth" ]
then
    echo "${GREEN} Test08 passed! ${NC}"
    exit 0
else
    echo "+++++++++++++++++++++++++++++++ Test08 ${RED}failed${NC}";

    echo "My output:"
    echo "$my_result"

    echo "==============================="

    echo "Correct answer:"
    echo "$ground_truth"
    echo "+++++++++++++++++++++++++++++++ Test08 ${RED}failed${NC}";

    echo "Debug on command: seq 1 5 | ./speed.pl '3d;/3/,5s/./?/'"
    exit 1
fi

