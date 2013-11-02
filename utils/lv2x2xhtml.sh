#!/bin/bash

#//tb/131029

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

filename=`echo "$1" | sed 's/:/_/g' | sed 's/\//_/g' | sed 's/#/_/g'`

echo "creating xml file for plugin"
echo "$1"
echo ""

#create generic xml plugin description
lv2xinfo "$1" | xmlstarlet fo - > "$outputdir"/"$filename".xml

#add screenshot as base64 encoded string (if available)
./lv2add_image.sh "$1"

#add manually written doc for this plugin (if available)
./lv2add_doc.sh "$1"

#create output xhtml file
cat "$outputdir"/"$filename".xml | xmlstarlet tr "$stylesheet" \
	-s call_timestamp="`date -R`" - \
	| xmlstarlet fo > "$outputdir"/"$filename".xhtml

echo "resulting file:"
ls -1  "$outputdir"/"$filename".xhtml

#cat "$outputdir"/"$filename" | xmlstarlet fo
