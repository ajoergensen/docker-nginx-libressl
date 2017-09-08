#!/bin/bash
set -euf -o pipefail

for i in stable mainline
 do
	docker build -t nginx-testbuild-$i $i/alpine && docker rmi nginx-testbuild-$i
done
