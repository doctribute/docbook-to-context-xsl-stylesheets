<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:variable name="tex.character.replacement.map"
      select="document($tex.character.replacement.map.filename)"/>

   <xsl:template match="text()">
      <xsl:call-template name="escape">
         <xsl:with-param name="string" select="."/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template name="normalize-escape">
      <xsl:param name="string"/>
      <xsl:variable name="result">
         <xsl:call-template name="escape">
            <xsl:with-param name="string" select="$string"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="normalize-space($result)"/>
   </xsl:template>

   <xsl:template name="escape">
      <xsl:param name="index" select="1"/>
      <xsl:param name="string"/>

      <xsl:variable name="entry"
         select="($tex.character.replacement.map/map/entry[position() = $index])[1]"/>
      <xsl:choose>
         <xsl:when test="$entry">
            <xsl:call-template name="string.subst">
               <xsl:with-param name="string">
                  <xsl:call-template name="escape">
                     <xsl:with-param name="index" select="$index + 1"/>
                     <xsl:with-param name="string" select="$string"/>
                  </xsl:call-template>
               </xsl:with-param>
               <xsl:with-param name="target" select="$entry/@key"/>
               <xsl:with-param name="replacement" select="$entry/@value"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$string"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>
