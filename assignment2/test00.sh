#!/bin/dash

# Testing on delete the last line
# Complicated multiple commands
# 1
# a
# 2
# a
# 3
# a
# 4
# 4

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

my_result=$(seq 1 5 | ./speed.pl '3d;3q')
ground_truth=$(seq 1 5 | 2041 speed '3d;3q')

# echo "$ground_truth";
if [ "$my_result" = "$ground_truth" ]
then
    echo "${GREEN} Test00 passed! ${NC}"
    exit 0
else
    echo "+++++++++++++++++++++++++++++++ Test00 ${RED}failed${NC}";

    echo "My output:"
    echo "$my_result"

    echo "==============================="

    echo "Correct answer:"
    echo "$ground_truth"
    echo "+++++++++++++++++++++++++++++++ Test00 ${RED}failed${NC}";

    echo "Debug on command: seq 1 5 | ./speed.pl '3d;1,/3/s/./?/'"
    exit 1
fi

