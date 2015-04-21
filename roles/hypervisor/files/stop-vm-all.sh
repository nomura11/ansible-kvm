#!/bin/bash

LANG=C
for m in $(virsh list --name --state-running); do
	virsh destroy $m
done
