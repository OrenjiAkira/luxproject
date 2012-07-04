#!/bin/bash

help(){
    echo "Placeholder Help Message - Ask Wil"
}

if [ $# -lt 1 ] ; then
    echo "Error: Missing argument!"
    help
    exit 1;
fi

if [ $1 == "-h" -o $1 == "--help" ]; then
    help
    exit 0
fi

if [ ! -d $1/nova ]
then
  mkdir $1/nova
fi

cp -v src/nova.lua $1
cp -v src/nova/*.lua $1/nova

