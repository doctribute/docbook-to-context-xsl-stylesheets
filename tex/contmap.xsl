<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:variable name="map.xml" select="document('contmap.xml')"/>

   <xsl:template name="cont.map">
      <xsl:param name="keyword"/>
      <xsl:param name="element.name" select="local-name(.)"/>
      <xsl:variable name="mapvalue">
         <xsl:value-of select="($map.xml/mapping/map[@key=$keyword])[1]/@text"/>
      </xsl:variable>
      <xsl:if test="$mapvalue =''">
         <xsl:message>Warning: no mapping for <xsl:value-of select="$keyword"/></xsl:message>
      </xsl:if>
      <xsl:value-of select="$mapvalue"/>
   </xsl:template>

</xsl:stylesheet>
