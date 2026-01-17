#!/bin/bash

docker run --rm -it -v "$PWD":/workdir crops/poky --workdir=/workdir
