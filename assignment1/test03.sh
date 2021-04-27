#!/bin/dash

# test with all commands that .girt is not created

rm -rf .girt
./girt-add a
./girt-commit -m commit-0
./girt-show 0:a
./girt-log
./girt-rm a
./girt-status
./girt-init