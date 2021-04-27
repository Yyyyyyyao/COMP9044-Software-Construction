#!/bin/dash

# Testing on delete lines
# if the end address of the print is a line nuber 
# And the matched line is deleted
# the print should stop

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

my_result=$(seq 1 5 | ./speed.pl '3d;1,3p')
ground_truth=$(seq 1 5 | 2041 speed '3d;1,3p')

# echo "$ground_truth";
if [ "$my_result" = "$ground_truth" ]
then
    echo "${GREEN} Test05 passed! ${NC}"
    exit 0
else
    echo "+++++++++++++++++++++++++++++++ Test05 ${RED}failed${NC}";

    echo "My output:"
    echo "$my_result"

    echo "==============================="

    echo "Correct answer:"
    echo "$ground_truth"
    echo "+++++++++++++++++++++++++++++++ Test05 ${RED}failed${NC}";

    echo "Debug on command: seq 1 5 | ./speed.pl '3d;1,3p'"
    exit 1
fi

