<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <!-- sectx mapping -->
   <xsl:template match="sect1|sect2|sect3|sect4|sect5">
      <xsl:call-template name="title.map"/>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="sect1/title"/>
   <xsl:template match="sect2/title"/>
   <xsl:template match="sect3/title"/>
   <xsl:template match="sect4/title"/>
   <xsl:template match="sect5/title"/>

   <!-- section mapping -->
   <xsl:template match="section">
      <xsl:call-template name="sect.map"/>
      <xsl:apply-templates/>
   </xsl:template>

   <!-- simplesect -->
   <xsl:template match="simplesect">
      <xsl:call-template name="sect.map">
         <xsl:with-param name="unumbered" select="1"/>
      </xsl:call-template>
      <xsl:apply-templates/>
   </xsl:template>

   <!-- bridgehead -->
   <xsl:template match="bridgehead">
      <xsl:variable name="title">
         <xsl:apply-templates/>
      </xsl:variable>
      <xsl:variable name="level">
         <xsl:choose>
            <xsl:when
               test="@renderas='sect1' or
                    @renderas='sect2' or
                    @renderas='sect3' or
                    @renderas='sect4' or
                    @renderas='sect5'">
               <xsl:value-of select="substring(@renderas,5,1)"/>
            </xsl:when>
            <!-- nothing specified, try to adapt to the right level -->
            <xsl:otherwise>auto</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:call-template name="title.map">
         <xsl:with-param name="keyword">refsect1</xsl:with-param>
         <xsl:with-param name="title" select="."/>
      </xsl:call-template>
   </xsl:template>


   <xsl:template match="simplesect/title"/>
   <xsl:template match="section/title"/>
   <xsl:template match="sectioninfo"/>
   <xsl:template match="sect1info"/>
   <xsl:template match="sect2info"/>
   <xsl:template match="sect3info"/>
   <xsl:template match="sect4info"/>
   <xsl:template match="sect5info"/>


   <xsl:template name="get.sect.level">
      <xsl:param name="n" select="."/>

      <xsl:variable name="from">
         <xsl:choose>
            <xsl:when test="$n/ancestor::appendix and $n/ancestor::article">
               <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="0"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:choose>
         <xsl:when test="$n/parent::appendix">
            <xsl:value-of select="$from+1"/>
         </xsl:when>
         <xsl:when test="$n/parent::section">
            <xsl:value-of select="count($n/ancestor::section)+$from+1"/>
         </xsl:when>
         <xsl:when test="$n/parent::chapter">1</xsl:when>
         <xsl:when test="$n/parent::article">1</xsl:when>
         <xsl:when test="$n/parent::sect1">2</xsl:when>
         <xsl:when test="$n/parent::sect2">3</xsl:when>
         <xsl:when test="$n/parent::sect3">4</xsl:when>
         <xsl:when test="$n/parent::sect4">5</xsl:when>
         <xsl:when test="$n/parent::sect5">6</xsl:when>
         <xsl:when test="$n/parent::reference">1</xsl:when>
         <xsl:when test="$n/parent::preface">1</xsl:when>
         <xsl:when test="$n/parent::simplesect">
            <xsl:variable name="l">
               <xsl:call-template name="get.sect.level">
                  <xsl:with-param name="n" select="$n/parent::simplesect"/>
               </xsl:call-template>
            </xsl:variable>
            <!-- +100 to say that it is unumbered -->
            <xsl:value-of select="$l+1+100"/>
         </xsl:when>
         <xsl:when test="$n/parent::book">0</xsl:when>
         <xsl:when test="$n/parent::part">0</xsl:when>
         <xsl:otherwise>7</xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="sect.map">
      <xsl:param name="level" select="'auto'"/>
      <xsl:param name="unumbered" select="0"/>
      <xsl:param name="title" select="title"/>
      <xsl:param name="titletext"/>

      <!-- is the level automatic or set? -->
      <xsl:variable name="l1">
         <xsl:choose>
            <xsl:when test="$level='auto'">
               <xsl:call-template name="get.sect.level"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="number($level)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- get the actual level value -->
      <xsl:variable name="l">
         <xsl:choose>
            <xsl:when test="$l1 >= 100">
               <xsl:value-of select="$l1 - 100"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$l1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- is it numbered? -->
      <xsl:variable name="number">
         <xsl:choose>
            <xsl:when test="$l1 >= 100 or $unumbered = 1">
               <xsl:value-of select="0"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- map the level to a section name -->
      <xsl:call-template name="title.map">
         <xsl:with-param name="titletext" select="$titletext"/>
         <xsl:with-param name="title" select="$title"/>
         <xsl:with-param name="keyword">
            <xsl:choose>
               <!-- unnumbered section -->
               <xsl:when test="$number=0">
                  <xsl:choose>
                     <xsl:when test="$l=1">simplesect-2</xsl:when>
                     <xsl:when test="$l=2">simplesect-3</xsl:when>
                     <xsl:when test="$l=3">simplesect-4</xsl:when>
                     <xsl:when test="$l=4">simplesect-5</xsl:when>
                     <xsl:when test="$l=5">simplesect-6</xsl:when>
                     <xsl:when test="$l=0">simplesect-1</xsl:when>
                     <xsl:when test="$l>=6">
                        <xsl:message>simplesect level too depth >=6</xsl:message>
                        <xsl:text>simplesect-6</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:message>simplesect level unknown</xsl:message>
                        <xsl:text>simplesect-1</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <!-- numbered section -->
               <xsl:otherwise>
                  <xsl:choose>
                     <xsl:when test="$l=1">sect1</xsl:when>
                     <xsl:when test="$l=2">sect2</xsl:when>
                     <xsl:when test="$l=3">sect3</xsl:when>
                     <xsl:when test="$l=4">sect4</xsl:when>
                     <xsl:when test="$l=5">sect5</xsl:when>
                     <xsl:when test="$l=0">chapter</xsl:when>
                     <xsl:when test="$l>=6">
                        <xsl:message>section level too depth >=6</xsl:message>
                        <xsl:text>simplesect-6</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:message>section level unknown</xsl:message>
                        <xsl:text>simplesect-1</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

</xsl:stylesheet>
