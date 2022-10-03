#!/bin/bash

declare fileName=users.db
declare fileDir=../data
declare filePath=$fileDir/$fileName


if [[ "$1" != "help" && "$1" != "" && ! -f "$filePath" ]];
then
	echo "${filename} does not exist";
fi

function latinValidator {
	if [[ $1 =~ ^[A-Za-z]+$ ]];
	then
		return 0;
	else
		return 1;
	fi
}

function backup {
	backupFile="$(date +'%Y-%m-%d-%H:%M:%S')-users.db.backup";
	cp $filePath $fileDir/$backupFile;
}


function restore {
	backupFile=$(ls $fileDir/*-$fileName.backup | tail -n 1)
	if [[ ! -f $backupFile ]]
	then
		echo "THere is no backup file";
		return;
	fi

	cp $backupFile $filePath 
}

function add {
	read -p "Enter username: " username
	latinValidator $username
	if [[ "$?" == 1 ]]
	then
		echo "Username can contain latin letters only"
		return
	fi

	read -p "Enter role: " role
	latinValidator $role
	if [[ "$?" == 1 ]]
	then
		echo "Role can contain latin letters only"
		return
	fi

	echo "$username,$role" >> $filePath
}

isInverse="$2"
function list {
	echo "$isInverse"
	if [[ $isInverse == "--inverse" ]]
	then
		cat --number $filePath | tac
	else
		cat --number $filePath
	fi
}

function find {
	read -p "Enter username: " username
	grep "^$username,.*" $filePath

	if [[ "$?" == 1 ]]
	then
		echo "Username not found"
	fi
}

function help {
	echo "Help command";
	echo "db.sh [command]";
	echo "List of commands:";
	echo "add		Adds new record into the users.db in the format username,role"
	echo "backup	Creates a backup file";
	echo "restore	Restores users.db from the latest backup file";
	echo "find 		Searches for the username with a role provided by the user";
	echo "list		Prints all records in the users.db";
	echo "	[--inverse] Prints all records in the users.db in reverse order";
}

case "$1" in
	backup) 	backup;;
	restore) 	restore;;
	add)		add;;
	list)		list;;
	find)		find;;
	help | '' | *) help;;
esac
