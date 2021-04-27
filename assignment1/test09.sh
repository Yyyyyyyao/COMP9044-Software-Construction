#!/bin/dash

# test all usage print

rm -rf .girt
./girt-init
./girt-add
touch a
./girt-add a
./girt-commit -msg commit-0 # print usage error
./girt-commit -m commit-0 # should commit
./girt-show # print usage error
./girt-show 0:b # should print girt-show: error: 'b' not found in commit 0
./girt-show 0: # should print girt-show: error: invalid filename ''
./girt-show 0 # should print girt-show: error: invalid object 1
./girt-rm # should print usage error
./girt-rm --force --cached

