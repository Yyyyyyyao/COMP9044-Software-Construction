#!/bin/dash

# Testing on delimitor 
# In this case delimitor is X not g
# And this example also includes g flag

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

my_result=$(echo sgner sg | ./speed.pl 'sXsgXzgXg')
ground_truth=$(echo sgner sg | 2041 speed 'sXsgXzgXg')

if [ "$my_result" = "$ground_truth" ]
then
    echo "${GREEN} Test01 passed! ${NC}"
    exit 0
else
    echo "+++++++++++++++++++++++++++++++ Test01 ${RED}failed${NC}";

    echo "My output:"
    echo "$my_result"

    echo "==============================="

    echo "Correct answer:"
    echo "$ground_truth"
    echo "+++++++++++++++++++++++++++++++ Test01 ${RED}failed${NC}";
    echo "Debug on command: echo sgner sg | ./speed.pl 'sXsgXzgXg'"
    exit 1
fi

