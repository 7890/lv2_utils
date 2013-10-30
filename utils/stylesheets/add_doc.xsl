<?xml version="1.0"?>
<xsl:stylesheet 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns="http://www.w3.org/1999/xhtml" 
version="1.0">
  <xsl:output method="xml" omit-xml-declaration="no" encoding="UTF-8" indent="yes"/>
  <!--
//tb/131030

//http://stackoverflow.com/questions/17485988/how-can-we-add-a-xml-file-content-to-another-xml-file-at-specific-position

-->

 <xsl:param name="plugin_uri" select="'http://n/a'"/>
 <xsl:param name="manual_doc_uri" select="'../manual_doc/doc.xml'"/>

<xsl:template match="node()|@*">
  <xsl:copy>
    <xsl:copy-of select="node()|@*"/>
    <xsl:copy-of select="document($manual_doc_uri)//doc[@uri=$plugin_uri]"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
