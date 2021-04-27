#!/bin/dash

# test nothing to commit

rm -rf .girt
./girt-init
echo line1 > a 
echo line2 > b 
./girt-add a b 
./girt-rm --cached a b 
./girt-commit -m commit-0
./girt-add a b
./girt-commit -m commit-0
./girt-commit -m commit-1
./girt-status