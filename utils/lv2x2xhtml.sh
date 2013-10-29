#!/bin/bash

if [ $# -eq 0 ]
then
	echo "need param: lv2 plugin uri"
	exit
fi

checkAvail()
{
	which "$1" >/dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo -e "tool \"$1\" not found. please install"
		exit 1
	fi
}

stylesheet=stylesheets/lv2x2xhtml.xsl
outputdir=xhtml

for tool in {lv2xinfo,xmlstarlet,sed}; \
	do checkAvail "$tool"; done

mkdir -p "$outputdir"

filename=`echo "$1" | sed 's/://g' | sed 's/\//_/g' | sed 's/#/_/g'`

lv2xinfo "$1" | xmlstarlet fo - > "$outputdir"/"$filename".xml
lv2xinfo "$1" | xmlstarlet tr "$stylesheet" - > "$outputdir"/"$filename".xhtml

ls -1  "$outputdir"/"$filename".xhtml

#cat "$outputdir"/"$filename" | xmlstarlet fo
