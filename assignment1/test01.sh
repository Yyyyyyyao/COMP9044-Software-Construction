#!/bin/dash

# test girt-rm

rm -rf .girt
./girt-init
# Initialized empty girt repository in .girt
echo hello >a
./girt-add a
./girt-commit -m commit-0
# Committed as commit 0
./girt-rm a
./girt-commit -m commit-1
./girt-show 1:a
./girt-show :a
# Committed as commit 1
echo world >a
./girt-status
# a - untracked
./girt-commit -m commit-2
# Committed as commit 2