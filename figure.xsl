<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template match="figure|informalfigure">

      <xsl:variable name="location">
         <xsl:choose>
            <xsl:when test="@pgwide = '1'">page</xsl:when>
            <xsl:when test="self::informalfigure">force</xsl:when>
            <xsl:when test="@id">here</xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:variable>

      <xsl:text>\startplacefigure[number=no, </xsl:text>
      <xsl:if test="$location != ''">
         <xsl:text>location={</xsl:text>
         <xsl:value-of select="$location"/>
         <xsl:text>}, </xsl:text>
      </xsl:if>
      <xsl:if test="@id">
         <xsl:text>reference=</xsl:text>
         <xsl:value-of select="@id"/>
         <xsl:text>, </xsl:text>
      </xsl:if>

      <xsl:apply-templates select="title"/>

      <xsl:text>]&#10;</xsl:text>

      <!-- Several images are put in a combination -->
      <xsl:variable name="count" select="count(child::mediaobject[imageobject])"/>

      <xsl:choose>
         <xsl:when test="$count &gt; 1">
            <xsl:text>{\startcombination[nx=1, ny=</xsl:text>
            <xsl:value-of select="$count"/>
            <xsl:text>, align={last, hz, hanging}, style=\itx, after={\blank[10mm]}]&#10;</xsl:text>
            <xsl:apply-templates select="*[not(self::title)]"/>
            <xsl:text>\stopcombination}&#10;</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="*[not(self::title)]"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>\stopplacefigure&#10;</xsl:text>
      <xsl:if test="$location = 'page'">
         <xsl:text>\indentation </xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template match="figure/title">
      <xsl:text>title={</xsl:text>
      <xsl:text>\itx </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>

   <xsl:template match="figure/titleabbrev"/>

</xsl:stylesheet>
