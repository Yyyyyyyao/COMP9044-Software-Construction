#!/bin/dash

# test with girt-add

rm -rf .girt
./girt-init
echo hello > a 
echo world > b 
./girt-add a b
echo change > a 
./girt-add b a
./girt-commit -m commit-0
./girt-show 0:a
./girt-status