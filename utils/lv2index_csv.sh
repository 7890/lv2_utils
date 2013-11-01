#!/bin/bash

#//tb/131029

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

for tool in {xmlstarlet,which}; \
	do checkAvail "$tool"; done


tmpfile=`mktemp`

echo '<lv2_plugins>' > $tmpfile; \
	ls -1 xhtml/*.xml \
	| while read line; do xmlstarlet sel -t -m "//lv2plugin" -c . "$line" >> $tmpfile; done; \
	echo '</lv2_plugins>' >> $tmpfile

#csv header
echo "class;name;author;total_ports;control_input_ports;audio_input_ports;atom_input_ports;control_output_ports;audio_output_ports;atom_output_ports;xhtml_uri;plugin_uri;"

cat $tmpfile \
	| xmlstarlet sel -t -m "//lv2plugin" \
	-v "meta/class" -o ";" \
	-v "meta/name" -o ";" \
	-v "meta/author/name" -o ";" \
	-v "count(port)" -o ";" \
	-v "count(port[@direction=1 and @type=1])" \-o ";" \
	-v "count(port[@direction=1 and @type=2])" \-o ";" \
	-v "count(port[@direction=1 and @type=3])" \-o ";" \
	-v "count(port[@direction=2 and @type=1])" \-o ";" \
	-v "count(port[@direction=2 and @type=2])" \-o ";" \
	-v "count(port[@direction=2 and @type=3])" \-o ";" \
	-v "concat ( translate( translate( translate(meta/uri,':','_'),'/','_' ),'#','_' ),'.xhtml' )" -o ";" \
	-v "meta/uri" -o ";" -nl

rm -f $tmpfile
