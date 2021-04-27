#!/bin/dash

# test girt-rm --cached with an non-exist file

rm -rf .girt
./girt-init
echo line1 > a 
echo line2 > b 
./girt-add b 
./girt-rm --cached b a 
./girt-status