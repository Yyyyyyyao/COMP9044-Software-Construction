#!/bin/dash

# test girt-add none existing files
rm -rf .girt
./girt-init
./girt-add a
./girt-add b a # b exist, a does not exist
./girt-commit -m commit-0 # should print nothing to commit

