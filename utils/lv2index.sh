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

#set any filter for partial index
echo '<lv2_plugins>' > $tmpfile; \
	ls -1 xhtml/*.xml \
	| while read line; do xmlstarlet sel -t -m "//lv2plugin" -c . "$line" >> $tmpfile; done; \
	echo '</lv2_plugins>' >> $tmpfile

cat << _EOF_
<html>
<head>
<style type="text/css">
table.mystyle
{
border-width: 0 0 1px 1px;
border-spacing: 0;
border-collapse: collapse;
border-style: solid;
}
 
.mystyle td, .mystyle th
{
white-space: nowrap;
margin: 0;
padding: 4px;
border-width: 1px 1px 0 0;
border-style: solid;
}
</style>
</head>
_EOF_

cat $tmpfile \
	| xmlstarlet sel -t -e 'body' -nl \
	-e 'table' -a 'class' -o 'mystyle' -b -nl \
	-e 'tr' \
	-e 'th' -o 'class' -b \
	-e 'th' -o 'name' -b \
	-e 'th' -o 'author' -b \
	-e 'th' -o 'total_ports' -b \
	-e 'th' -o 'control_input_ports' -b \
	-e 'th' -o 'audio_input_ports' -b \
	-e 'th' -o 'atom_input_ports' -b \
	-e 'th' -o 'control_output_ports' -b \
	-e 'th' -o 'audio_output_ports' -b \
	-e 'th' -o 'atom_output_ports' -b \
	-e 'th' -o 'plugin_uri' -b \
	-b \
	-m "//lv2plugin" -s A:T:L 'concat(meta/class,meta/name)' \
	-e 'tr' -nl \
	-e 'td' -v "meta/class" -b -nl \
	-e 'td' -e 'a' -a 'href'\
		-v "concat ( translate( translate( translate(@uri,':','_'),'/','_' ),'#','_' ),'.xhtml' )" -b \
	-v "meta/name" -b \
	-b -nl \
	-e 'td' -v "meta/author/name" -b -nl \
	-e 'td' -v "count(port)" -b -nl \
	-e 'td' -v "count(port[@direction=1 and @type=1])" -b -nl \
	-e 'td' -v "count(port[@direction=1 and @type=2])" -b -nl \
	-e 'td' -v "count(port[@direction=1 and @type=3])" -b -nl \
	-e 'td' -v "count(port[@direction=2 and @type=1])" -b -nl \
	-e 'td' -v "count(port[@direction=2 and @type=2])" -b -nl \
	-e 'td' -v "count(port[@direction=2 and @type=3])" -b -nl \
	-e 'td' -v "meta/uri" -b -nl \
	-b -b -b -nl

echo "</html>"

rm -f $tmpfile
