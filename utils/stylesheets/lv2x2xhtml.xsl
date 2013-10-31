<?xml version="1.0"?>
<xsl:stylesheet 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:svg="http://www.w3.org/2000/svg" 
xmlns="http://www.w3.org/1999/xhtml" 
version="1.0">
  <xsl:output method="xml" doctype-system="about:legacy-compat" omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
  <!--
//tb/131028
inspired by http://edutechwiki.unige.ch/en/XSLT_to_generate_SVG_tutorial
-->
  <xsl:decimal-format name="lv2_decimal_value" decimal-separator="." grouping-separator=" "/>

  <xsl:variable name="plugin_body_width">300</xsl:variable>
  <xsl:variable name="port_spacing_vertical">30</xsl:variable>
  <xsl:variable name="port_group_spacing_vertical">10</xsl:variable>
  <xsl:variable name="total_input_ports" select="count(//port[@direction=1])"/>
  <xsl:variable name="total_output_ports" select="count(//port[@direction=2])"/>
  <xsl:variable name="plugin_body_height">
    <xsl:if test="$total_input_ports &gt;= $total_output_ports">
      <xsl:value-of select="($total_input_ports + 1) * $port_spacing_vertical"/>
    </xsl:if>
    <xsl:if test="$total_input_ports &lt; $total_output_ports">
      <xsl:value-of select="($total_output_ports + 1) * $port_spacing_vertical"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="svg_w" select="3 * $plugin_body_width"/>
  <xsl:variable name="svg_h" select="$plugin_body_height"/>

  <xsl:variable name="audio_port_color">000,000,155</xsl:variable>
  <xsl:variable name="control_port_color">000,155,00</xsl:variable>
  <xsl:variable name="atom_port_color">155,000,000</xsl:variable>

  <xsl:variable name="screenshots_uri">screenshots</xsl:variable>
  <xsl:variable name="plugin_jalv_gtk_image" select=" concat($screenshots_uri,'/scrot_', translate(  translate(   translate(lv2plugin/meta/uri,':',''),   '/','_'  ),  '#','_' ), '.png' )"/>

  <xsl:variable name="plugin_uri" select="//lv2plugin/meta/uri"/>

  <xsl:variable name="index_url">index.html</xsl:variable>

  <xsl:variable name="max_label_length" select="30"/>

  <xsl:variable name="svg_icons_file_uri">../svg_icons/svg_icons.xml</xsl:variable>
  <xsl:variable name="manual_doc_file_uri">../manual_doc/doc.xml</xsl:variable>

  <xsl:variable name="audio_port_in_b64" select="document($svg_icons_file_uri)//icon[@handle='audio_input']/data"/>
  <xsl:variable name="audio_port_out_b64" select="document($svg_icons_file_uri)//icon[@handle='audio_output']/data"/>

  <xsl:variable name="atom_port_in_midi_b64" select="document($svg_icons_file_uri)//icon[@handle='atom_input_midi']/data"/>
  <xsl:variable name="atom_port_out_midi_b64" select="document($svg_icons_file_uri)//icon[@handle='atom_output_midi']/data"/>

  <xsl:variable name="control_port_in_enumeration_b64" select="document($svg_icons_file_uri)//icon[@handle='control_input_enumeration']/data"/>
  <xsl:variable name="control_port_in_toggle_b64" select="document($svg_icons_file_uri)//icon[@handle='control_input_toggle']/data"/>
  <xsl:variable name="control_port_in_float_b64" select="document($svg_icons_file_uri)//icon[@handle='control_input_float']/data"/>

  <xsl:variable name="control_port_out_enumeration_b64" select="document($svg_icons_file_uri)//icon[@handle='control_output_enumeration']/data"/>
  <xsl:variable name="control_port_out_toggle_b64" select="document($svg_icons_file_uri)//icon[@handle='control_output_toggle']/data"/>
  <xsl:variable name="control_port_out_float_b64" select="document($svg_icons_file_uri)//icon[@handle='control_output_float']/data"/>

  <xsl:template match="//lv2plugin">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta charset="utf-8"/>
        <title>
          <xsl:value-of select="concat('lv2 Plugin Description: ', meta/name,' (',meta/class,') - By ',meta/author/name)"/>
        </title>

<style type="text/css">

.control_port_in_enumeration {
	width:35;
	height:25;
	background-image: url("data:image/svg+xml;base64,<xsl:value-of select="$control_port_in_enumeration_b64"/>");
	background-repeat:no-repeat;
}

.control_port_in_toggle {
	width:35;
	height:25;
	background-image: url("data:image/svg+xml;base64,<xsl:value-of select="$control_port_in_toggle_b64"/>");
	background-repeat:no-repeat;
}

.control_port_in_float {
	width:35;
	height:25;
	background-image: url("data:image/svg+xml;base64,<xsl:value-of select="$control_port_in_float_b64"/>");
	background-repeat:no-repeat;
}

.control_port_out_enumeration {
	width:35;
	height:25;
	background-image: url("data:image/svg+xml;base64,<xsl:value-of select="$control_port_out_enumeration_b64"/>");
	background-repeat:no-repeat;
}

.control_port_out_toggle {
	width:35;
	height:25;
	background-image: url("data:image/svg+xml;base64,<xsl:value-of select="$control_port_out_toggle_b64"/>");
	background-repeat:no-repeat;
}

.control_port_out_float {
	width:35;
	height:25;
	background-image: url("data:image/svg+xml;base64,<xsl:value-of select="$control_port_out_float_b64"/>");
	background-repeat:no-repeat;
}

.port_box {
	float:left;
	background:rgb(250,250,250);
	color:rgb(20,20,20);
/*	border-style:dotted;*/
	margin:10px;
	padding:5px;
	width:300px;
}

table.key_value {
	width:100%; margin-bottom:1em; border:1px solid #aaa;
}

.left {text-align:left;}
.right {text-align:right;}

</style>

      </head>
      <body>
        <a name="top_of_page"/>
	<a href="{$index_url}">back to index</a>
        <h1>
          <xsl:value-of select="concat(meta/name,' (',meta/class,')')"/>
        </h1>
        <p>By <xsl:value-of select="meta/author/name"/><br/>
		<a href="{$plugin_uri}"><xsl:value-of select="$plugin_uri"/></a>
	</p>

        <div style="float:left;margin-top:20px">

          <svg xmlns="http://www.w3.org/2000/svg" width="{$svg_w}" height="{$svg_h}" version="1.1" viewbox="0 0 {$svg_w} {$svg_h}">

        <svg:defs>

                <svg:image id="audio_port_in" width="50" height="24" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$audio_port_in_b64}"/>

                <svg:image id="audio_port_out" width="50" height="24" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$audio_port_out_b64}"/>


                <svg:image id="atom_port_in_midi" width="50" height="23" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$atom_port_in_midi_b64}"/>

                <svg:image id="atom_port_out_midi" width="50" height="23" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$atom_port_out_midi_b64}"/>


                <svg:image id="control_port_in_enumeration" width="50" height="24" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$control_port_in_enumeration_b64}"/>

                <svg:image id="control_port_in_toggle" width="50" height="24" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$control_port_in_toggle_b64}"/>

                <svg:image id="control_port_in_float" width="50" height="24" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$control_port_in_float_b64}"/>


                <svg:image id="control_port_out_enumeration" width="50" height="24" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$control_port_out_enumeration_b64}"/>

                <svg:image id="control_port_out_toggle" width="50" height="24" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$control_port_out_toggle_b64}"/>

                <svg:image id="control_port_out_float" width="50" height="24" transform="rotate(-6)"
                xlink:href="data:image/svg+xml;base64,{$control_port_out_float_b64}"/>


        </svg:defs>


            <xsl:call-template name="plugin_graph"/>
          </svg>
        </div>

        <div style="clear:left"/>

        <div style="float:left;margin-top:20px">
<!--
embed screenshot as base64 string
-->
          <img alt="jalv.gtk Screenshot" src="data:image/png;base64,{//screenshot}"/>

        </div>

        <div style="clear:left"/>

	<div style="float:left;margin-top:20px">
	  <xsl:for-each select="document($manual_doc_file_uri)//doc[@uri=$plugin_uri]/p">
		<xsl:element name="p">
			<xsl:value-of select="."/>
		</xsl:element>
	  </xsl:for-each>
	</div>

        <div style="clear:left"/>

        <xsl:apply-templates select="port[@direction=1 and @type=1]"/>

        <div style="clear:left;margin-top:60px;"/>

	<xsl:apply-templates select="port[@direction=2 and @type=1]"/>

        <div style="clear:left"/>

        <hr/>
        <small>Page generated with lv2xinfo, xmlstarlet, lv2x2xhtml.sh - <a href="http://lv2plug.in/ns/lv2core/lv2core.html">lv2 spec</a> - <a href="https://github.com/7890/lv2_utils">lv2_utils on github</a></small>
      </body>
    </html>
  </xsl:template>
<!-- end / -->

  <xsl:template name="plugin_graph">

    <svg:rect x="{$plugin_body_width}" y="0" width="{$plugin_body_width}" height="{$plugin_body_height}" rx="10" ry="10" style="fill:rgb(220,220,255);stroke-width:2;stroke:rgb(0,0,0);opacity:0.3"/>

<!-- ==================================== -->

<!-- audio input -->

    <xsl:for-each select="//port[@direction=1 and @type=2]">
      <xsl:variable name="y" select="position() * $port_spacing_vertical"/>
      <xsl:variable name="symbol" select="@symbol"/>
      <xsl:variable name="name" select="name"/>

      <svg:use x = "0" y = "{-25 + $y}" xlink:href = "#audio_port_in"/>

      <svg:line x1="0" y1="{$y}" x2="{10 + $plugin_body_width}" y2="{$y}" style="stroke:rgb({$audio_port_color});stroke-width:2"/>
      <svg:text x="50" y="{$y - 5}" fill="black">
        <xsl:value-of select="substring(concat(@index,') ',$name),1,$max_label_length)"/>
      </svg:text>
      <svg:text x="{10 + $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat('(',$symbol,')')"/>
      </svg:text>
    </xsl:for-each>

    <xsl:variable name="audio_inputs" select="count(//port[@direction=1 and @type=2])"/>

<!-- atom input -->

    <xsl:for-each select="//port[@direction=1 and @type=3]">
      <xsl:variable name="y" select="$port_group_spacing_vertical + ($audio_inputs + position()) * $port_spacing_vertical"/>
      <xsl:variable name="symbol" select="@symbol"/>
      <xsl:variable name="name" select="name"/>

      <svg:use x = "0" y = "{-25 + $y}" xlink:href = "#atom_port_in_midi"/>

      <svg:line x1="0" y1="{$y}" x2="{10 + $plugin_body_width}" y2="{$y}" style="stroke:rgb({$atom_port_color});stroke-width:2"/>
      <svg:text x="50 " y="{$y - 5}" fill="black">
        <xsl:value-of select="substring(concat(@index,') ',$name),1,$max_label_length)"/>
      </svg:text>
      <svg:text x="{10 + $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat('(',$symbol,')')"/>
      </svg:text>
    </xsl:for-each>

    <xsl:variable name="atom_inputs" select="count(//port[@direction=1 and @type=3])"/>

<!-- control input -->

    <xsl:for-each select="//port[@direction=1 and @type=1]">
      <xsl:variable name="y" select="2 * $port_group_spacing_vertical + ($audio_inputs + $atom_inputs + position()) * $port_spacing_vertical"/>
      <xsl:variable name="symbol" select="@symbol"/>
      <xsl:variable name="name" select="name"/>
      <svg:a xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#{@symbol}" target="_top">

<xsl:choose>
<xsl:when test="property = 'http://lv2plug.in/ns/lv2core#enumeration'">
      <svg:use x = "0" y = "{-25 + $y}" xlink:href = "#control_port_in_enumeration"/>
</xsl:when>
<xsl:when test="property = 'http://lv2plug.in/ns/lv2core#toggled'">
      <svg:use x = "0" y = "{-25 + $y}" xlink:href = "#control_port_in_toggle"/>
</xsl:when>
<xsl:otherwise>
      <svg:use x = "0" y = "{-25 + $y}" xlink:href = "#control_port_in_float"/>
</xsl:otherwise>
</xsl:choose>

      </svg:a>
      <svg:line x1="0" y1="{$y}" x2="{10 + $plugin_body_width}" y2="{$y}" style="stroke:rgb({$control_port_color});stroke-width:2"/>
      <!-- needs check! -->
      <svg:text x="50" y="{$y - 5}" fill="black">
        <xsl:value-of select="substring(concat(@index,') ',$name),1,$max_label_length)"/>
      </svg:text>
      <svg:text x="{10 + $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat('(',$symbol,')')"/>
      </svg:text>
    </xsl:for-each>


<!-- ==================================== -->
<!-- audio output -->

    <xsl:for-each select="//port[@direction=2 and @type=2]">
      <xsl:variable name="y" select="position() * $port_spacing_vertical"/>
      <xsl:variable name="symbol" select="@symbol"/>
      <xsl:variable name="name" select="name"/>

      <svg:use x = "{-50 + 3 * $plugin_body_width}" y = "{-25 + $y}" xlink:href = "#audio_port_out"/>

      <svg:line x1="{-10 + 2 * $plugin_body_width}" y1="{$y}" x2="{3 * $plugin_body_width}" y2="{$y}" style="stroke:rgb({$audio_port_color});stroke-width:2"/>
      <svg:text x="{-10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black" style="text-anchor: end;">
        <xsl:value-of select="concat('(',$symbol,')')"/>
      </svg:text>
      <svg:text x="{10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="substring(concat(@index,') ',$name),1,$max_label_length)"/>
      </svg:text>
    </xsl:for-each>

    <xsl:variable name="audio_outputs" select="count(//port[@direction=2 and @type=2])"/>

<!-- atom output -->

    <xsl:for-each select="//port[@direction=2 and @type=3]">
      <xsl:variable name="y" select="$port_group_spacing_vertical + ($audio_outputs + position()) * $port_spacing_vertical"/>
      <xsl:variable name="symbol" select="@symbol"/>
      <xsl:variable name="name" select="name"/>

      <svg:use x = "{-50 + 3 * $plugin_body_width}" y = "{-25 + $y}" xlink:href = "#atom_port_out_midi"/>

      <svg:line x1="{-10 + 2 * $plugin_body_width}" y1="{$y}" x2="{3 * $plugin_body_width}" y2="{$y}" style="stroke:rgb({$atom_port_color});stroke-width:2"/>
      <svg:text x="{-10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black" style="text-anchor: end;">
        <xsl:value-of select="concat('(',$symbol,')')"/>
      </svg:text>
      <svg:text x="{10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="substring(concat(@index,') ',$name),1,$max_label_length)"/>
      </svg:text>
    </xsl:for-each>

    <xsl:variable name="atom_outputs" select="count(//port[@direction=2 and @type=3])"/>

<!-- control output -->

    <xsl:for-each select="//port[@direction=2 and @type=1]">
      <xsl:variable name="y" select="2 * $port_group_spacing_vertical + ($audio_outputs + $atom_outputs + position()) * $port_spacing_vertical"/>
      <xsl:variable name="symbol" select="@symbol"/>
      <xsl:variable name="name" select="name"/>

      <svg:a xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#{@symbol}" target="_top">

<xsl:choose>
<xsl:when test="property = 'http://lv2plug.in/ns/lv2core#enumeration'">
      <svg:use x = "{-50 + 3 * $plugin_body_width}" y = "{-25 + $y}" xlink:href = "#control_port_out_enumeration"/>
</xsl:when>
<xsl:when test="property = 'http://lv2plug.in/ns/lv2core#toggled'">
      <svg:use x = "{-50 + 3 * $plugin_body_width}" y = "{-25 + $y}" xlink:href = "#control_port_out_toggle"/>
</xsl:when>
<xsl:otherwise>
      <svg:use x = "{-50 + 3 * $plugin_body_width}" y = "{-25 + $y}" xlink:href = "#control_port_out_float"/>
</xsl:otherwise>
</xsl:choose>

      </svg:a>
      <svg:line x1="{-10 + 2 * $plugin_body_width}" y1="{$y}" x2="{3 * $plugin_body_width}" y2="{$y}" style="stroke:rgb({$control_port_color});stroke-width:2"/>
      <svg:text x="{-10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black" style="text-anchor: end;">
        <xsl:value-of select="concat('(',$symbol,')')"/>
      </svg:text>
      <svg:text x="{10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="substring(concat(@index,') ',$name),1,$max_label_length)"/>
      </svg:text>
    </xsl:for-each>
  </xsl:template>

<!-- end plugin_graph -->


<!-- ==================================== -->

  <!-- port -->
  <xsl:template match="port">

    <a name="{@symbol}"/>

    <div class="port_box">
      <h2>
        <xsl:value-of select="concat(@index,') ',name)"/>
      </h2>



<xsl:if test="@direction=1">
<a href="#top_of_page">
<xsl:choose>
<xsl:when test="property = 'http://lv2plug.in/ns/lv2core#enumeration'">
    <div class="control_port_in_enumeration"><br/><br/></div>
control input (enumeration)
</xsl:when>
<xsl:when test="property = 'http://lv2plug.in/ns/lv2core#toggled'">
    <div class="control_port_in_toggle"><br/><br/></div>
control input (toggle)
</xsl:when>
<xsl:otherwise>
    <div class="control_port_in_float"><br/><br/></div>
control intput (float)
</xsl:otherwise>
</xsl:choose>
</a>
</xsl:if>


<xsl:if test="@direction=2">
<a href="#top_of_page">
<xsl:choose>
<xsl:when test="property = 'http://lv2plug.in/ns/lv2core#enumeration'">
    <div class="control_port_out_enumeration"><br/><br/></div>
control output (enumeration)
</xsl:when>
<xsl:when test="property = 'http://lv2plug.in/ns/lv2core#toggled'">
    <div class="control_port_out_toggle"><br/><br/></div>
control output (toggle)
</xsl:when>
<xsl:otherwise>
    <div class="control_port_out_float"><br/><br/></div>
control output (float)
</xsl:otherwise>
</xsl:choose>
</a>
</xsl:if>


<h3>range</h3>
<table class="key_value">
<tr>
	<td>min:</td>
	<td class="right">
		<xsl:if test="minimum &lt; 1 and minimum &gt; -1">0</xsl:if>
		<xsl:value-of select=" format-number(minimum, '# ###.00', 'lv2_decimal_value')"/>

	</td>
</tr>
<tr>
	<td>max:</td>
	<td class="right">
		<xsl:if test="maximum &lt; 1 and maximum &gt; -1">0</xsl:if>
		<xsl:value-of select=" format-number(maximum, '# ###.00', 'lv2_decimal_value')"/>
	</td>
</tr>
<tr>
	<td>default:</td>
	<td class="right">
		<xsl:if test="default &lt; 1 and default &gt; -1">0</xsl:if>
		<xsl:value-of select=" format-number(default, '# ###.00', 'lv2_decimal_value')"/>
	</td>
</tr>
</table>

      <xsl:if test="property">
<h3>properties</h3>
	<ul>
	      <xsl:for-each select="property">
	<li>
       		   <xsl:value-of select="substring-after(.,'#')"/>
	</li>
     		 </xsl:for-each>
	</ul>
	</xsl:if>

      <xsl:if test="scale_point">
<h3>scale points</h3>
<table class="key_value">

        <xsl:for-each select="scale_point">
	  <xsl:sort order="ascending" data-type="number" select="@value"/>

<tr>
	<td>
          <xsl:value-of select="@value"/>
	</td>
	<td class="right">
            <xsl:value-of select="."/>
	</td>

</tr>

        </xsl:for-each>

</table>
      </xsl:if>

    </div>

    <div style="clear:left"/>

  </xsl:template>
<!-- end port -->

</xsl:stylesheet>
