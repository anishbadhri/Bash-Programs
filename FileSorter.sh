#!/bin/bash
if [ ! -e .optionDB ]; then
	touch .optionDB
fi
if [ ! -d Extensions ]; then
	mkdir Extensions
	mkdir Extensions/Other
fi
if [ ! -d Extensions/Other ]; then
	mkdir Extensions/Other
fi
if [ $# -eq 0 ]; then
	read -p "Enter Option to Add: " op
	read -p "Enter Folder to Link to: " fold
	if [ ! -d $fold ]; then
		echo "No such Folder, Creating Folder"
		mkdir $fold
	fi
	echo "$op : $fold" >> .optionDB
	sort -o .optionDB .optionDB
	exit 0
fi
opArrIndex=0
fileArrIndex=0
for var in $@; do
	firstChar=${var:0:1}
	if [[ $firstChar == '-' ]]; then
		opArr[opArrIndex]=${var:1:${#var}-1}
		opArrIndex=$((opArrIndex+1))
	else
		if [ ! -e $var ]; then
			echo "$var : No Such File"
			continue
		fi
		fileArr[fileArrIndex]=$var
		fileArrIndex=$((fileArrIndex+1))
	fi
done
opArr=($(printf '%s\n' "${opArr[@]}"|sort -u))
opArrIndex2=0
fileArrIndex=0
fline=$(head -n 1 .optionDB)
flineArr=($fline)
while [[ ${opArr[opArrIndex2]} < ${flineArr[0]} ]]; do
	if [ $opArrIndex2 -ge $opArrIndex ]; then
		break
	fi
	echo "Invalid Option: ${opArr[opArrIndex2]}"
	opArrIndex2=$((opArrIndex2+1))
	if [ $opArrIndex2 -ge $opArrIndex ]; then
		break
	fi
done
while read -r line
do
	if [ $opArrIndex2 -ge $opArrIndex ]; then
		break
	fi
	if [[ $opArrIndex2 != 0 ]]; then
		while [[ ${opArr[opArrIndex2]} == ${opArr[opArrIndex2-1]} ]]; do
			opArrIndex2=$((opArrIndex2+1))
		done
	fi
	if [[ ${lineArr[0]} > ${opArr[opArrIndex2]} ]]; then
		echo "Invalid Option: ${opArr[opArrIndex2]}"
		opArrIndex2=$((opArrIndex2+1))
	fi
	lineArr=($line)
	if [[ ${lineArr[0]} == ${opArr[opArrIndex2]} ]]; then
		folderArr[fileArrIndex]=${lineArr[2]}
		fileArrIndex=$((fileArrIndex+1))
		opArrIndex2=$((opArrIndex2+1))
	fi
done < .optionDB
while [ $opArrIndex2 -lt $opArrIndex ]; do
	echo "Invalid Option: ${opArr[opArrIndex2]}"
	opArrIndex2=$((opArrIndex2+1))
done
folderArr=($(printf '%s\n' "${folderArr[@]}"|sort -u))
for folderVar in ${folderArr[@]}; do
	for fileVar in ${fileArr[@]}; do
		if [ ! -d $folderVar ]; then
			mkdir $folderVar
		fi
		dest=$folderVar/$fileVar
		rm -f $dest
		link $fileVar $dest 
	done
done
for fileVar in ${fileArr[@]}; do
	pointLoc=-1
	flag=0
	for (( i = 0; i < ${#fileVar}; i++ )); do
		if [[ ${fileVar:i:1} == '.' ]]; then
			if [[ $pointLoc != -1 ]]; then
				flag=1
			fi
			pointLoc=$i;
		fi
	done
	lenRem=`expr ${#fileVar} - $pointLoc`
	if [ $flag -eq 1 ] || [ $pointLoc -eq -1 ] || [ $lenRem -le 1 ]; then
		dest=Extensions/Other/ + $fileVar
		rm -f $dest
		link $fileVar $dest
	else
		ext=${fileVar:pointLoc+1:lenRem-1}
		dest=Extensions/$ext
		if [ ! -d $dest ]; then
			mkdir $dest
		fi
		dest=$dest/$fileVar
		rm -f $dest
		link $fileVar $dest
	fi
done
