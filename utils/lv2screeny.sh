#!/bin/bash

#lv2ls | while read line; do ./autoscreenshot.sh "$line"; sleep 1; done
#//tb/131029

#use always generic ui for now
jalv_cmd="jalv.gtk --generic-ui"

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

outputdir=screenshots

for tool in {jalv.gtk,scrot,sed,convert}; \
	do checkAvail "$tool"; done

mkdir -p "$outputdir"

stripped=`echo "$1" | sed 's/:/_/g' | sed 's/\//_/g' | sed 's/#/_/g'`
filename="$stripped.png"

scrot --delay 2 --focused "$outputdir"/"$filename"_.png &
#jalv.gtk http://gareus.org/oss/lv2/meters#NORstereo_gtk &
$jalv_cmd $1 &
pid=$!
sleep 3
kill -9 $pid

#cut unreasonable menu
convert "$outputdir"/"$filename"_.png -crop +2+29 +repage "$outputdir"/"$filename"

#http://www.imagemagick.org/Usage/annotating/
#write uri to image footer
width=`identify -format %w "$outputdir"/"$filename"`; \
convert -background '#0008' -fill white -gravity center -size ${width}x30 \
caption:"$1" \
"$outputdir"/"$filename" +swap -gravity south -composite \
"$outputdir"/"$filename"_.png

mv "$outputdir"/"$filename"_.png "$outputdir"/"$filename"

ls -1 "$outputdir"/"$filename"

