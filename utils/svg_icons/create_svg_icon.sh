#!/bin/bash

#//tb/131031

if [ $# -ne 2 ]
then
        echo "need params: <icon file.svg> <icon handle>"
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

svg_icons_file="svg_icons.xml"

for tool in {xmlstarlet,which}; \
	do checkAvail "$tool"; done

if [ ! -f "$1" ]
then
        echo "icon file not found."
        exit
fi

tmpfile=`mktemp`

xmlstarlet \
	ed -u "//icon[@handle='${2}']/data" \
	-v "`base64 -w 100000 "$1"`" "$svg_icons_file" > "$tmpfile"

xmlstarlet fo "$tmpfile" 2>&1 > /dev/null
ret=$?

if [ $ret -ne 0 ]
then
        echo "error: resulting xml file was invalid: "
        echo "$tmpfile"
        exit
fi

mv "$tmpfile" "$svg_icons_file"
