<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template name="xref.xreflabel">
      <!-- called to process an xreflabel...you might use this to make  -->
      <!-- xreflabels come out in the right font for different targets, -->
      <!-- for example. -->
      <xsl:param name="target" select="."/>
      <xsl:value-of select="$target/@xreflabel"/>
   </xsl:template>

</xsl:stylesheet>
