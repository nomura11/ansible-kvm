#!/bin/bash

LANG=C
for m in $(virsh list --name --all); do
	./remove-vm.sh $m
done
