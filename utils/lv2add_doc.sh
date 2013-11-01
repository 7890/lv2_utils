#!/bin/bash

#//tb/131030

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

stylesheet=stylesheets/add_doc.xsl
xml_dir=xhtml
manual_doc_file=manual_doc/doc.xml

for tool in {xmlstarlet,which}; \
	do checkAvail "$tool"; done

stripped=`echo "$1" | sed 's/:/_/g' | sed 's/\//_/g' | sed 's/#/_/g' `

xml_filename="$stripped".xml

if [ ! -f "$xml_dir"/"$xml_filename" ]
then
	echo "no xml file found for this plugin."
	echo "hint: use lv2x2xhtml.sh to create one."
	exit
fi

if [ ! -f "$manual_doc_file" ]
then
	echo "no manual doc file found!"
	exit
fi

tmpfile=`mktemp`

echo "adding manual doc"

#add manually written doc node for this plugin from external file
xmlstarlet tr "$stylesheet" \
	-s plugin_uri="$1" \
	"$xml_dir"/"$xml_filename" \
	> "$tmpfile"

xmlstarlet fo "$tmpfile" 2>&1 > /dev/null
ret=$?

if [ $ret -ne 0 ]
then
	echo "error: resulting xml file was invalid: "
	echo "$tmpfile"
	exit
fi

mv "$tmpfile" "$xml_dir"/"$xml_filename"

ls -1 "$xml_dir"/"$xml_filename"
echo "done."
