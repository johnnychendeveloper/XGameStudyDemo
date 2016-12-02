#!/bin/bash

GEN="../gen"
if [ ! -d "$GEN" ]; then
	mkdir $GEN
fi

protoc --cpp_out=../gen *.proto
