<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template match="book|article">

      <xsl:call-template name="defineProcessors"/>
      <xsl:call-template name="defineRegisters"/>
      <xsl:call-template name="setupRegistersHeadText"/>

      <xsl:text>\starttext&#10;</xsl:text>

      <xsl:apply-templates select="." mode="titlepage.mode"/>

      <xsl:call-template name="frontmatter"/>
      <xsl:call-template name="bodymatter"/>
      <xsl:call-template name="backmatter"/>

      <xsl:text>\stoptext&#10;</xsl:text>

   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template name="frontmatter">

      <xsl:text>&#10;\startfrontmatter&#10;</xsl:text>

      <xsl:apply-templates select="dedication"/>

      <!-- The TOC -->
      <xsl:text>&#10;\title{</xsl:text>
      <xsl:call-template name="gentext">
         <xsl:with-param name="key">TableofContents</xsl:with-param>
      </xsl:call-template>
      <xsl:text>}&#10;</xsl:text>
      <xsl:text>&#10;\placecontent&#10;</xsl:text>

      <xsl:apply-templates select="preface"/>

      <xsl:text>&#10;\stopfrontmatter&#10;</xsl:text>

   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template name="bodymatter">

      <xsl:text>&#10;\startbodymatter&#10;</xsl:text>
      <xsl:text>&#10;\setcounter[userpage][1]&#10;</xsl:text>

      <xsl:apply-templates select="*[not(self::preface or self::dedication)]"/>
      <xsl:text>&#10;\stopbodymatter&#10;</xsl:text>

   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template name="backmatter">

      <xsl:if test="index">
         <xsl:call-template name="placeRegisters"/>
      </xsl:if>

   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template match="book/bookinfo"/>
   <xsl:template match="book/info"/>
   <xsl:template match="book/title"/>
   <xsl:template match="book/subtitle"/>
   <xsl:template match="book/titleabbrev"/>

</xsl:stylesheet>
