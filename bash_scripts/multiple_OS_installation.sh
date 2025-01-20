#!/bin/bash
echo "Script to install git"
echo "Installation started"
if [ "$(uname)" == "Linux" ];
then 
    echo "This is linux box installing git"
    apt install git -y 
elif [ "$(uname)" == "Darwin" ];
then
    echo "this is MacOS"
    sudo brew install git 
else
    echo "Discovered systm is unidentified"
fi
