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

screenshots_dir=screenshots
xml_dir=xhtml

for tool in {xmlstarlet,base64}; \
	do checkAvail "$tool"; done

stripped=`echo "$1" | sed 's/:/_/g' | sed 's/\//_/g' | sed 's/#/_/g' `
image_filename="$stripped.png"

if [ ! -f "$screenshots_dir"/"$image_filename" ]
then
	echo "no screenshot found for this plugin."
	echo "hint: use lv2screeny.sh to create one."
	exit
fi

xml_filename="$stripped".xml

if [ ! -f "$xml_dir"/"$xml_filename" ]
then
	echo "no xml file found for this plugin."
	echo "hint: use lv2x2xhtml.sh to create one."
	exit
fi

echo "trying to add screenshot"

tmpfile=`mktemp`

#dont embed screenshot if > 100k
find "$screenshots_dir/$image_filename" -size +100k | grep png
ret=$?
if [ $ret -ne 1 ]
then

echo "========"
echo "SCREENSHOT WAS NOT ADDED (>100K)"
echo "========"

rm -f "$tmpfile"
exit

else

#replace (if any) screenshot generic screenshot
xmlstarlet ed -d "//lv2plugin[@uri='"$1"']/data/screenshot[@type=1]" \
	-s "//lv2plugin/data" \
	-t elem -n 'screenshot' \
	-v "`base64 -w 100000 $screenshots_dir/$image_filename`" \
	-i "//lv2plugin[@uri='"$1"']/data/screenshot[position()=last()]" \
	-t attr -n 'type' -v "1" \
	-i "//lv2plugin[@uri='"$1"']/data/screenshot[position()=last()]" \
	-t attr -n 'encoding' -v "base64" \
	-i "//lv2plugin[@uri='"$1"']/data/screenshot[position()=last()]" \
	-t attr -n 'format' -v "png" \
	 "$xml_dir"/"$xml_filename" > "$tmpfile"
fi


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
