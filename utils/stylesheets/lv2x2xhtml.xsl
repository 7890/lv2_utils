<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
  <xsl:output method="xml" doctype-system="about:legacy-compat" omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
  <!--
//tb/131028
inspired by http://edutechwiki.unige.ch/en/XSLT_to_generate_SVG_tutorial
-->
  <xsl:decimal-format name="lv2_decimal_value" decimal-separator="." grouping-separator=" "/>
  <xsl:variable name="audio_port_icon_uri">../svg_icons/lv2_port_type_audio.svg</xsl:variable>
  <xsl:variable name="control_port_icon_uri">../svg_icons/lv2_port_type_control.svg</xsl:variable>
  <xsl:variable name="atom_port_icon_uri">../svg_icons/lv2_port_type_atom.svg</xsl:variable>
  <xsl:variable name="screenshots_uri">../screenshots</xsl:variable>
  <xsl:variable name="this_uri">../stylesheets/lv2x2xhtml.xsl</xsl:variable>

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
  <xsl:variable name="svg_w" select="4 * $plugin_body_width"/>
  <xsl:variable name="svg_h" select="$plugin_body_height"/>

  <xsl:variable name="audio_port_color">000,000,155</xsl:variable>
  <xsl:variable name="control_port_color">000,155,00</xsl:variable>
  <xsl:variable name="atom_port_color">155,000,000</xsl:variable>

  <xsl:variable name="plugin_jalv_gtk_image" select=" concat($screenshots_uri,'/scrot_', translate(  translate(   translate(lv2plugin/meta/uri,':',''),   '/','_'  ),  '#','_' ), '.png' )"/>

  <xsl:template match="//lv2plugin">
    <html xmlns="http://www.w3.org/1999/xhtml">

      <head>
        <meta charset="utf-8"/>
        <title>
          <xsl:value-of select="concat('lv2 Plugin Description: ', meta/name,' (',meta/class,') - By ',meta/author/name)"/>
        </title>
      </head>
      <body>
        <h1>
          <xsl:value-of select="concat(meta/name,' (',meta/class,')')"/>
        </h1>
        <p>By <xsl:value-of select="meta/author/name"/><br/>
		<xsl:variable name="plugin_uri" select="meta/uri"/>
		<a href="{$plugin_uri}"><xsl:value-of select="meta/uri"/></a>
	</p>

        <div style="float:left;margin-top:20px">
          <svg xmlns="http://www.w3.org/2000/svg" width="{$svg_w}" height="{$svg_h}" version="1.1">
            <xsl:call-template name="plugin_graph"/>
          </svg>
        </div>

        <div style="float:left;margin-top:20px">
          <img src="{$plugin_jalv_gtk_image}" alt="jalv.gtk Screenshot"/>
        </div>

        <div style="clear:left"/>
        <xsl:apply-templates select="port[@direction=1 and @type=1]"/>

        <div style="clear:left;margin-top:60px;"/>
	<xsl:apply-templates select="port[@direction=2 and @type=1]"/>
        <div style="clear:left"/>

        <hr/>
        <small>Page generated with lv2xinfo, xmlstarlet, lv2x2xhtml.sh - see <a href="https://github.com/7890/lv2_utils">github repo</a></small>
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
      <!-- scales better in browser than using svg:image -->
      <svg:foreignObject x="0" y="{-25 + $y}" width="40" height="25">
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$audio_port_icon_uri}" width="40" height="25"/>
      </svg:foreignObject>
      <svg:line x1="0" y1="{$y}" x2="{10 + $plugin_body_width}" y2="{$y}" style="stroke:rgb({$audio_port_color});stroke-width:2"/>
      <svg:text x="40" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat(@index,') ',$name)"/>
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
      <svg:a xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#{@symbol}" target="_top">
        <!-- scales better in browser than using svg:image -->
        <svg:foreignObject x="0" y="{-25 + $y}" width="40" height="25">
          <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$atom_port_icon_uri}" width="40" height="25"/>
        </svg:foreignObject>
      </svg:a>
      <svg:line x1="0" y1="{$y}" x2="{10 + $plugin_body_width}" y2="{$y}" style="stroke:rgb({$control_port_color});stroke-width:2"/>
      <svg:text x="40 " y="{$y - 5}" fill="black">
        <xsl:value-of select="concat(@index,') ',$name)"/>
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
      <!-- scales better in browser than using svg:image -->
      <svg:foreignObject x="0" y="{-25 + $y}" width="40" height="25">
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$control_port_icon_uri}" width="40" height="25"/>
      </svg:foreignObject>
      <svg:line x1="0" y1="{$y}" x2="{10 + $plugin_body_width}" y2="{$y}" style="stroke:rgb({$atom_port_color});stroke-width:2"/>
      <!-- needs check! -->
      <svg:text x="40" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat(@index,') ',$name)"/>
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
      <!-- scales better in browser than using svg:image -->
      <svg:foreignObject x="{-30 + 2 * $plugin_body_width}" y="{-25 + $y}" width="40" height="25">
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$audio_port_icon_uri}" width="40" height="25"/>
      </svg:foreignObject>
      <svg:line x1="{-10 + 2 * $plugin_body_width}" y1="{$y}" x2="{3 * $plugin_body_width}" y2="{$y}" style="stroke:rgb({$audio_port_color});stroke-width:2"/>
      <svg:text x="{10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat(@index,') ',$name)"/>
      </svg:text>
      <svg:text x="{10 + 3 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat('(',$symbol,')')"/>
      </svg:text>
    </xsl:for-each>

    <xsl:variable name="audio_outputs" select="count(//port[@direction=2 and @type=2])"/>

<!-- atom output -->

    <xsl:for-each select="//port[@direction=2 and @type=3]">
      <xsl:variable name="y" select="$port_group_spacing_vertical + ($audio_outputs + position()) * $port_spacing_vertical"/>
      <xsl:variable name="symbol" select="@symbol"/>
      <xsl:variable name="name" select="name"/>
      <!-- scales better in browser than using svg:image -->
      <svg:foreignObject x="{-30 + 2 * $plugin_body_width}" y="{-25 + $y}" width="40" height="25">
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$atom_port_icon_uri}" width="40" height="25"/>
      </svg:foreignObject>
      <svg:line x1="{-10 + 2 * $plugin_body_width}" y1="{$y}" x2="{3 * $plugin_body_width}" y2="{$y}" style="stroke:rgb({$control_port_color});stroke-width:2"/>
      <svg:text x="{10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat(@index,') ',$name)"/>
      </svg:text>
      <svg:text x="{10 + 3 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat('(',$symbol,')')"/>
      </svg:text>
    </xsl:for-each>

    <xsl:variable name="atom_outputs" select="count(//port[@direction=2 and @type=3])"/>

<!-- control output -->

    <xsl:for-each select="//port[@direction=2 and @type=1]">
      <xsl:variable name="y" select="2 * $port_group_spacing_vertical + ($audio_outputs + $atom_outputs + position()) * $port_spacing_vertical"/>
      <xsl:variable name="symbol" select="@symbol"/>
      <xsl:variable name="name" select="name"/>
      <!-- scales better in browser than using svg:image -->
      <svg:foreignObject x="{-30 + 2 * $plugin_body_width}" y="{-25 + $y}" width="40" height="25">
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$control_port_icon_uri}" width="40" height="25"/>
      </svg:foreignObject>
      <svg:line x1="{-10 + 2 * $plugin_body_width}" y1="{$y}" x2="{3 * $plugin_body_width}" y2="{$y}" style="stroke:rgb({$atom_port_color});stroke-width:2"/>
      <svg:text x="{10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat(@index,') ',$name)"/>
      </svg:text>
      <svg:text x="{10 + 3 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="concat('(',$symbol,')')"/>
      </svg:text>
    </xsl:for-each>
  </xsl:template>

<!-- end plugin_graph -->


<!-- ==================================== -->

  <!-- port -->
  <xsl:template match="port">

    <a href="#{@symbol}"/>
    <div style="background:rgb(250,250,250);color:rgb(20,20,20);border-style:dotted;margin:10px;padding:5px;width:400px">
      <h2>
        <xsl:value-of select="concat(@index,') ',name)"/>
      </h2>


<xsl:if test="@type=1">
<object type="image/svg+xml" data="{$control_port_icon_uri}" width="40" height="25"/>
CONTROL
</xsl:if>

<xsl:if test="@type=2">
AUDIO
<object type="image/svg+xml" data="{$audio_port_icon_uri}" width="40" height="25"/>
</xsl:if>

<xsl:if test="@type=3">
ATOM
<object type="image/svg+xml" data="{$atom_port_icon_uri}" width="40" height="25"/>
</xsl:if>

<xsl:if test="@direction=1">INPUT -&gt;()</xsl:if>

<xsl:if test="@direction=2">OUTPUT ()-&gt;</xsl:if>

      <p>min:
<span style="float:right;"><xsl:value-of select=" format-number(minimum, '# ###.00', 'lv2_decimal_value') "/></span>
<br/>

max:
<span style="float:right;"><xsl:value-of select=" format-number(maximum, '# ###.00', 'lv2_decimal_value') "/></span>
<br/>

default:
<span style="float:right;"><xsl:value-of select=" format-number(default, '# ###.00', 'lv2_decimal_value') "/></span>
      </p>

      <xsl:for-each select="property">
        <xsl:if test=".='http://lv2plug.in/ns/lv2core#integer'">
          <xsl:value-of select="substring-after(.,'#')"/>
          <br/>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="property">
        <xsl:if test=".='http://lv2plug.in/ns/lv2core#toggled'">
          <xsl:value-of select="substring-after(.,'#')"/>
          <br/>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="property">
        <xsl:if test=".='http://lv2plug.in/ns/lv2core#enumeration'">
          <xsl:value-of select="substring-after(.,'#')"/>
          <br/>
        </xsl:if>
      </xsl:for-each>

      <xsl:if test="scale_point">
      <p>scale points:<br/>
        <xsl:for-each select="scale_point">
	  <xsl:sort order="ascending" data-type="number" select="@value"/>
          <xsl:value-of select="@value"/>
          <span style="float:right;">
            <xsl:value-of select="."/>
          </span>
          <br/>
        </xsl:for-each>
      </p>
      </xsl:if>


    </div>
  </xsl:template>
<!-- end port -->

</xsl:stylesheet>
