<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template match="footnote">
      <xsl:text>\footnote</xsl:text>
      <xsl:if test="@id">
         <xsl:text>[</xsl:text>
         <xsl:value-of select="@id"/>
         <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text>{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>

   <xsl:template match="footnoteref">
      <!-- @label is ignored -->
      <xsl:text>\note[</xsl:text>
      <xsl:value-of select="@linkend"/>
      <xsl:text>]</xsl:text>
   </xsl:template>

   <xsl:template match="term/footnote|entry/footnote">
      <xsl:text>\postponenotes\footnote</xsl:text>
      <xsl:if test="@id">
         <xsl:text>[</xsl:text>
         <xsl:value-of select="@id"/>
         <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text>{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>

</xsl:stylesheet>
