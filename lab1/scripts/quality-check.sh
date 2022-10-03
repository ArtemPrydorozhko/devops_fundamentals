#!/bin/bash

project_dir="../../../shop-angular-cloudfront"

cd $project_dir

npm run lint
if [[ "$?" == 1 ]]
then
	echo "Lint not passed!"
	exit 1
fi

export FIREFOX_BIN="/usr/bin/firefox"

npm run test --watch=false
if [[ "$?" == 1 ]]
then
	echo "Tests not passed!"
	exit 1
fi 
