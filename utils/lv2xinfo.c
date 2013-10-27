/*
  Copyright 2007-2011 David Robillard <http://drobilla.net>

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THIS SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

//origin: lilv/utils/lv2info.c
//tb/131026 changes for xml output

#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lv2/lv2plug.in/ns/ext/port-groups/port-groups.h"
#include "lv2/lv2plug.in/ns/ext/presets/presets.h"
#include "lv2/lv2plug.in/ns/ext/event/event.h"

#include "lilv/lilv.h"

#include "lilv_config.h"

#ifdef _MSC_VER
#    define isnan _isnan
#endif

LilvNode* applies_to_pred     = NULL;
LilvNode* control_class       = NULL;
LilvNode* event_class         = NULL;
LilvNode* group_pred          = NULL;
LilvNode* label_pred          = NULL;
LilvNode* preset_class        = NULL;
LilvNode* designation_pred    = NULL;
LilvNode* supports_event_pred = NULL;

static void
print_port(const LilvPlugin* p,
           uint32_t          index,
           float*            mins,
           float*            maxes,
           float*            defaults)
{

	int direction=0; //0 unknown, 1 input, 2 output
	int portType=0; //0 unknown, 1 control, 2 audio, 3 atom

	const LilvPort* port = lilv_plugin_get_port_by_index(p, index);

	if (!port) {
		printf("\t\tERROR: Illegal/nonexistent port\n");
		return;
	}

	const LilvNodes* classes = lilv_port_get_classes(p, port);
	LILV_FOREACH(nodes, i, classes) {
		const LilvNode* value = lilv_nodes_get(classes, i);
		
		if (!strcmp(lilv_node_as_uri(value), "http://lv2plug.in/ns/lv2core#InputPort"))
		{
			direction=1;
		}
		else if (!strcmp(lilv_node_as_uri(value), "http://lv2plug.in/ns/lv2core#OutputPort"))
		{
			direction=2;
		}
		else if (!strcmp(lilv_node_as_uri(value), "http://lv2plug.in/ns/lv2core#ControlPort"))
		{
			portType=1;
		}
		else if (!strcmp(lilv_node_as_uri(value), "http://lv2plug.in/ns/lv2core#AudioPort"))
		{
			portType=2;
		}
		else if (!strcmp(lilv_node_as_uri(value), "http://lv2plug.in/ns/ext/atom#AtomPort"))
		{
			portType=3;
		}
		else
		{
			//unknown
			portType=0;
		}
	}

	const LilvNode* sym = lilv_port_get_symbol(p, port);

	printf("<port index=\"%d\" symbol=\"%s\" direction=\"%d\" type=\"%d\">\n", index, lilv_node_as_string(sym), direction, portType);

	LILV_FOREACH(nodes, i, classes) {
		const LilvNode* value = lilv_nodes_get(classes, i);
		printf("<type>%s</type>\n", lilv_node_as_uri(value));
	}
	
	if (lilv_port_is_a(p, port, event_class)) {
		LilvNodes* supported = lilv_port_get_value(
			p, port, supports_event_pred);
		if (lilv_nodes_size(supported) > 0) {
			LILV_FOREACH(nodes, i, supported) {
				const LilvNode* value = lilv_nodes_get(supported, i);
				printf("<supported_event>%s</supported_event>\n", lilv_node_as_uri(value));
			}
		}
		lilv_nodes_free(supported);
	}

	LilvNode* name = lilv_port_get_name(p, port);

	printf("<name>%s</name>\n", lilv_node_as_string(name));

	lilv_node_free(name);

	LilvNodes* groups = lilv_port_get_value(p, port, group_pred);
	if (lilv_nodes_size(groups) > 0) {
		printf("<group>%s</group>\n",lilv_node_as_string(lilv_nodes_get_first(groups)));
	}
	lilv_nodes_free(groups);

	LilvNodes* designations = lilv_port_get_value(p, port, designation_pred);
	if (lilv_nodes_size(designations) > 0) {
		printf("<designation>%s</designation>\n",lilv_node_as_string(lilv_nodes_get_first(designations)));
	}
	lilv_nodes_free(designations);

	if (lilv_port_is_a(p, port, control_class)) {
		if (!isnan(mins[index]))
			printf("<minimum>%f</minimum>\n", mins[index]);

		if (!isnan(mins[index]))
			printf("<maximum>%f</maximum>\n", maxes[index]);
		if (!isnan(mins[index]))
			printf("<default>%f</default>\n", defaults[index]);
	}

	LilvNodes* properties = lilv_port_get_properties(p, port);

	LILV_FOREACH(nodes, i, properties) {
		printf("<property>%s</property>\n", lilv_node_as_uri(lilv_nodes_get(properties, i)));
	}
	lilv_nodes_free(properties);

	LilvScalePoints* points = lilv_port_get_scale_points(p, port);

	LILV_FOREACH(scale_points, i, points) {
		const LilvScalePoint* point = lilv_scale_points_get(points, i);

		printf("<scale_point value=\"%s\">%s</scale_point>\n",
				lilv_node_as_string(lilv_scale_point_get_value(point)),
				lilv_node_as_string(lilv_scale_point_get_label(point)));

	}
	lilv_scale_points_free(points);

	printf("</port>\n");
}

static void
print_plugin(LilvWorld*        world,
             const LilvPlugin* p)
{
	LilvNode* val = NULL;

	printf("<lv2plugin>\n");
	printf("<meta>\n");

	printf("<uri>%s</uri>\n", lilv_node_as_uri(lilv_plugin_get_uri(p)));

	val = lilv_plugin_get_name(p);
	if (val) {
		printf("<name>%s</name>\n", lilv_node_as_string(val));
		lilv_node_free(val);
	}

	const LilvPluginClass* pclass      = lilv_plugin_get_class(p);
	const LilvNode*       class_label = lilv_plugin_class_get_label(pclass);
	if (class_label) {
		printf("<class>%s</class>\n", lilv_node_as_string(class_label));
	}

	printf("<author>\n");

	val = lilv_plugin_get_author_name(p);
	if (val) {
		printf("<name>%s</name>\n", lilv_node_as_string(val));
		lilv_node_free(val);
	}

	val = lilv_plugin_get_author_email(p);
	if (val) {
		printf("<email>%s</email>\n", lilv_node_as_uri(val));
		lilv_node_free(val);
	}

	val = lilv_plugin_get_author_homepage(p);
	if (val) {
		printf("<homepage>%s</homepage>\n", lilv_node_as_uri(val));
		lilv_node_free(val);
	}

	printf("</author>\n");

	if (lilv_plugin_has_latency(p)) {
		uint32_t latency_port = lilv_plugin_get_latency_port_index(p);
		printf("<latency_port>%d</latency_port>\n", latency_port);

//	} else {
//		printf("\tHas latency:       no\n");
	}

	printf("<bundle>%s</bundle>\n",lilv_node_as_uri(lilv_plugin_get_bundle_uri(p)));

	const LilvNode* binary_uri = lilv_plugin_get_library_uri(p);
	if (binary_uri) {
		printf("<binary>%s</binary>\n",lilv_node_as_uri(lilv_plugin_get_library_uri(p)));
	}

	LilvUIs* uis = lilv_plugin_get_uis(p);
	if (lilv_nodes_size(uis) > 0) {
		printf("<userinterface>\n");

		LILV_FOREACH(uis, i, uis) {
			const LilvUI* ui = lilv_uis_get(uis, i);
			printf("<uri>%s</uri>\n", lilv_node_as_uri(lilv_ui_get_uri(ui)));

			const char* binary = lilv_node_as_uri(lilv_ui_get_binary_uri(ui));

			const LilvNodes* types = lilv_ui_get_classes(ui);
			LILV_FOREACH(nodes, t, types) {
				printf("<class>%s</class>\n",lilv_node_as_uri(lilv_nodes_get(types, t)));
			}

			printf("<bundle>%s</bundle>\n",lilv_node_as_uri(lilv_ui_get_bundle_uri(ui)));

			if (binary)
			{
				printf("<binary>%s</binary>\n", binary);
			}

		}
		printf("</userinterface>\n");
	}
	lilv_uis_free(uis);

	const LilvNodes* data_uris = lilv_plugin_get_data_uris(p);
	LILV_FOREACH(nodes, i, data_uris) {

		printf("<data_uri>%s</data_uri>\n", lilv_node_as_uri(lilv_nodes_get(data_uris, i)));
	}

	/* Required Features */

	LilvNodes* features = lilv_plugin_get_required_features(p);

	LILV_FOREACH(nodes, i, features) {
		printf("<required_feature>%s</required_feature>\n", lilv_node_as_uri(lilv_nodes_get(features, i)));
	}
	lilv_nodes_free(features);

	/* Optional Features */

	features = lilv_plugin_get_optional_features(p);
	LILV_FOREACH(nodes, i, features) {
		printf("<optional_feature>%s</optional_feature>\n", lilv_node_as_uri(lilv_nodes_get(features, i)));
	}
	lilv_nodes_free(features);

	/* Extension Data */

	LilvNodes* data = lilv_plugin_get_extension_data(p);
	if (data)
	LILV_FOREACH(nodes, i, data) {
		printf("<extension_data>%s</extension_data>\n", lilv_node_as_uri(lilv_nodes_get(data, i)));
	}
	lilv_nodes_free(data);

	/* Presets */

	LilvNodes* presets = lilv_plugin_get_related(p, preset_class);
	LILV_FOREACH(nodes, i, presets) {
		const LilvNode* preset = lilv_nodes_get(presets, i);
		lilv_world_load_resource(world, preset);
		LilvNodes* titles = lilv_world_find_nodes(
			world, preset, label_pred, NULL);
		if (titles) {
			const LilvNode* title = lilv_nodes_get_first(titles);
			printf("<preset>%s</preset>\n", lilv_node_as_string(title));
			lilv_nodes_free(titles);
//		} else {
//			fprintf(stderr, "Preset <%s> has no rdfs:label\n",lilv_node_as_string(lilv_nodes_get(presets, i)));
		}
	}
	lilv_nodes_free(presets);

	printf("</meta>\n");

	/* Ports */

	const uint32_t num_ports = lilv_plugin_get_num_ports(p);
	float* mins     = (float*)calloc(num_ports, sizeof(float));
	float* maxes    = (float*)calloc(num_ports, sizeof(float));
	float* defaults = (float*)calloc(num_ports, sizeof(float));
	lilv_plugin_get_port_ranges_float(p, mins, maxes, defaults);

	printf("<!-- port direction: 1=in, 2=out -->\n");
	printf("<!-- port type: 1=control, 2=audio 3=atom -->\n");

	for (uint32_t i = 0; i < num_ports; ++i)
		print_port(p, i, mins, maxes, defaults);


	printf("</lv2plugin>\n");

	free(mins);
	free(maxes);
	free(defaults);

}

static void
print_version(void)
{
	printf(
		"lv2info (lilv) " LILV_VERSION "\n"
		"Copyright 2007-2011 David Robillard <http://drobilla.net>\n"
		"2013 Thomas Brand <tom@trellis.ch>\n"
		"License: <http://www.opensource.org/licenses/isc-license>\n"
		"This is free software: you are free to change and redistribute it.\n"
		"There is NO WARRANTY, to the extent permitted by law.\n");
}

static void
print_usage(void)
{
	printf(
//		"Usage: lv2xinfo [OPTION]... PLUGIN_URI\n"
		"Usage: lv2xinfo PLUGIN_URI\n"
		"Print information about an installed LV2 plugin as XML.\n\n"
//		"  -p FILE      Write Turtle description of plugin to FILE\n"
//		"  -m FILE      Add record of plugin to manifest FILE\n"
		"  --help       Display this help and exit\n"
		"  --version    Display version information and exit\n\n"
//		"For -p and -m, Turtle files are appended to (not overwritten),\n"
//		"and @prefix directives are only written if the file was empty.\n"
//		"This allows several plugins to be added to a single file.\n");
		"See also lv2ls, lv2info\n\n");
		
}

int
main(int argc, char** argv)
{
	if (argc == 1) {
		print_usage();
		return 1;
	}

	const char* plugin_file   = NULL;
	const char* manifest_file = NULL;
	const char* plugin_uri    = NULL;
	for (int i = 1; i < argc; ++i) {
		if (!strcmp(argv[i], "--version")) {
			print_version();
			return 0;
		} else if (!strcmp(argv[i], "--help")) {
			print_usage();
			return 0;
/*		} else if (!strcmp(argv[i], "-p")) {
			plugin_file = argv[++i];
		} else if (!strcmp(argv[i], "-m")) {
			manifest_file = argv[++i];
*/
		} else if (argv[i][0] == '-') {
			print_usage();
			return 1;
		} else if (i == argc - 1) {
			plugin_uri = argv[i];
		}
	}

	int ret = 0;

	LilvWorld* world = lilv_world_new();
	lilv_world_load_all(world);

	LilvNode* uri = lilv_new_uri(world, plugin_uri);
	if (!uri) {
		fprintf(stderr, "Invalid plugin URI\n");
		lilv_world_free(world);
		return 1;
	}

	applies_to_pred     = lilv_new_uri(world, LV2_CORE__appliesTo);
	control_class       = lilv_new_uri(world, LILV_URI_CONTROL_PORT);
	event_class         = lilv_new_uri(world, LILV_URI_EVENT_PORT);
	group_pred          = lilv_new_uri(world, LV2_PORT_GROUPS__group);
	label_pred          = lilv_new_uri(world, LILV_NS_RDFS "label");
	preset_class        = lilv_new_uri(world, LV2_PRESETS__Preset);
	designation_pred    = lilv_new_uri(world, LV2_CORE__designation);
	supports_event_pred = lilv_new_uri(world, LV2_EVENT__supportsEvent);

	const LilvPlugins* plugins = lilv_world_get_all_plugins(world);
	const LilvPlugin*  p       = lilv_plugins_get_by_uri(plugins, uri);

	if (p && plugin_file) {
		LilvNode* base = lilv_new_uri(world, plugin_file);

		FILE* plugin_fd = fopen(plugin_file, "a");
		lilv_plugin_write_description(world, p, base, plugin_fd);
		fclose(plugin_fd);

		if (manifest_file) {
			FILE* manifest_fd = fopen(manifest_file, "a");
			lilv_plugin_write_manifest_entry(
				world, p, base, manifest_fd, plugin_file);
			fclose(manifest_fd);
		}
		lilv_node_free(base);
	} else if (p) {
		print_plugin(world, p);
	} else {
		fprintf(stderr, "Plugin not found.\n");
	}

	ret = (p != NULL ? 0 : -1);

	lilv_node_free(uri);

	lilv_node_free(supports_event_pred);
	lilv_node_free(designation_pred);
	lilv_node_free(preset_class);
	lilv_node_free(label_pred);
	lilv_node_free(group_pred);
	lilv_node_free(event_class);
	lilv_node_free(control_class);
	lilv_node_free(applies_to_pred);

	lilv_world_free(world);
	return ret;
}
