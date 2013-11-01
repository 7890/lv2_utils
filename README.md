lv2_utils
=========

lv2xinfo is 99% equal to lv2info with slightly different output formatting

see http://drobilla.net/software/lilv for more information

```
Usage: lv2xinfo PLUGIN_URI
Print information about an installed LV2 plugin as XML.
```

The XML file can be used to create different representations of the plugin description.

```
#example how to create plugin description and index for
#all lv2 plugins with "invada" in them

cd utils
lv2ls | grep invada | while read line; do \
	./lv2screeny.sh "$line"; \
	./lv2x2xhtml.sh "$line"; \
done

./lv2index.sh > xhtml/index.html

```

Example Output

!output example 1](examples/ex1.png?raw=true)

!output example 2](examples/ex2.png?raw=true)

