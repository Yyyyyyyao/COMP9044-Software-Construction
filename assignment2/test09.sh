#!/bin/dash

# Testing on delete lines
# if the end address of the substitude is a regex
# And the matched line is deleted
# the substitude should not start
# output should be:
# ?
# ?
# ?
# ?

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

my_result=$(seq 1 5 | ./speed.pl '3d;1,/3/s/./?/')
ground_truth=$(seq 1 5 | 2041 speed '3d;1,/3/s/./?/')

# echo "$ground_truth";
if [ "$my_result" = "$ground_truth" ]
then
    echo "${GREEN} Test09 passed! ${NC}"
    exit 0
else
    echo "+++++++++++++++++++++++++++++++ Test09 ${RED}failed${NC}";

    echo "My output:"
    echo "$my_result"

    echo "==============================="

    echo "Correct answer:"
    echo "$ground_truth"
    echo "+++++++++++++++++++++++++++++++ Test09 ${RED}failed${NC}";

    echo "Debug on command: seq 1 5 | ./speed.pl '3d;1,/3/s/./?/'"
    exit 1
fi

