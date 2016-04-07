<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template name="inline.charseq">
      <xsl:param name="content">
         <xsl:apply-templates/>
      </xsl:param>
      <xsl:if test="@role='bold'">
         <xsl:text>{\bf </xsl:text>
      </xsl:if>
      <xsl:copy-of select="$content"/>
      <xsl:if test="@role='bold'">
         <xsl:text>}</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template name="inline.boldseq">
      <xsl:param name="content">
         <xsl:apply-templates/>
      </xsl:param>
      <xsl:text>{\bf </xsl:text>
      <xsl:copy-of select="$content"/>
      <xsl:text>}</xsl:text>
   </xsl:template>

   <xsl:template name="inline.italicseq">
      <xsl:param name="content">
         <xsl:apply-templates/>
      </xsl:param>
      <xsl:if test="@role='bold'">
         <xsl:text>{\bf </xsl:text>
      </xsl:if>
      <xsl:text>{\em </xsl:text>
      <xsl:copy-of select="$content"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="@role='bold'">
         <xsl:text>}</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template name="inline.monoseq">
      <xsl:param name="content">
         <xsl:apply-templates/>
      </xsl:param>
      <xsl:if test="@role='bold'">
         <xsl:text>{\bf </xsl:text>
      </xsl:if>
      <xsl:text>{\tt </xsl:text>
      <xsl:copy-of select="$content"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="@role='bold'">
         <xsl:text>}</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template name="inline.boldmonoseq">
      <xsl:param name="content">
         <xsl:apply-templates/>
      </xsl:param>
      <xsl:text>{\bf{\tt </xsl:text>
      <xsl:copy-of select="$content"/>
      <xsl:text>}}</xsl:text>
   </xsl:template>

   <xsl:template name="inline.italicmonoseq">
      <xsl:param name="content">
         <xsl:apply-templates/>
      </xsl:param>
      <xsl:if test="@role='bold'">
         <xsl:text>{\bf </xsl:text>
      </xsl:if>
      <xsl:text>{\tt{\em </xsl:text>
      <xsl:copy-of select="$content"/>
      <xsl:text>}}</xsl:text>
      <xsl:if test="@role='bold'">
         <xsl:text>}</xsl:text>
      </xsl:if>
   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template match="author|editor|othercredit|personname">
      <xsl:call-template name="person.name"/>
   </xsl:template>

   <xsl:template match="authorinitials">
      <xsl:call-template name="inline.charseq"/>
   </xsl:template>

   <xsl:template match="authorgroup">
      <xsl:call-template name="person.name.list"/>
   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template match="emphasis">
      <xsl:call-template name="inline.italicseq"/>
   </xsl:template>

   <xsl:template match="emphasis[@role='bold' or @role='strong']">
      <xsl:call-template name="inline.boldseq"/>
   </xsl:template>

   <xsl:template match="emphasis[@role='underline']">
      <xsl:text>\underbars{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>

   <xsl:template match="emphasis[@role='strikethrough']">
      <xsl:text>\overstrikes{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>

   <xsl:template match="filename">
      <xsl:call-template name="inline.monoseq"/>
   </xsl:template>

   <xsl:template match="literal">
      <xsl:call-template name="inline.monoseq"/>
   </xsl:template>

   <xsl:template match="phrase">
      <xsl:call-template name="inline.charseq"/>
   </xsl:template>

   <xsl:template match="superscript">
      <xsl:text>\high{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>

   <xsl:template match="subscript">
      <xsl:text>\low{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>

</xsl:stylesheet>
