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
  <xsl:variable name="svg_w" select="4 * $plugin_body_width"/>
  <xsl:variable name="svg_h" select="$plugin_body_height"/>

  <xsl:variable name="audio_port_color">000,000,155</xsl:variable>
  <xsl:variable name="control_port_color">000,155,00</xsl:variable>
  <xsl:variable name="atom_port_color">155,000,000</xsl:variable>

  <xsl:variable name="plugin_jalv_gtk_image" select=" concat($screenshots_uri,'/scrot_', translate(  translate(   translate(lv2plugin/meta/uri,':',''),   '/','_'  ),  '#','_' ), '.png' )"/>

  <xsl:variable name="plugin_uri" select="//lv2plugin/meta/uri"/>

  <xsl:variable name="max_label_length" select="30"/>

<!-- replaced with inline data -->
  <xsl:variable name="audio_port_icon_uri">svg_icons/lv2_port_type_audio.svg</xsl:variable>
  <xsl:variable name="control_port_icon_uri">svg_icons/lv2_port_type_control.svg</xsl:variable>
  <xsl:variable name="atom_port_icon_uri">svg_icons/lv2_port_type_atom.svg</xsl:variable>
  <xsl:variable name="screenshots_uri">screenshots</xsl:variable>

  <xsl:variable name="audio_port_icon_b64">
PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhLS0gQ3JlYXRlZCB3aXRoIElua3NjYXBlIChodHRwOi8vd3d3Lmlua3NjYXBlLm9yZy8pIC0tPgoKPHN2ZwogICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iCiAgIHhtbG5zOmNjPSJodHRwOi8vY3JlYXRpdmVjb21tb25zLm9yZy9ucyMiCiAgIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyIKICAgeG1sbnM6c3ZnPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIKICAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogICB2ZXJzaW9uPSIxLjAiCiAgIHdpZHRoPSIzNC45OTk5OTIiCiAgIGhlaWdodD0iMjUuMDAwMDA4IgogICB2aWV3Qm94PSIwIDAgMzQuOTc4ODQxIDI0Ljk0ODMzNCIKICAgaWQ9InN2ZzM0OTMiPgogIDxkZWZzCiAgICAgaWQ9ImRlZnMzNDk1IiAvPgogIDxtZXRhZGF0YQogICAgIGlkPSJtZXRhZGF0YTM0OTgiPgogICAgPHJkZjpSREY+CiAgICAgIDxjYzpXb3JrCiAgICAgICAgIHJkZjphYm91dD0iIj4KICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3N2Zyt4bWw8L2RjOmZvcm1hdD4KICAgICAgICA8ZGM6dHlwZQogICAgICAgICAgIHJkZjpyZXNvdXJjZT0iaHR0cDovL3B1cmwub3JnL2RjL2RjbWl0eXBlL1N0aWxsSW1hZ2UiIC8+CiAgICAgICAgPGRjOnRpdGxlPjwvZGM6dGl0bGU+CiAgICAgIDwvY2M6V29yaz4KICAgIDwvcmRmOlJERj4KICA8L21ldGFkYXRhPgogIDxnCiAgICAgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTMyNS4zNjc3MiwtNDY1LjU4NDAyKSIKICAgICBpZD0ibGF5ZXIxIj4KICAgIDxwYXRoCiAgICAgICBkPSJtIDMyOS45MDY5Niw0NjUuNTg0MDIgMjUuOTAwMzcsMCBjIDIuNTE0NzMsMCA0LjUzOTIzLDIuMDM2OTQgNC41MzkyMyw0LjU2NzE0IGwgMCwxNS44NTA2MiBjIDAsMi41MzAyIC0yLjAyNDUsNC41NjcxNCAtNC41MzkyMyw0LjU2NzE0IGwgLTI1LjkwMDM3LDAgYyAtMi41MTQ3NCwwIC00LjUzOTI0LC0yLjAzNjk0IC00LjUzOTI0LC00LjU2NzE0IGwgMCwtMTUuODUwNjIgYyAwLC0yLjUzMDIgMi4wMjQ1LC00LjU2NzE0IDQuNTM5MjQsLTQuNTY3MTQgeiBtIC0zLjk4MjkxLDExLjg3MDMxIDEuMTE2NTEsLTAuMjA3MjQgMTBlLTQsLTAuMjg4MTggYyAwLjAwMiwtMC40MjQ4NSAwLjE4MzE3LC0xLjQ5MzQzIDAuMjc3MzksLTEuNjMyODEgMC4xMjU5NSwtMC4xODYzIDAuMjA1NDksMC4wOSAwLjI1OTU4LDAuOTAxNTggMC4wMjYsMC4zOTAzMiAwLjA3MTQsMC43MzE2OCAwLjEwMDc5LDAuNzU4NTkgMC4wMjk0LDAuMDI2OSAwLjA5MTIsLTAuMzMyNDUgMC4xMzcyNywtMC43OTg1NyAwLjE0MzU4LC0xLjQ1MjQ3IDAuMjM1MzIsLTEuNTIyMjggMC4zNTU0NSwtMC4yNzA0OSBsIDAuMDgzNiwwLjg3MDc4IDAuNDk5NCwwLjEyNjY4IGMgMC41ODU1NywwLjE0ODU0IDAuNjE5NzEsMC4xMjM1NSAwLjg4MzUzLC0wLjY0NjU2IDAuMTg4MjIsLTAuNTQ5NDQgMC4zMDMxOSwtMC41Mjg2NSAwLjMwNTQzLDAuMDU1MiAxMGUtNCwwLjM1Mjc5IDAuMTE4MDEsMC44MTg5NiAwLjIwNDk0LDAuODE4OTYgMC4wMzYxLDAgMC4wOTksLTAuMTQxNDcgMC4xMzk3NiwtMC4zMTQzNyAwLjA4NTUsLTAuMzYyNzkgMC4xOTM3OSwtMC40MDY2OCAwLjI1ODU2LC0wLjEwNDggMC4wNjEsMC4yODQxOSAwLjE2MzUxLDAuMjYzNiAwLjI2MDg1LC0wLjA1MjQgMC4xMTQyMiwtMC4zNzA4NCAwLjI0Njc2LC0wLjMyNDczIDAuMzAxMjMsMC4xMDQ4IDAuMDI3OCwwLjIxOTU1IDAuMDg3OSwwLjM2Njc3IDAuMTQ5NTcsMC4zNjY3NyAwLjA1NjcsMCAwLjEwNDA3LC0wLjAzNTQgMC4xMDUzLC0wLjA3ODYgMTBlLTQsLTAuMDQzMiAwLjA0OCwtMC41NzM3NSAwLjEwNDAyLC0xLjE3ODkzIDAuMDU2LC0wLjYwNTE4IDAuMTAyNzksLTEuMjk3OTUgMC4xMDQwMiwtMS41Mzk1MSAwLjAwNCwtMC44MzQgMC4xMzI5NCwtMC41NjMwNiAwLjE4MzEsMC4zODU1MyAwLjAyNzUsMC41MTk0MiAwLjA3NjksMC45NDQ0IDAuMTA5ODQsMC45NDQ0IDAuMDMyOSwwIDAuMTA5MzQsLTAuMTQxNDcgMC4xNjk3OSwtMC4zMTQzOCAwLjE0NjcxLC0wLjQxOTY4IDAuMjMyMTYsLTAuMzk2MjMgMC4yODY0OCwwLjA3ODYgMC4wMjQ3LDAuMjE2MTMgMC4wODYxLDAuNjk5NDkgMC4xMzYzNiwxLjA3NDEyIDAuMDgyOCwwLjYxNjcgMC4wOTgyLDAuNjU2MjIgMC4xNjI2OSwwLjQxNzY1IDAuMDM5MiwtMC4xNDQ5MyAwLjE1MjMsLTAuOTE1NjQgMC4yNTEzMSwtMS43MTI2OCAwLjI1NTU5LC0yLjA1NzYxIDAuMjkxMDMsLTIuMDYzMjcgMC40MDU3MiwtMC4wNjQ3IDAuMDQ0NSwwLjc3NTg1IDAuMDk5MSwxLjQ1NDEyIDAuMTIxMzIsMS41MDcyNyAwLjAyMjIsMC4wNTMyIDAuMDkxLC0wLjIwNTg4IDAuMTUyOTUsLTAuNTc1NjEgMC4xMzg1OSwtMC44Mjc2MiAwLjI3NzY5LC0wLjg4MzU2IDAuNDM2NTYsLTAuMTc1NTUgMC4xNTUwOSwwLjY5MTIxIDAuMjA3MjgsMC43MjIxOSAwLjIwNzczLDAuMTIzMzIgOGUtNCwtMS4wNjg1MiAwLjIxNjgyLC03LjQ0MDQgMC4yNTg5OSwtNy42Mzk0MyAwLjEwNTUyLC0wLjQ5Nzk4IDAuMTY0NjgsMC40MDQ5NSAwLjIzNTExLDMuNTg4MjIgMC4wOTQzLDQuMjYyMzQgMC4xNjQ4MSw1LjE0NjY2IDAuMjEzNzEsMi42Nzk4NyAwLjAzMzEsLTEuNjY3ODMgMC4wNzE3LC0yLjA1OTY3IDAuMTg2NTQsLTEuODg5ODQgMC4wMjQ1LDAuMDM2MyAwLjA3MzEsMC41Mjc1MyAwLjEwNzk5LDEuMDkxNiAwLjAzNDksMC41NjQwOCAwLjA4MjgsMS4xNDM0OSAwLjEwNjU2LDEuMjg3NTcgMC4wNDMyLDAuMjYxOSAwLjA0MzIsMC4yNjE4OCAwLjA5OCwtMC4wNTI0IDAuMDMwMSwtMC4xNzI5IDAuMDc2NSwtMC41OTE0OSAwLjEwMjk5LC0wLjkzMDE5IDAuMDQxOSwtMC41MzU3OSAwLjA2MTQsLTAuNTk2MjMgMC4xNTAxNSwtMC40NjUwMiAwLjA3MDksMC4xMDQ4MiAwLjEyNjY5LDAuNjI0ODEgMC4xODMxLDEuNzA1NjkgMC4wNSwwLjk1Nzc5IDAuMTAxODYsMS40NzIxMSAwLjEzNTA3LDEuMzM5MzEgMC4wMjk3LC0wLjExODU4IDAuMDksLTEuODU4NjkgMC4xMzQyMiwtMy44NjY5IDAuMDQ0MiwtMi4wMDgyMSAwLjA5NTksLTMuNzY0MjIgMC4xMTQ5LC0zLjkwMjI0IDAuMDk1OSwtMC42OTUyMSAwLjE3MTIyLDAuMjE0NjggMC4yNDIyMiwyLjkyNTE1IDAuMDg5MywzLjQwODAyIDAuMTYyNjEsNC4xMjEzOCAwLjIzNjc5LDIuMzAzNDcgMC4xMDM5OCwtMi41NDgyNiAwLjE5OTQsLTIuNjkwMTUgMC4zMTQ3NiwtMC40NjgwMyAwLjA5MjUsMS43ODA5NyAwLjIwOTE3LDIuMzk0MTUgMC4yMjg3LDEuMjAxNTggMC4wMDcsLTAuNDMyMjcgMC4wMzQ4LC0wLjkyNzQyIDAuMDYxNSwtMS4xMDAzMyAwLjA0MjEsLTAuMjcyMyAwLjA1NDksLTAuMjg2MzMgMC4wOTUyLC0wLjEwNDc5IDAuMDk5MiwwLjQ0Njg1IDAuMTkyNTYsMS42MDkxOSAwLjE5MzA3LDIuNDA1IDMuMmUtNCwwLjUwNjk3IDAuMDI1OSwwLjc5NDEzIDAuMDY1NCwwLjczMzU1IDAuMDM1NywtMC4wNTQ4IDAuMTAxMjcsLTEuODQ0MzYgMC4xNDU3NCwtMy45NzY4OSAwLjA4MTcsLTMuOTE2NTYgMC4xMTIzNSwtNC41NTg1MSAwLjIxNzcsLTQuNTU4NTEgMC4xMDc2MSwwIDAuMTMwNywwLjM1OTEzIDAuMTcxNzksMi42NzIyMyAwLjA0NTUsMi41NTc3MiAwLjEwNzE2LDQuMjgwNzYgMC4xNTA5OSw0LjIxNTkzIDAuMDE1OCwtMC4wMjM0IDAuMDYwNCwtMC40MTE1MiAwLjA5OSwtMC44NjI1NSAwLjAzODcsLTAuNDUxMDQgMC4wODgxLC0wLjg0NjM5IDAuMTA5ODQsLTAuODc4NTcgMC4wODYxLC0wLjEyNzI5IDAuMTcxNDgsMC4yNzk0IDAuMTczNTMsMC44MjYxNyAwLjAwMywwLjcxNjM1IDAuMDgzOCwwLjk1MjYzIDAuMTk4NzMsMC41NzkzNCAwLjE2ODgxLC0wLjU0ODA1IDAuMjQ3NTgsLTAuMjg5MTcgMC4zMzM4OSwxLjA5NzM1IDAuMTE3MDEsMS44Nzk2IDAuMjIzODUsMS40NTA4MSAwLjMxMzMyLC0xLjI1NzUyIDAuMDQxLC0xLjIzOTE4IDAuMDkyMywtMi41Mzc1IDAuMTE0MTQsLTIuODg1MTYgMC4wMzk3LC0wLjYzMjc0IDAuMTI2NjQsLTAuOTkxNTEgMC4yMTAyMiwtMC44Njc4OCAwLjAyNDUsMC4wMzYyIDAuMDczLDEuMjU1NDIgMC4xMDc3NiwyLjcwOTM2IDAuMDM0OCwxLjQ1MzkzIDAuMDc3LDIuNjYzODMgMC4wOTM4LDIuNjg4NjUgMC4wMzI5LDAuMDQ4NyAwLjA4NTQsLTAuNTI5MTUgMC4xNTQ4NywtMS43MDU0NCAwLjA4ODIsLTEuNDkzMjcgMC4yNjIsLTEuMjA2OTkgMC4zNTQ4NywwLjU4NDQ0IDAuMDU5NCwxLjE0NTg4IDAuMTQ1OTcsMS4wOTExIDAuMTY1NjEsLTAuMTA0OCAwLjAxLC0wLjU5NDkgMC4wOTM2LC0wLjk1MDkxIDAuMTc2OTMsLTAuNzUxNDYgMC4wNjQ3LDAuMTU0OCAwLjE3OTgsMS41Mzg1NyAwLjE4MjQsMi4xOTIzNyAwLjAwMiwwLjQwMTQyIDAuMDI5MSwwLjU1MDE2IDAuMTAxODQsMC41NTAxNiAwLjA3NTYsMCAwLjEwOTA3LC0wLjIzMzUzIDAuMTM4NzIsLTAuOTY5MzMgMC4xMzAxOCwtMy4yMzAyNyAwLjE3NDE5LC0zLjk3OTM3IDAuMjM5NTIsLTQuMDc2MDEgMC4wNDk5LC0wLjA3MzggMC4wODc0LC0wLjA3MzEgMC4xMTg5MiwwLjAwMiAwLjAyNTMsMC4wNjA2IDAuMDc4LDEuMDkwNCAwLjExNjk3LDIuMjg4MzggMC4wODc1LDIuNjg2NiAwLjE1MTg4LDMuMTE3MzQgMC4yMDgxNywxLjM5MjIgMC4wMjM1LC0wLjcyMDQ1IDAuMDc2OSwtMS4zOTk5OCAwLjExODU5LC0xLjUxMDA2IDAuMDcyOSwtMC4xOTI0MyAwLjA3OTIsLTAuMTkwOTQgMC4xNjIzMiwwLjAzODkgMC4wNDc2LDAuMTMxNDUgMC4xMDM5MSwwLjc5OTE5IDAuMTI1MjUsMS40ODM4NiAwLjAyMTMsMC42ODQ2NyAwLjA2NTksMS4yNDQ4NiAwLjA5OTIsMS4yNDQ4NiAwLjAzMzIsMCAwLjA2MDQsLTAuMTU4MDIgMC4wNjA0LC0wLjM1MTE0IDAsLTAuNDYzMTUgMC4xMzcyMiwtMS4wMzA4NSAwLjIzNzI0LC0wLjk4MTUyIDAuMDQzNywwLjAyMTUgMC4xMDM4MywwLjE4ODczIDAuMTMzNjMsMC4zNzE1MyAwLjAyOTgsMC4xODI4MSAwLjA3OTMsMC40ODU2MyAwLjEwOTk4LDAuNjcyOTUgMC4wMzEzLDAuMTkxMzkgMC4xMDExNywwLjM0MDU3IDAuMTU5NCwwLjM0MDU3IDAuMDc4NiwwIDAuMTA3NTEsLTAuMTY0MTggMC4xMTk3NiwtMC42ODExNSAwLjAzMzcsLTEuNDE5MzQgMC4xNzIwNywtMy42OTczMiAwLjI0MDkzLC0zLjk2NTIzIDAuMDY0NiwtMC4yNTE1IDAuMDc4NiwtMC4yNjA1MyAwLjE0MjM5LC0wLjA5MiAwLjAzODksMC4xMDI3OSAwLjEyMjA5LDEuMjIyNzcgMC4xODQ4OCwyLjQ4ODgzIDAuMDYyOCwxLjI2NjA2IDAuMTM1OTgsMi4zMDE5MyAwLjE2MjYzLDIuMzAxOTMgMC4wNTY2LDAgMC4xMzg1NywtMC44MDIzMSAwLjEzODU3LC0xLjM1NjkgMCwtMC4yMTE0OSAwLjA0MTUsLTAuNDY4NTMgMC4wOTIzLC0wLjU3MTIgMC4wODI5LC0wLjE2NzY1IDAuMTAxNTksLTAuMTcwMDkgMC4xODM1OSwtMC4wMjM5IDAuMDUwMiwwLjA4OTUgMC4xMDc5OSwwLjQ1OTIzIDAuMTI4MzksMC44MjE2MSAwLjA0NjYsMC44Mjc3NyAwLjE2NjQxLDEuMTMwNDQgMC40NDc0OSwxLjEzMDQ0IDAuMjAwNzMsMCAwLjIxMDk1LC0wLjAyMTUgMC4yMTE5MywtMC40NDUzNyAwLjAwMiwtMC43NDE5OSAwLjEzNjU3LC00LjA4NjA5IDAuMTgxNzIsLTQuNTA2MSAwLjA0NDcsLTAuNDE2IDAuMTI2OTEsLTAuNTA2MzEgMC4yMDA5NywtMC4yMjA4MiAwLjAyNDYsMC4wOTQ3IDAuMDc2MiwxLjA0OTYxIDAuMTE0NjQsMi4xMjIwNiAwLjA3NDgsMi4wODQzNyAwLjEzNDE1LDMuMDkyNjkgMC4xNzgxOSwzLjAyNzU0IDAuMDE1LC0wLjAyMjIgMC4wNjI0LC0wLjYwMzgyIDAuMTA1MzUsLTEuMjkyNTQgMC4xMTgwNiwtMS44OTM1MiAwLjI3Njk5LC0xLjkyNTI2IDAuNDE3MTEsLTAuMDgzMyAwLjA0NTgsMC42MDE4MSAwLjEwMSwxLjE2MjY3IDAuMTIyNzEsMS4yNDYzNSAwLjAyNDksMC4wOTYxIDAuMTM4NzIsMC4xNTIxNiAwLjMwODkxLDAuMTUyMTYgbCAwLjI2OTQ0LDAgMC4wNDM5LC0wLjkxNjkzIGMgMC4xODA2MywtMy43NzIzMiAwLjIwMjQyLC00LjAwOTA4IDAuMzM2MzUsLTMuNjU1MDggMC4wNTk4LDAuMTU4MTUgMC4xMzc0NSwxLjMwMzIyIDAuMjQwNjcsMy41NTAyOCAwLjAyMzIsMC41MDQzMiAwLjA2NzUsMC45MTY5NCAwLjA5ODUsMC45MTY5NCAwLjAzMSwwIDAuMDc4NiwtMC4yMTgyMyAwLjEwNTYxLC0wLjQ4NDk3IDAuMDkyNiwtMC45MTM5MiAwLjE5OTQ3LC0xLjAyMTMyIDAuMzI1NDIsLTAuMzI3MTcgMC4wNDQ0LDAuMjQ0OTUgMC4xMTI5NCwwLjU2MzI1IDAuMTUyMjMsMC43MDczNSBsIDAuMDcxNCwwLjI2MTk4IDAuMTA2NjEsLTAuMjM0NDUgMC4xMDY2MSwtMC4yMzQ0NSAwLjE5ODc3LDAuMjA5MzcgMC4xOTg3NiwwLjIwOTM1IDAuMDQwOCwtMC42NTYwNyBjIDAuMDIyNCwtMC4zNjA4MyAwLjA3MzUsLTEuNDM0MTUgMC4xMTM0MiwtMi4zODUxNCAwLjA3ODcsLTEuODczMzUgMC4xMjU4OSwtMi40MTAyNCAwLjIxMTc3LC0yLjQxMDI0IDAuMTE0MDUsMCAwLjE1Mjc4LDAuNDE4OSAwLjIxODAzLDIuMzU3ODQgMC4wODM1LDIuNDgyNTIgMC4xMzE4MSwzLjE4MjE4IDAuMjA1NywyLjk4MTU3IDAuMDMwOCwtMC4wODM3IDAuMDc5MiwtMC40MTE1MiAwLjEwNzU0LC0wLjcyODUyIDAuMDU3LC0wLjYzOCAwLjE1MTE0LC0wLjk3OTAyIDAuMjQ2MjksLTAuODkyMDQgMC4wMzQzLDAuMDMxMyAwLjEwMDk1LDAuNDExMjYgMC4xNDgxOCwwLjg0NDI4IDAuMDQ3MiwwLjQzMzAyIDAuMTEyNTMsMC44MTE3IDAuMTQ1MTMsMC44NDE1IDAuMDMyNiwwLjAyOTggMC4xMDI0OCwtMC4xMDEyMyAwLjE1NTI4LC0wLjI5MTE4IGwgMC4wOTYsLTAuMzQ1MzcgMC4xMTk4NywwLjM0MDU3IGMgMC4wNjU5LDAuMTg3MzIgMC4xNDk0OCwwLjM0MDU4IDAuMTg1NjgsMC4zNDA1OCAwLjA3MDgsMCAwLjA4MzEsLTAuMDkzOCAwLjIzNzkzLC0xLjgxNzA3IDAuMDk0LC0xLjA0NjQ1IDAuMTkwNDMsLTEuNDYzNjEgMC4zMDA2NSwtMS4zMDA1NyAwLjA0MywwLjA2MzYgMC4xMjcwMSwxLjAyNDg0IDAuMjEwNjYsMi40MTAyOSBsIDAuMDQyNywwLjcwNzM1IDAuNzA1MDMsMCBjIDAuNTAyOTEsMCAwLjcxMjQ3LC0wLjAzNzYgMC43MzEwNCwtMC4xMzA5OSAwLjAxNDMsLTAuMDcyIDAuMDc3NiwtMC40NjAyMyAwLjE0MDcsLTAuODYyNjQgMC4wNjMxLC0wLjQwMjQxIDAuMTU5NTMsLTAuNzk3OTggMC4yMTQzNCwtMC44NzkwNSAwLjA4NTYsLTAuMTI2NjggMC4xMTAwNCwtMC4wOTAxIDAuMTczNDksMC4yNjAwOCAwLjA0MDYsMC4yMjQxMSAwLjA5NTQsMC42ODAzMyAwLjEyMTY5LDEuMDEzODIgMC4wNTY5LDAuNzIxNCAwLjE1MzY4LDAuNzMwMiAwLjMyMzE4LDAuMDI5NCAwLjA2NjYsLTAuMjc1NTEgMC4xNDE2MSwtMC41MzExOCAwLjE2NjYxLC0wLjU2ODE2IDAuMDcxMSwtMC4xMDUxMiAwLjI0NjM5LDAuMzExODYgMC4yNDYzOSwwLjU4NTk5IDAsMC4yNzkwMyAwLjI5MDY1LDAuNzYxMTYgMC40NTg4NSwwLjc2MTE2IDAuMDYxMSwwIDAuMjQ5NDEsLTAuMTg4NjMgMC40MTg1LC0wLjQxOTE3
IDAuMTY5MDgsLTAuMjMwNTUgMC4zNDAwNCwtMC40MTkxOCAwLjM3OTksLTAuNDE5MTggMC4wMzk5LDAgMC4xMjM2NywwLjExNTU2IDAuMTg2MjMsMC4yNTY3OSAwLjEzMDc2LDAuMjk1MTkgMC41MDA1NSwwLjQ3NTM0IDAuOTc3NDksMC40NzYxOCAwLjI1MDE2LDQuNGUtNCAwLjM4MjUsLTAuMDYzNCAwLjU0MTU0LC0wLjI2MTQgMC4yNTU5OSwtMC4zMTg2MiAwLjMyMTU3LC0wLjMyNTAzIDAuNDQ3OCwtMC4wNDM4IGwgMC4wOTgsMC4yMTgyIDAuMTk2MjQsLTAuMjI4MzUgYyAwLjE0NDk0LC0wLjE2ODY0IDAuMjIwMjMsLTAuMTk4OTMgMC4yODc5MSwtMC4xMTU4NCAwLjEwODA0LDAuMTMyNjMgMS4wMjYzNSwwLjQzMTc1IDEuMzI1NDksMC40MzE3NSAwLjIwMjI1LDAgMC4yMDc5LDAuMDE0MiAwLjIwNzksMC41MjM5NiBsIDAsMC41MjM5NiAtMC41NzI4MywwIGMgLTAuOTAxNjgsMCAtMy4zMTU0MywwLjIxMDM3IC0zLjc4NDA2LDAuMzI5OCAtMC4yMzM3OCwwLjA1OTYgLTAuNDg4MjgsMC4xMDYxNiAtMC41NjU1NCwwLjEwMzUyIC0wLjA3NzMsLTAuMDAzIC0wLjIwODkyLDAuMDkwMyAtMC4yOTI1NiwwLjIwNjUzIGwgLTAuMTUyMDcsMC4yMTEzMyAtMC4xODE2MSwtMC4zNDMyNyAtMC4xODE2MiwtMC4zNDMyNyAtMC4wNjUyLDAuMjU4MjYgYyAtMC4wMzU5LDAuMTQyMDUgLTAuMDg2NCwwLjQ3MDQ3IC0wLjExMjM2LDAuNzI5ODMgLTAuMTAyNTUsMS4wMjU3IC0wLjI4MDYsMC45NTQwNyAtMC40MDIzMSwtMC4xNjE4MyAtMC4wNDcyLC0wLjQzMzAyIC0wLjExNDYxLC0wLjgxMzYgLTAuMTQ5NzYsLTAuODQ1NzIgLTAuMTA2NDEsLTAuMDk3MyAtMC4yNDI0OSwwLjE0MzA0IC0wLjMzMjQ0LDAuNTg3MTMgLTAuMTExNzMsMC41NTE2MiAtMC4yNTYxLDAuNTM1MzMgLTAuNDQ4NTUsLTAuMDUwNiAtMC4xNjc5MywtMC41MTEyNiAtMC4zMjY1LC0wLjY1MDUgLTAuNTQ0NDEsLTAuNDc4IC0wLjE1Mjc2LDAuMTIwOTQgLTAuMTcyMDcsMC4xOTI2MSAtMC4yOTA5OSwxLjA4MDA1IC0wLjA1MDksMC4zODAwOCAtMC4xMTYzNiwwLjYwMjU2IC0wLjE3NzIxLDAuNjAyNTYgLTAuMTA1MTksMCAtMC4xMjQyNSwtMC4wNzI4IC0wLjI1NDEzLC0wLjk3MDU3IC0wLjA4ODgsLTAuNjEzNTYgLTAuMjQ2NzUsLTAuOTcxOTYgLTAuMzA0OTIsLTAuNjkxNzIgLTAuMDE2MywwLjA3ODUgLTAuMDYwNywwLjU1NzY2IC0wLjA5ODcsMS4wNjQ3MiAtMC4xMDQ3OCwxLjM5OTQyIC0wLjIxODI2LDEuMzc3MzUgLTAuMzYzOTEsLTAuMDcwOCAtMC4xMTM1MiwtMS4xMjg2OCAtMC4xODU4NSwtMS4yODEwMSAtMC4yNDA1NiwtMC41MDY2NyAtMC4wOTQ0LDEuMzM1NDkgLTAuMzEyNzUsMS41MTk4MSAtMC4zODIxOSwwLjMyMjU4IC0wLjA0NTksLTAuNzkxNCAtMC4xMzA5MSwtMS4xMTQzOSAtMC4xODg5NSwtMC43MTc5OSAtMC4wMjEsMC4xNDMyNyAtMC4wNzQxLDEuMDE0OTEgLTAuMTE4MTEsMS45MzY5NiAtMC4xMjAxNywyLjUxOTI5IC0wLjIzNTUyLDIuNTcyNDQgLTAuMzU3MTUsMC4xNjQ1NiAtMC4wOTcsLTEuOTE5MjQgLTAuMTMyNTIsLTIuMzEyNTkgLTAuMjA5MTEsLTIuMzEyNTkgLTAuMTAwNjQsMCAtMC4xMzI1NiwwLjMzNTk0IC0wLjIwODEzLDIuMTkwMjkgLTAuMDM4NSwwLjk0NTMgLTAuMDg4MiwxLjc0NTYgLTAuMTEwNDIsMS43Nzg0NSAtMC4wODQ4LDAuMTI1NDkgLTAuMTY2NCwtMC4yNjY0NSAtMC4yMDMzNCwtMC45NzcwNiAtMC4wMjExLC0wLjQwNjI0IC0wLjA2NDIsLTEuMjEwMiAtMC4wOTU3LC0xLjc4NjU2IGwgLTAuMDU3MywtMS4wNDc5MyAtMC4wOTYxLDAuNTk0MDkgYyAtMC4xNzU2NywxLjA4NTU4IC0wLjI3OTc1LDEuMDcyMjUgLTAuNDI5NjgsLTAuMDU1IC0wLjEwMDY0LC0wLjc1Njc0IC0wLjE3Mzg4LC0wLjY0MjQgLTAuMjQxMTksMC4zNzY1NiAtMC4wMjU3LDAuMzg4MzIgLTAuMDY1MSwwLjc3NzM3IC0wLjA4NzgsMC44NjQ1NCAtMC4xMTU3MiwwLjQ0NjA5IC0wLjI3MzE3LC0wLjEwODk3IC0wLjM0ODksLTEuMjMgLTAuMDQ0NCwtMC42NTcyMyAtMC4xMDcxNCwtMC44NDQ4OCAtMC4yMDQ1MywtMC42MTE3NyAtMC4wMjIsMC4wNTI2IC0wLjA3MTQsMC43MDA5NyAtMC4xMDk4OSwxLjQ0MDkgLTAuMDM4NSwwLjczOTkzIC0wLjA4ODQsMS41MDQ3MyAtMC4xMTA4OCwxLjY5OTU1IC0wLjA3MSwwLjYxNDQ1IC0wLjE3OTQ3LDAuMjEwMDQgLTAuMjYyOSwtMC45Nzk5OSBsIC0wLjA3ODcsLTEuMTIyMjMgLTAuMDk0OCwwLjQ4MTAyIGMgLTAuMDk4OCwwLjUwMTAzIC0wLjE5NTI5LDAuNjEwOTggLTAuMjYxMzEsMC4yOTc2NCAtMC4wNDA5LC0wLjE5NDA3IC0wLjE3ODE3LC0xLjU0MTMxIC0wLjE4NDE5LC0xLjgwNzY4IC0wLjAwMywtMC4xMzQ4OCAtMC4wMTI4LC0wLjEzMzg0IC0wLjA2ODYsMC4wMDcgLTAuMDM1OCwwLjA5MDUgLTAuMDk0NSwwLjc1NDI1IC0wLjEzMDQ0LDEuNDc1MDcgLTAuMDYwNSwxLjIxMjgzIC0wLjE3MDg3LDEuODgxNiAtMC4yODMxLDEuNzE1NTggLTAuMDI1NSwtMC4wMzc3IC0wLjA4MDgsLTAuNzQ4MzUgLTAuMTIzMDEsLTEuNTc5MTkgLTAuMDQyMiwtMC44MzA4NCAtMC4xMDAxMywtMS41NDUzNyAtMC4xMjg4NSwtMS41ODc4NSAtMC4xMTAyOSwtMC4xNjMxNCAtMC4xNjczLDAuMjQxMDEgLTAuMjE0NzYsMS41MjI0NyAtMC4wNTE4LDEuMzk4MjkgLTAuMTI1NTEsMi4xMzA4OCAtMC4xOTY4OCwxLjk1NjYxIC0wLjAyMzUsLTAuMDU3MyAtMC4wOTY4LC0wLjUwNTA1IC0wLjE2Mjg1LC0wLjk5NDk2IC0wLjA4ODQsLTAuNjU1MDkgLTAuMTY1MzUsLTAuOTU0MjMgLTAuMjkxLC0xLjEzMDc2IC0wLjExNTEzLC0wLjE2MTc2IC0wLjE3MDgzLC0wLjM1NjAyIC0wLjE3MDgzLC0wLjU5NTc0IDAsLTAuNDUyMTUgLTAuMTI2NzgsLTAuOTU5MDcgLTAuMjA4MDIsLTAuODMxNzkgLTAuMDMzNiwwLjA1MjYgLTAuMDczNSwwLjU2NzIyIC0wLjA4ODgsMS4xNDM1OSAtMC4wMTUyLDAuNTc2MzYgLTAuMDYyNCwxLjEzOCAtMC4xMDQ4NiwxLjI0ODA4IC0wLjA3NDEsMC4xOTIxOSAtMC4wODA2LDAuMTkwNDkgLTAuMTY1MDcsLTAuMDQyOSAtMC4wNDg0LC0wLjEzMzY5IC0wLjEwNDIyLC0wLjY0ODE3IC0wLjEyNDEyLC0xLjE0MzI4IC0wLjAzODcsLTAuOTY0MDIgLTAuMTIxODgsLTEuMzY0MjEgLTAuMjQ1NDYsLTEuMTgxNCAtMC4wNDAyLDAuMDU5NCAtMC4xMDQ5NywwLjk3MjI4IC0wLjE0Mzk2LDIuMDI4NTEgLTAuMDY5OSwxLjg5Mjc5IC0wLjEyNDI5LDIuMzkyIC0wLjI2MDc5LDIuMzkyIC0wLjA4NzksMCAtMC4xMTYzNywtMC4yNzczMyAtMC4yNTIzNiwtMi40NjAzNiAtMC4wNjEsLTAuOTc4NTYgLTAuMTM5NzQsLTEuODIxOTYgLTAuMTc1MDYsLTEuODc0MjMgLTAuMDM4NCwtMC4wNTY4IC0wLjA4MzYsMC4xNTgxNyAtMC4xMTI0NCwwLjUzNTA2IC0wLjA0ODksMC42Mzk5OCAtMC4xMjk3NywwLjk2NSAtMC4yMTAzNCwwLjg0NTgzIC0wLjAyNDUsLTAuMDM2MiAtMC4wODA1LC0wLjM3Njc0IC0wLjEyNDUsLTAuNzU2NzIgLTAuMDQ0LC0wLjM3OTk5IC0wLjA5OTUsLTAuNjkwODkgLTAuMTIzMjMsLTAuNjkwODkgLTAuMDIzOCwwIC0wLjA4MTMsMC41OTc2OSAtMC4xMjc4NSwxLjMyODE5IC0wLjA0NjYsMC43MzA1MSAtMC4xMDIwNSwxLjM1Mzk3IC0wLjEyMzM1LDEuMzg1NDggLTAuMDg3MSwwLjEyODg5IC0wLjE2MDA3LC0wLjI3NzIxIC0wLjIwMjkxLC0xLjEyOTgyIC0wLjA1NDMsLTEuMDgwMTQgLTAuMTE0MzgsLTEuNzE5MjggLTAuMTU1OTIsLTEuNjU3ODQgLTAuMDE2NywwLjAyNDcgLTAuMDc3MSwxLjE3MTQzIC0wLjEzNDI4LDIuNTQ4MjkgLTAuMTE5NTcsMi44ODA0NyAtMC4xNTE3OCwzLjI2MTUzIC0wLjI2MTkxLDMuMDk4NjIgLTAuMDY4NCwtMC4xMDEyMyAtMC4yNTY0NSwtMy41NjIwNyAtMC4yNjQ2NSwtNC44NzE3NSAtMC4wMDQsLTAuNjkwMTMgLTAuMTE1MzEsLTAuNTMzNjcgLTAuMTc1LDAuMjQ2NyAtMC4wOTMzLDEuMjE5NTggLTAuMjIwNDcsMS4yNzQ3NyAtMC4yOTEwMiwwLjEyNjI2IC0wLjA3NzIsLTEuMjU3MTggLTAuMTUzMzUsLTEuMjI0MjQgLTAuMjAzMDYsMC4wODc5IC0wLjEwMDE4LDIuNjQ0IC0wLjEyNzg3LDMuMDQwMDQgLTAuMjA5NywyLjk5OTc4IC0wLjEyMTQ0LC0wLjA1OTggLTAuMTY5MzgsLTAuNTMyNiAtMC4xNzg2NSwtMS43NjIzNiAtMC4wMDUsLTAuNjExMTQgLTAuMDMwOCwtMS40MTI4MSAtMC4wNTgzLC0xLjc4MTQ5IC0wLjA0MTksLTAuNTYyNTMgLTAuMDU3NiwtMC42MTk3NyAtMC4wOTc5LC0wLjM1NTk0IC0wLjAyNjQsMC4xNzI5MSAtMC4wNTE4LDAuODMzMSAtMC4wNTY0LDEuNDY3MDkgLTAuMDEzLDEuNzczMTYgLTAuMTQ5NTQsNC45OTUwNiAtMC4yMTk1Nyw1LjE3OTUxIC0wLjA1NDcsMC4xNDQxNiAtMC4wNjczLDAuMTQ1MTQgLTAuMDk5OSwwLjAwOCAtMC4wMjA1LC0wLjA4NjQgLTAuMDg4MiwtMS41MjQ3MyAtMC4xNTA1OCwtMy4xOTYxOSAtMC4wNjIzLC0xLjY3MTQ0IC0wLjEzODY5LC0zLjIwNDA0IC0wLjE2OTY5LC0zLjQwNTc3IGwgLTAuMDU2NCwtMC4zNjY3NyAtMC4wNTE3LDAuMzE0MzggYyAtMC4wODgsMC41MzUzNyAtMC4xMDc0NSwwLjU5MTY5IC0wLjE4MTAzLDAuNTI0NDIgLTAuMDM5MiwtMC4wMzU5IC0wLjA3MTgsLTAuMTY4NTQgLTAuMDcyNCwtMC4yOTQ4MyAtNmUtNCwtMC4xMjYyOCAtMC4wMzIsLTAuMzAwMzMgLTAuMDY5OCwtMC4zODY3OSAtMC4wNTI5LC0wLjEyMTA1IC0wLjA2OTUsLTAuMDg0OSAtMC4wNzIsMC4xNTcyIC0wLjAxNTEsMS40MTg0MyAtMC4yMDkwMiw2LjY2ODc4IC0wLjI0OTkzLDYuNzY2NzEgLTAuMTI0NDMsMC4yOTc4MSAtMC4xNjU1NywtMC4zMzI2OSAtMC4yMTQzNCwtMy4yODQ2IC0wLjAyODMsLTEuNzEzNDQgLTAuMDc0NCwtMy4xMTUzNCAtMC4xMDIzNiwtMy4xMTUzNCAtMC4wNTI0LDAgLTAuMTEwNjcsMS45MjU2NiAtMC4xNzc2Niw1Ljg2ODQxIC0wLjA0NzgsMi44MTUyMyAtMC4wODgyLDMuNDc1NTEgLTAuMTk1MzksMy4xOTIyOCAtMC4wNDgyLC0wLjEyNzMyIC0wLjA5OTEsLTEuNjM1MDEgLTAuMTM2MTUsLTQuMDI5NSAtMC4wMzI2LC0yLjEwNDM0IC0wLjA3ODcsLTQuMDM4MjggLTAuMTAyNTYsLTQuMjk3NjQgLTAuMDQxOCwtMC40NTQ3NyAtMC4wNDU4LC0wLjQ2MTI4IC0wLjExMDk3LC0wLjE4MjczIC0wLjA5NCwwLjQwMTgxIC0wLjE3MzE2LDAuMjc5OTggLTAuMjczODksLTAuNDIxNjYgLTAuMDc2NCwtMC41MzIzMiAtMC4wOTIyLC0wLjU2ODkyIC0wLjEzODcyLC0wLjMyMTQyIC0wLjAyODksMC4xNTM2MiAtMC4wNzYsMS40MTYgLTAuMTA0NjksMi44MDUzIC0wLjA0ODksMi4zNjU2IC0wLjA5MzMsMi44ODYyMyAtMC4yMDgyOSwyLjQ0MjkgLTAuMDg4LC0wLjMzOTE2IC0wLjE3NTI0LC0yLjI2OTMyIC0wLjE3NzY0LC0zLjkyOTQxIC0wLjAwMSwtMC45MDc3NyAtMC4wMzA0LC0xLjY1MDUgLTAuMDY0NywtMS42NTA1IC0wLjA3NTgsMCAtMC4xMzYxNCwxLjk3MDQ2IC0wLjE4NjA5LDYuMDc4IC0wLjA0NTksMy43NzIyOSAtMC4wOTE2LDQuODgzNTQgLTAuMTk0NTQsNC43MzEyMiAtMC4wNDgzLC0wLjA3MTUgLTAuMTAyMjYsLTEuOTY0MDYgLTAuMTUyNDQsLTUuMzQ2NCAtMC4wNDI3LC0yLjg3OTY5IC0wLjA5NjUsLTUuMjYzNzIgLTAuMTE5NjIsLTUuMjk3ODQgLTAuMDIzMSwtMC4wMzQxIC0wLjA4MTcsMC40ODc3OCAtMC4xMzAyLDEuMTU5NzggLTAuMDQ4NSwwLjY3MTk4IC0wLjExMzg5LDEuMzIwODEgLTAuMTQ1MjQsMS40NDE4MiAtMC4wNTQ5LDAuMjEyMDIgLTAuMDU4NCwwLjIxMDQ5IC0wLjA5NTUsLTAuMDQyIC0wLjAyMTIsLTAuMTQ0MDkgLTAuMDU3MiwtMC43MDk5NyAtMC4wODAxLC0xLjI1NzUxIC0wLjA1MTQsLTEuMjMxNCAtMC4xMDUxMywtMS42NDQ5NyAtMC4xODg0NCwtMS40NTA1NCAtMC4wMzMxLDAuMDc3MyAtMC4wNjA3LDEuNTg0ODEgLTAuMDYxMywzLjM0OTkxIC0xMGUtNCwzLjA5OTg5IC0wLjAyOTQsMy44NjQyNSAtMC4xNDMzNywzLjg2NDI1IC0wLjExNDU2LDAgLTAuMTQ4MywtMC41ODQyNyAtMC4yMjA4NCwtMy44MjQ5NSAtMC4wNDEzLC0xLjg0NDM2IC0wLjEwMDMyLC0zLjQyMDMgLTAuMTMxMTYsLTMuNTAyMDkgLTAuMDY0MywtMC4xNzA2MSAtMC4xMjIxMiwyLjI4NzU2IC0wLjE4MDg1LDcuNjkzODEgLTAuMDM4NSwzLjU0MTM4IC0wLjA5MTYsNC40NjMyMyAtMC4yMDUzOSwzLjU2NTcxIC0wLjAyNjUsLTAuMjA4ODMgLTAuMDc3LC0yLjY5OTg4IC0wLjExMjI0LC01LjUzNTY3IC0wLjAzNTIsLTIuODM1NzggLTAuMDkxNiwtNS4yOTc0MyAtMC4xMjUyMSwtNS40NzAzNCAtMC4xMDA5NSwtMC41MTkwOSAtMC4xODkzNSwtMC4zNTg5NyAtMC4yNDg5NiwwLjQ1MDk2IC0wLjA2MiwwLjg0MzE4IC0wLjE1MDMxLDEuMjc4MTIgLTAuMjU5MzcsMS4yNzgxMiAtMC4wOTMzLDAgLTAuMTMzNjUsLTAuMzA1ODcgLTAuMTYxNTQsLTEuMjI1NjkgLTAuMDEyNiwtMC40MTQ3NyAtMC4wNDM3LC0wLjc4NDk2IC0wLjA2OTIsLTAuODIyNjUgLTAuMTE4MTYsLTAuMTc0NzcgLTAuMTk3NzcsMC4xMzAxMyAtMC4yMDEyNiwwLjc3MDgxIC0wLjAwOCwxLjUxOTkyIC0wLjE1OTkzLDIuNzQ2OTIgLTAuMzExNzUsMi41MjIzNSAtMC4wMTksLTAuMDI4MSAtMC4xMDAzNCwtMC42ODUxNiAtMC4xODA3NSwtMS40NjAxMSAtMC4xODU0OCwtMS43ODc2NSAtMC4yMDI4NSwtMS45MDE0MSAtMC4yNzk1OCwtMS44MzEyNiAtMC4wMzQ4LDAuMDMxOCAtMC4wODM4LDAuMTk1NTYgLTAuMTA4NzQsMC4zNjM4MiAtMC4wMjUsMC4xNjgyNiAtMC4wOTY0LDAuMzY4MTQgLTAuMTU4NjYsMC40NDQxNyAtMC4wNjIzLDAuMDc2IC0wLjE4MjcsMC4zNzA2MiAtMC4yNjc2MSwwLjY1NDY1IGwgLTAuMTU0MzksMC41MTY0MiAtMC4xOTU5NywtMC43Nzg0IGMgLTAuMTA3OCwtMC40MjgxMiAtMC4yMjQ2NSwtMC44ODc0NyAtMC4yNTk2OCwtMS4wMjA3NyAtMC4wNTEzLC0wLjE5NTIzIC0wLjEwODA1LC0wLjIzNTk5IC0wLjI5MTg0LC0wLjIwOTU5IC0wLjE5ODczLDAuMDI4NiAtMC4yNDMyNywwLjA5MzYgLTAuMzQ1NDgsMC41MDQzNSAtMC4wNjQ1LDAuMjU5MzcgLTAuMTYwODcsMC40NzE1NyAtMC4yMTQxLDAuNDcxNTcgLTAuMDUzMiwwIC0wLjEzOTY3LC0wLjIwMDQxIC0wLjE5MjA3LC0wLjQ0NTM3IC0wLjEwMzI1LC0wLjQ4MjY0IC0wLjIyMzUyLC0wLjU5MjA5IC0wLjIyMzUyLC0wLjIwMzQyIDAsMC4xMzMwOCAtMC4wNDM4LDAuMzMwNTIgLTAuMDk3MywwLjQzODc3IC0wLjA5MzksMC4xOTAwMiAtMC4wOTksMC4xODg5IC0wLjE0NjQ2LC0wLjAzMjQgLTAuMDI3LC0wLjEyNjA1IC0wLjA5NTMsLTAuMjI5MTggLTAuMTUxNjMsLTAuMjI5MTggLTAuMDU2NCwwIC0wLjE2Njc1LC0wLjA1ODkgLTAuMjQ1MzQsLTAuMTMwOTkgLTAuMTE3NzMsLTAuMTA3OTQgLTAuMTU1MjMsLTAuMTAzMzIgLTAuMjEzMDEsMC4wMjYyIC0wLjA1OTgsMC4xMzQwMSAtMC4wOTA3LDAuMTIwOTMgLTAuMjA5NTMsLTAuMDg4NyBsIC0wLjEzOTQxLC0wLjI0NTg3IC0wLjA3MTcsMC4yNzg4OSBjIC0wLjAzOTQsMC4xNTMzOCAtMC4wNzE3LDAuMzQzNzYgLTAuMDcxNywwLjQyMzA3IDAsMC4wNzkzIC0wLjAzMTks
MC4xNzMzOCAtMC4wNzEsMC4yMDkwNiAtMC4wODUxLDAuMDc3OCAtMC4yMTE1NSwtMC4zNzM5OSAtMC4yMTQ1NiwtMC43NjY2OSAtMC4wMDIsLTAuMjQzMzMgLTAuMDEyLC0wLjI1NjM1IC0wLjA3NSwtMC4wOTYzIC0wLjA0MDEsMC4xMDE3NyAtMC4xMDg3OCwwLjc1MDE4IC0wLjE1MjcxLDEuNDQwOSAtMC4xMDM1NCwxLjYyNzg1IC0wLjE4NzYzLDEuNjY3MDIgLTAuMzMzOTMsMC4xNTU1MiAtMC4wMzksLTAuNDAzNDUgLTAuMDcyNiwtMC45NjkzMyAtMC4wNzQ2LC0xLjI1NzUxIC0wLjAwNCwtMC42NTU4MSAtMC4xMDQ1NCwtMC40MzgxMiAtMC4xNjQ5NCwwLjM1ODc1IC0wLjA3MzEsMC45NjQ3OSAtMC4yMzE2NCwwLjk2MTY5IC0wLjMwOTEyLC0wLjAwNiAtMC4wNzIzLC0wLjkwMzE0IC0wLjExNTM3LC0wLjkzMDM4IC0xLjQ1NTY3LC0wLjkyMTA5IC0wLjM0NzU5LDIuMDE1NSAwLjE4MjI2LC0wLjI4NDM2IDAuMzg4OTEsLTAuODQ4NjcgeiIKICAgICAgIGlkPSJyZWN0MzQyMCIKICAgICAgIHN0eWxlPSJmaWxsOiMwMDAwZmY7ZmlsbC1vcGFjaXR5OjE7ZmlsbC1ydWxlOmV2ZW5vZGQ7c3Ryb2tlOm5vbmUiIC8+CiAgPC9nPgo8L3N2Zz4K
</xsl:variable>

  <xsl:variable name="control_port_icon_b64">
PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhLS0gQ3JlYXRlZCB3aXRoIElua3NjYXBlIChodHRwOi8vd3d3Lmlua3NjYXBlLm9yZy8pIC0tPgoKPHN2ZwogICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iCiAgIHhtbG5zOmNjPSJodHRwOi8vY3JlYXRpdmVjb21tb25zLm9yZy9ucyMiCiAgIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyIKICAgeG1sbnM6c3ZnPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIKICAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogICB2ZXJzaW9uPSIxLjAiCiAgIHdpZHRoPSIzNS4yMTQwMDUiCiAgIGhlaWdodD0iMjQuOTk5OTAxIgogICB2aWV3Qm94PSIwIDAgMzUuMTkyNzE5IDI0Ljk0ODIyOCIKICAgaWQ9InN2ZzM1MjQiPgogIDxkZWZzCiAgICAgaWQ9ImRlZnMzNTI2IiAvPgogIDxtZXRhZGF0YQogICAgIGlkPSJtZXRhZGF0YTM1MjkiPgogICAgPHJkZjpSREY+CiAgICAgIDxjYzpXb3JrCiAgICAgICAgIHJkZjphYm91dD0iIj4KICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3N2Zyt4bWw8L2RjOmZvcm1hdD4KICAgICAgICA8ZGM6dHlwZQogICAgICAgICAgIHJkZjpyZXNvdXJjZT0iaHR0cDovL3B1cmwub3JnL2RjL2RjbWl0eXBlL1N0aWxsSW1hZ2UiIC8+CiAgICAgICAgPGRjOnRpdGxlPjwvZGM6dGl0bGU+CiAgICAgIDwvY2M6V29yaz4KICAgIDwvcmRmOlJERj4KICA8L21ldGFkYXRhPgogIDxnCiAgICAgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTExMy44Mjg0OCwtNjg1LjU4NjM1KSIKICAgICBpZD0ibGF5ZXIxIj4KICAgIDxwYXRoCiAgICAgICBkPSJtIDExOC4zOTUzNSw2ODUuNTg2MzUgYyAtMi41MzAxNSwwIC00LjU2Njg3LDIuMDM2NzEgLTQuNTY2ODcsNC41NjY4NyBsIDAsMTUuODUxMDUgYyAwLDIuNTMwMTYgMi4wMzY3Miw0LjU2Njg3IDQuNTY2ODcsNC41NjY4NyBsIDI2LjA1ODk4LDAgYyAyLjUzMDE1LDAgNC41NjY4NywtMi4wMzY3MSA0LjU2Njg3LC00LjU2Njg3IGwgMCwtMTUuODUxMDUgYyAwLC0yLjUzMDE2IC0yLjAzNjcyLC00LjU2Njg3IC00LjU2Njg3LC00LjU2Njg3IGwgLTI2LjA1ODk4LDAgeiBtIDMuMzM4OTIsMy4xNTYwOCAzLjY2NzIxLDAgMCwxMC43MjMyIDIuNDI4ODcsMCAwLDMuNDAzMzQgLTIuNDI4ODcsMCAwLDMuNDY5ODIgLTMuNjY3MjEsMCAwLC0zLjQ2OTgyIC0yLjYwOTY0LDAgMCwtMy40MDMzNCAyLjYwOTY0LDAgMCwtMTAuNzIzMiB6IG0gMS40MDA0LDEuMTk4ODYgMCw5LjUyNDM0IDAuNzY0NjEsMCAwLC05LjUyNDM0IC0wLjc2NDYxLDAgeiBtIDAsMTIuOTI3NjggMCwyLjI3MzA0IDAuNzY0NjEsMCAwLC0yLjI3MzA0IC0wLjc2NDYxLDAgeiIKICAgICAgIGlkPSJyZWN0MzQyNyIKICAgICAgIHN0eWxlPSJmaWxsOiMwMGNlMDA7ZmlsbC1vcGFjaXR5OjE7ZmlsbC1ydWxlOmV2ZW5vZGQ7c3Ryb2tlOm5vbmUiIC8+CiAgPC9nPgo8L3N2Zz4K
</xsl:variable>

  <xsl:variable name="atom_port_icon_b64">
PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhLS0gQ3JlYXRlZCB3aXRoIElua3NjYXBlIChodHRwOi8vd3d3Lmlua3NjYXBlLm9yZy8pIC0tPgoKPHN2ZwogICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iCiAgIHhtbG5zOmNjPSJodHRwOi8vY3JlYXRpdmVjb21tb25zLm9yZy9ucyMiCiAgIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyIKICAgeG1sbnM6c3ZnPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIKICAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogICB2ZXJzaW9uPSIxLjAiCiAgIHdpZHRoPSIzNS4wMDAwMDQiCiAgIGhlaWdodD0iMjUuMDAwMDA4IgogICB2aWV3Qm94PSIwIDAgMzQuOTc4ODUyIDI0Ljk0ODMzNSIKICAgaWQ9InN2ZzM0NjIiPgogIDxkZWZzCiAgICAgaWQ9ImRlZnMzNDY0IiAvPgogIDxtZXRhZGF0YQogICAgIGlkPSJtZXRhZGF0YTM0NjciPgogICAgPHJkZjpSREY+CiAgICAgIDxjYzpXb3JrCiAgICAgICAgIHJkZjphYm91dD0iIj4KICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3N2Zyt4bWw8L2RjOmZvcm1hdD4KICAgICAgICA8ZGM6dHlwZQogICAgICAgICAgIHJkZjpyZXNvdXJjZT0iaHR0cDovL3B1cmwub3JnL2RjL2RjbWl0eXBlL1N0aWxsSW1hZ2UiIC8+CiAgICAgICAgPGRjOnRpdGxlPjwvZGM6dGl0bGU+CiAgICAgIDwvY2M6V29yaz4KICAgIDwvcmRmOlJERj4KICA8L21ldGFkYXRhPgogIDxnCiAgICAgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTcyLjQyNDc3OCwtMTY5LjI0MTc3KSIKICAgICBpZD0ibGF5ZXIxIj4KICAgIDxwYXRoCiAgICAgICBkPSJtIDc2Ljk2NDAxOSwxNjkuMjQxNzcgMjUuOTAwMzcxLDAgYyAyLjUxNDc0LDAgNC41MzkyNCwyLjAzNjk0IDQuNTM5MjQsNC41NjcxMyBsIDAsMTUuODUwNjQgYyAwLDIuNTMwMTkgLTIuMDI0NSw0LjU2NzEzIC00LjUzOTI0LDQuNTY3MTMgbCAtMjUuOTAwMzcxLDAgYyAtMi41MTQ3NDEsMCAtNC41MzkyNDEsLTIuMDM2OTQgLTQuNTM5MjQxLC00LjU2NzEzIGwgMCwtMTUuODUwNjQgYyAwLC0yLjUzMDE5IDIuMDI0NSwtNC41NjcxMyA0LjUzOTI0MSwtNC41NjcxMyB6IG0gNC43NDIwMSw1LjkwNDk2IGMgLTAuOTAxMDQ0LDAgLTEuNTc5NzQ1LDAuNDQ3NDcgLTIuMDM2MDMzLDEuMzQyNDUgLTAuNDUwNTE4LDAuODg5MTcgLTAuNjc1NzgsMi4yMjg3MiAtMC42NzU3OCw0LjAxODY2IDAsMS43ODQxNCAwLjIyNTI2MiwzLjEyMzY5IDAuNjc1NzgsNC4wMTg2NiAwLjQ1NjI4OCwwLjg4OTE4IDEuMTM0OTg5LDEuMzMzNzYgMi4wMzYwMzMsMS4zMzM3NiAwLjkwNjg0NSwwIDEuNTg1NTA3LC0wLjQ0NDU4IDIuMDM2MDcxLC0xLjMzMzc2IDAuNDU2Mjg4LC0wLjg5NDk3IDAuNjg0NDMyLC0yLjIzNDUyIDAuNjg0NDcxLC00LjAxODY2IC0zLjllLTUsLTEuNzg5OTQgLTAuMjI4MTgzLC0zLjEyOTQ5IC0wLjY4NDQ3MSwtNC4wMTg2NiAtMC40NTA1NjQsLTAuODk0OTggLTEuMTI5MjI2LC0xLjM0MjQ1IC0yLjAzNjA3MSwtMS4zNDI0NSBtIDAsLTEuMzk0NzcgYyAxLjQ0OTgxMiwwIDIuNTU1ODgzLDAuNTc4MjYgMy4zMTgzMzksMS43MzQ3MyAwLjc2ODIyNCwxLjE1MDY3IDEuMTUyMjg5LDIuODI0MzggMS4xNTIzMzUsNS4wMjExNSAtNC42ZS01LDIuMTkwOTIgLTAuMzg0MTExLDMuODY0NjQgLTEuMTUyMzM1LDUuMDIxMTUgLTAuNzYyNDU2LDEuMTUwNjcgLTEuODY4NTI3LDEuNzI2MDMgLTMuMzE4MzM5LDEuNzI2MDMgLTEuNDQ5Nzc0LDAgLTIuNTU4NzcyLC0wLjU3NTM2IC0zLjMyNjk5NSwtMS43MjYwMyAtMC43NjI0MTYsLTEuMTU2NTEgLTEuMTQzNjQsLTIuODMwMjMgLTEuMTQzNjQsLTUuMDIxMTUgMCwtMi4xOTY3NyAwLjM4MTIyNCwtMy44NzA0OCAxLjE0MzY0LC01LjAyMTE1IDAuNzY4MjIzLC0xLjE1NjQ3IDEuODc3MjIxLC0xLjczNDczIDMuMzI2OTk1LC0xLjczNDczIG0gMTAuMTYyOTM4LDAuMjM1MzUgMS40NzI4NzQsMCAtNC41MDUyNzMsMTQuNjcxMTcgLTEuNDcyODgyLDAgNC41MDUyODEsLTE0LjY3MTE3IG0gMy42OTA4NzQsMTEuNTMyOTggMi44NTkxMzIsMCAwLC05LjkyODk4IC0zLjExMDM4NCwwLjYyNzYyIDAsLTEuNjAzOTUgMy4wOTMwODEsLTAuNjI3NjcgMS43NTAxMiwwIDAsMTEuNTMyOTggMi44NTkxNCwwIDAsMS40ODE5MyAtNy40NTEwODksMCAwLC0xLjQ4MTkzIgogICAgICAgaWQ9InJlY3QzNDQ5IgogICAgICAgc3R5bGU9ImZpbGw6I2ZmMDAwMDtmaWxsLW9wYWNpdHk6MTtmaWxsLXJ1bGU6ZXZlbm9kZDtzdHJva2U6bm9uZSIgLz4KICA8L2c+Cjwvc3ZnPgo=
</xsl:variable>

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
		<a href="{$plugin_uri}"><xsl:value-of select="$plugin_uri"/></a>
	</p>

        <div style="float:left;margin-top:20px">
          <svg xmlns="http://www.w3.org/2000/svg" width="{$svg_w}" height="{$svg_h}" version="1.1">
            <xsl:call-template name="plugin_graph"/>
          </svg>
        </div>

        <div style="float:left;margin-top:20px">
<!--
          <img src="{$plugin_jalv_gtk_image}" alt="jalv.gtk Screenshot"/>
-->
<!--
embed screenshot as base64 string
-->
          <img alt="jalv.gtk Screenshot" src="data:image/png;base64,{//screenshot}"/>

        </div>

        <div style="clear:left"/>
	<div style="float:left;margin-top:20px">
	  <xsl:for-each select="document('../manual_doc/doc.xml')//doc[@uri=$plugin_uri]/p">
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
      <!-- scales better in browser than using svg:image -->
      <svg:foreignObject x="0" y="{-25 + $y}" width="40" height="25">
<!--
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$audio_port_icon_uri}" width="40" height="25"/>
-->
        <object xmlns="http://www.w3.org/1999/xhtml" width="40" height="25" type="image/svg+xml" data="data:image/svg+xml;base64,{$audio_port_icon_b64}"/>

      </svg:foreignObject>
      <svg:line x1="0" y1="{$y}" x2="{10 + $plugin_body_width}" y2="{$y}" style="stroke:rgb({$audio_port_color});stroke-width:2"/>
      <svg:text x="40" y="{$y - 5}" fill="black">
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
      <!-- scales better in browser than using svg:image -->
      <svg:foreignObject x="0" y="{-25 + $y}" width="40" height="25">
<!--
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$atom_port_icon_uri}" width="40" height="25"/>
-->
        <object xmlns="http://www.w3.org/1999/xhtml" width="40" height="25" type="image/svg+xml" data="data:image/svg+xml;base64,{$atom_port_icon_b64}"/>

      </svg:foreignObject>
      <svg:line x1="0" y1="{$y}" x2="{10 + $plugin_body_width}" y2="{$y}" style="stroke:rgb({$atom_port_color});stroke-width:2"/>
      <svg:text x="40 " y="{$y - 5}" fill="black">
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
      <!-- scales better in browser than using svg:image -->
      <svg:foreignObject x="0" y="{-25 + $y}" width="40" height="25">

<!--
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$control_port_icon_uri}" width="40" height="25"/>
-->
        <object xmlns="http://www.w3.org/1999/xhtml" width="40" height="25" type="image/svg+xml" data="data:image/svg+xml;base64,{$control_port_icon_b64}"/>

      </svg:foreignObject>
      </svg:a>
      <svg:line x1="0" y1="{$y}" x2="{10 + $plugin_body_width}" y2="{$y}" style="stroke:rgb({$control_port_color});stroke-width:2"/>
      <!-- needs check! -->
      <svg:text x="40" y="{$y - 5}" fill="black">
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
      <!-- scales better in browser than using svg:image -->
      <svg:foreignObject x="{-30 + 2 * $plugin_body_width}" y="{-25 + $y}" width="40" height="25">
<!--
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$audio_port_icon_uri}" width="40" height="25"/>
-->
        <object xmlns="http://www.w3.org/1999/xhtml" width="40" height="25" type="image/svg+xml" data="data:image/svg+xml;base64,{$audio_port_icon_b64}"/>

      </svg:foreignObject>
      <svg:line x1="{-10 + 2 * $plugin_body_width}" y1="{$y}" x2="{3 * $plugin_body_width}" y2="{$y}" style="stroke:rgb({$audio_port_color});stroke-width:2"/>
      <svg:text x="{10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="substring(concat(@index,') ',$name),1,$max_label_length)"/>
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
<!--
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$atom_port_icon_uri}" width="40" height="25"/>
-->
        <object xmlns="http://www.w3.org/1999/xhtml" width="40" height="25" type="image/svg+xml" data="data:image/svg+xml;base64,{$atom_port_icon_b64}"/>

      </svg:foreignObject>
      <svg:line x1="{-10 + 2 * $plugin_body_width}" y1="{$y}" x2="{3 * $plugin_body_width}" y2="{$y}" style="stroke:rgb({$atom_port_color});stroke-width:2"/>
      <svg:text x="{10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="substring(concat(@index,') ',$name),1,$max_label_length)"/>
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
<!--
        <object xmlns="http://www.w3.org/1999/xhtml" type="image/svg+xml" data="{$control_port_icon_uri}" width="40" height="25"/>
-->
        <object xmlns="http://www.w3.org/1999/xhtml" width="40" height="25" type="image/svg+xml" data="data:image/svg+xml;base64,{$control_port_icon_b64}"/>

      </svg:foreignObject>
      <svg:line x1="{-10 + 2 * $plugin_body_width}" y1="{$y}" x2="{3 * $plugin_body_width}" y2="{$y}" style="stroke:rgb({$control_port_color});stroke-width:2"/>
      <svg:text x="{10 + 2 * $plugin_body_width}" y="{$y - 5}" fill="black">
        <xsl:value-of select="substring(concat(@index,') ',$name),1,$max_label_length)"/>
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
<!--
<object type="image/svg+xml" data="{$control_port_icon_uri}" width="40" height="25"/>
-->
<object xmlns="http://www.w3.org/1999/xhtml" width="40" height="25" type="image/svg+xml" data="data:image/svg+xml;base64,{$control_port_icon_b64}"/>
CONTROL
</xsl:if>

<xsl:if test="@type=2">
<!--
<object type="image/svg+xml" data="{$audio_port_icon_uri}" width="40" height="25"/>
-->
<object xmlns="http://www.w3.org/1999/xhtml" width="40" height="25" type="image/svg+xml" data="data:image/svg+xml;base64,{$audio_port_icon_b64}"/>
AUDIO
</xsl:if>

<xsl:if test="@type=3">
<!--
<object type="image/svg+xml" data="{$atom_port_icon_uri}" width="40" height="25"/>
-->
<object xmlns="http://www.w3.org/1999/xhtml" width="40" height="25" type="image/svg+xml" data="data:image/svg+xml;base64,{$atom_port_icon_b64}"/>
ATOM
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
