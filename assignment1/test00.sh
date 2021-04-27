#!/bin/dash

# test on girt-show
# a is in commit 0
# a is not in commit 2
# a is not in index


rm -rf .girt

./girt-init
touch a b
echo "line1" > a
./girt-add a b
./girt-commit -m "first commit"
rm a
./girt-commit -m "second commit"
./girt-add a
./girt-commit -m "second commit"
./girt-rm --cached b
./girt-commit -m "third commit"
./girt-show 0:a
./girt-show 1:a
./girt-show 2:a
./girt-show :a
./girt-status