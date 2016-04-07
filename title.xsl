<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:variable name="tex.title.command.map" select="document($tex.title.command.map.filename)"/>

   <xsl:template name="title.command.map">
      <xsl:param name="keyword"/>
      <xsl:param name="element.name" select="local-name(.)"/>
      <xsl:variable name="value">
         <xsl:value-of select="($tex.title.command.map/map/entry[@key=$keyword])[1]/@value"/>
      </xsl:variable>
      <xsl:if test="$value = ''">
         <xsl:message>Warning: no mapping for <xsl:value-of select="$keyword"/></xsl:message>
      </xsl:if>
      <xsl:value-of select="$value"/>
   </xsl:template>

   <xsl:template name="title.map">
      <xsl:param name="keyword" select="local-name(.)"/>
      <xsl:param name="title" select="title"/>
      <xsl:param name="titletext" select="''"/>

      <!-- first, the command -->
      <xsl:call-template name="title.command.map">
         <xsl:with-param name="keyword" select="$keyword"/>
      </xsl:call-template>

      <!-- the label if it exists -->
      <xsl:if test="@id">
         <xsl:text>[</xsl:text>
         <xsl:value-of select="@id"/>
         <xsl:text>]</xsl:text>
      </xsl:if>

      <!-- the title itself -->
      <xsl:text>{</xsl:text>
      <xsl:variable name="txt">
         <xsl:apply-templates select="$title/node()[not(self::indexterm)]"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($txt)"/>
      <xsl:text>}</xsl:text>
      <xsl:apply-templates select="$title/node()[self::indexterm]"/>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <!-- currently nothing to do with subtitle -->
   <xsl:template match="subtitle"/>

</xsl:stylesheet>
