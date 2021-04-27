#!/bin/dash

# test girt-commit

rm -rf .girt
./girt-init
echo linea1 > a
echo lineb1 > b
echo linec1 > c
./girt-add a c 
./girt-commit -m commit-0 # should commit
rm a
./girt-commit -m commit-1 # should have nothing to commit
./girt-add a c 
./girt-commit -m commit-2
./girt-show 1:a