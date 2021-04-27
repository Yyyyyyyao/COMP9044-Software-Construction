#!/bin/dash

# Testing on delete lines
# if the start address of the print is a line number 
# And the matched line is deleted
# the print should also start
# output should be:
# 1
# 2
# 4
# 4
# 5
# 5

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

my_result=$(seq 1 5 | ./speed.pl '3d;3,5p')
ground_truth=$(seq 1 5 | 2041 speed '3d;3,5p')

# echo "$ground_truth";
if [ "$my_result" = "$ground_truth" ]
then
    echo "${GREEN} Test06 passed! ${NC}"
    exit 0
else
    echo "+++++++++++++++++++++++++++++++ Test06 ${RED}failed${NC}";

    echo "My output:"
    echo "$my_result"

    echo "==============================="

    echo "Correct answer:"
    echo "$ground_truth"
    echo "+++++++++++++++++++++++++++++++ Test06 ${RED}failed${NC}";

    echo "Debug on command: seq 1 5 | ./speed.pl '3d;3,5p'"
    exit 1
fi

