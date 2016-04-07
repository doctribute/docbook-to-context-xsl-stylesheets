<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template match="preface|colophon|chapter|dedication">
      <xsl:call-template name="title.map"/>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="preface/title"/>
   <xsl:template match="chapter/title"/>
   <xsl:template match="chapter/titleabbrev"/>
   <xsl:template match="chapter/subtitle"/>
   <xsl:template match="chapter/docinfo|chapterinfo"/>
   <xsl:template match="dedication/title"/>
   <xsl:template match="dedication/subtitle"/>
   <xsl:template match="dedication/titleabbrev"/>

   <xsl:template match="appendix[1]">
      <xsl:text>&#10;\startappendices&#10;</xsl:text>
      <xsl:call-template name="appendix.template"/>
   </xsl:template>

   <xsl:template match="appendix[position()=last()]">
      <xsl:call-template name="appendix.template"/>
      <xsl:text>&#10;\stopappendices&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="appendix[position()=1 and position()=last()]" priority="10">
      <xsl:text>&#10;\startappendices&#10;</xsl:text>
      <xsl:call-template name="appendix.template"/>
      <xsl:text>&#10;\stopappendices&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="appendix">
      <xsl:call-template name="appendix.template"/>
   </xsl:template>

   <xsl:template name="appendix.template">
      <xsl:call-template name="title.map">
         <xsl:with-param name="keyword">
            <xsl:choose>
               <xsl:when test="local-name(..)='book' or
                  local-name(..)='part'"
                  >chapter</xsl:when>
               <xsl:otherwise>sect1</xsl:otherwise>
            </xsl:choose>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="appendix/title"/>
   <xsl:template match="appendix/titleabbrev"/>
   <xsl:template match="appendix/subtitle"/>
   <xsl:template match="appendix/docinfo|appendixinfo"/>

</xsl:stylesheet>
