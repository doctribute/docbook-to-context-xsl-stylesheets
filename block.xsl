<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template match="para">
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="formalpara">
      <xsl:text>&#10;{\bf </xsl:text>
      <xsl:apply-templates select="title"/>
      <xsl:text>} </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="formalpara/title">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="blockquote">
      <xsl:text>\blank \setupquotation[left=, right=]</xsl:text>
      <xsl:apply-imports/>
      <xsl:text>\blank&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="blockquote/para">
      <xsl:text>{\it&#10;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}&#10;</xsl:text>
   </xsl:template>

</xsl:stylesheet>
