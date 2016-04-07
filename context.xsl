<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:exsl="http://exslt.org/common" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template name="string.subst.map">
      <xsl:param name="string"/>
      <xsl:param name="replacementMap"/>
      <xsl:param name="index" select="1"/>

      <xsl:variable name="replacementMapNodeSet" select="exsl:node-set($replacementMap)"/>

      <xsl:variable name="replacedString">
         <xsl:if test="$index &lt;= count($replacementMapNodeSet/entry)">
            <xsl:variable name="entry" select="$replacementMapNodeSet/entry[position() = $index]"/>
            <xsl:call-template name="string.subst">
               <xsl:with-param name="string" select="$string"/>
               <xsl:with-param name="target" select="$entry/@key"/>
               <xsl:with-param name="replacement" select="$entry/@value"/>
            </xsl:call-template>
         </xsl:if>
      </xsl:variable>

      <xsl:choose>
         <xsl:when test="$index &lt; count($replacementMapNodeSet/entry)">
            <xsl:call-template name="string.subst.map">
               <xsl:with-param name="string" select="$replacedString"/>
               <xsl:with-param name="replacementMap" select="$replacementMap"/>
               <xsl:with-param name="index" select="$index + 1"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$replacedString"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="opt.hvalign">
      <xsl:param name="pre"/>
      <xsl:param name="opts" select="@align|@valign"/>
      <xsl:if test="$opts">
         <!-- something to print before the option -->
         <xsl:value-of select="$pre"/>
         <xsl:text>align=</xsl:text>
         <xsl:if test="count($opts) &gt; 1">
            <!-- several alignment options? -->
            <xsl:text>{</xsl:text>
         </xsl:if>
         <xsl:for-each select="$opts">
            <xsl:apply-templates select="." mode="opt">
               <xsl:with-param name="printopt" select="0"/>
            </xsl:apply-templates>
            <xsl:if test="position()!=last()">
               <xsl:text>,</xsl:text>
            </xsl:if>
         </xsl:for-each>
         <xsl:if test="count($opts) &gt; 1">
            <xsl:text>}</xsl:text>
         </xsl:if>
      </xsl:if>
   </xsl:template>

   <!-- Translate DocBook alignment to ConTeXt alignment -->
   <xsl:template match="@align" name="opt.align" mode="opt">
      <xsl:param name="align" select="."/>
      <xsl:param name="printopt" select="1"/>
      <xsl:if test="$printopt=1">
         <xsl:text>align=</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$align='center'">
            <xsl:text>middle</xsl:text>
         </xsl:when>
         <xsl:when test="$align='justify'">
            <xsl:text>right</xsl:text>
         </xsl:when>
         <xsl:when test="$align='right'">
            <xsl:text>left</xsl:text>
         </xsl:when>
         <xsl:when test="$align='left'">
            <xsl:text>right</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>right</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="@valign" name="opt.valign" mode="opt">
      <xsl:param name="align" select="."/>
      <xsl:param name="printopt" select="1"/>
      <xsl:if test="$printopt=1">
         <xsl:text>align=</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$align='middle'">
            <xsl:text>lohi</xsl:text>
         </xsl:when>
         <xsl:when test="$align='top'">
            <xsl:text>high</xsl:text>
         </xsl:when>
         <xsl:when test="$align='bottom'">
            <xsl:text>low</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>normal</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- Process a group of options -->
   <xsl:template name="opt.group">
      <xsl:param name="opts"/>
      <xsl:param name="mode" select="'opt'"/>
      <xsl:for-each select="$opts">
         <xsl:variable name="str">
            <xsl:apply-templates select="." mode="opt"/>
         </xsl:variable>
         <xsl:value-of select="$str"/>
         <!-- Put a separator only if something really printed -->
         <xsl:if test="$str!='' and position()!=last()">
            <xsl:text>,</xsl:text>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template name="href.target">
      <xsl:param name="context" select="."/>
      <xsl:param name="object" select="."/>
      <xsl:text>#</xsl:text>
      <xsl:call-template name="object.id">
         <xsl:with-param name="object" select="$object"/>
      </xsl:call-template>
   </xsl:template>

</xsl:stylesheet>
