<?xml version='1.0'?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY lowercase "'abcdefghijklmnopqrstuvwxyz'">
<!ENTITY uppercase "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'">
 ]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:param name="graphic.notations">
      <xsl:text> PNG PDF JPG JPEG GIF TIFF BMP </xsl:text>
   </xsl:param>

   <xsl:template name="is.graphic.format">
      <xsl:param name="format"/>
      <xsl:if test="contains($graphic.notations, concat(' ',$format,' '))">1</xsl:if>
   </xsl:template>

   <xsl:param name="graphic.extensions">
      <xsl:text> bmp gif tif tiff svg png pdf jpg jpeg eps </xsl:text>
   </xsl:param>

   <xsl:template name="is.graphic.extension">
      <xsl:param name="ext"/>
      <xsl:variable name="lcext" select="translate($ext, &uppercase;, &lowercase;)"/>
      <xsl:if test="contains($graphic.extensions, concat(' ', $lcext, ' '))">1</xsl:if>
   </xsl:template>

</xsl:stylesheet>
