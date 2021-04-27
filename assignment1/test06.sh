#!/bin/dash

# test girt-rm --force with an non-exist file

rm -rf .girt
./girt-init
echo line1 > a
./girt-add a
./girt-commit -m commit-0
./girt-rm --force a b
./girt-status
