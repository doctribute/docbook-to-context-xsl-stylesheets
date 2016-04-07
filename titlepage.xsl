<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template match="*" mode="titlepage.mode">
      <!-- if an element isn't found in this mode, try the default mode -->
      <xsl:apply-templates select="."/>
   </xsl:template>

   <xsl:template match="book|article" mode="titlepage.mode">

      <xsl:variable name="info" select="bookinfo|articleinfo|info"/>
      <xsl:variable name="title" select="(title|$info/title)[1]"/>
      <xsl:variable name="subtitle" select="(subtitle|$info/subtitle)[1]"/>

      <xsl:if test="$title">

         <xsl:text>\startstandardmakeup&#10;</xsl:text>
         <xsl:text>\startalignment[middle]&#10;</xsl:text>

         <!-- title -->
         <xsl:text>{\bfd </xsl:text>
         <xsl:value-of select="$title"/>
         <xsl:text>}&#10;</xsl:text>

         <!-- subtitle -->
         <xsl:if test="$subtitle">
            <xsl:text>\blank[2*big]&#10;</xsl:text>
            <xsl:text>{\bfc </xsl:text>
            <xsl:value-of select="$subtitle"/>
            <xsl:text>}&#10;</xsl:text>
         </xsl:if>

         <!-- authors -->
         <xsl:if test="$info/authorgroup">
            <xsl:text>\blank[4*big]&#10;</xsl:text>
            <xsl:text>{\bfb </xsl:text>
            <xsl:apply-templates select="$info/authorgroup" mode="titlepage.mode"/>
            <xsl:text>}&#10;</xsl:text>
         </xsl:if>

         <xsl:text>\stopalignment&#10;</xsl:text>
         <xsl:text>\stopstandardmakeup&#10;</xsl:text>
      </xsl:if>

   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template match="authorgroup" mode="titlepage.mode">
      <xsl:apply-templates mode="titlepage.mode"/>
   </xsl:template>

   <xsl:template match="author" mode="titlepage.mode">
      <xsl:apply-templates mode="titlepage.mode"/>
   </xsl:template>

   <xsl:template match="personname" mode="titlepage.mode">
      <xsl:apply-templates select="firstname" mode="titlepage.mode"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="surname" mode="titlepage.mode"/>
   </xsl:template>

   <xsl:template match="firstname|surname" mode="titlepage.mode">
      <xsl:apply-templates/>
   </xsl:template>

</xsl:stylesheet>
