<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:key name="registersTypes" match="//indexterm" use="@type"/>
   <xsl:variable name="registersTypesCount"
      select="count(//indexterm[generate-id() = generate-id(key('registersTypes', @type))])"/>

   <xsl:key name="significanceValues" match="//indexterm[not(@significance = 'normal')]"
      use="@significance"/>
   <xsl:variable name="significanceValuesCount"
      select="count(//indexterm[not(@significance = 'normal')][generate-id() = generate-id(key('significanceValues', @significance))])"/>

   <xsl:template match="indexterm" mode="entries"/>

   <xsl:template match="indexterm" name="indexterm">
      <xsl:param name="isFromRange" select="0"/>
      <xsl:variable name="name">
         <xsl:call-template name="getRegisterName"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$isFromRange = 0">
            <xsl:variable name="command">
               <xsl:choose>
                  <xsl:when test="see|seealso">
                     <xsl:text>\see</xsl:text>
                     <xsl:value-of select="$name"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>\</xsl:text>
                     <xsl:value-of select="$name"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:choose>
               <xsl:when test="parent::title or parent::subtitle or parent::bridgehead">
                  <xsl:value-of select="$command"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="concat('\leftboundary\hbox{', $command)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="primary[@sortas] or secondary[@sortas] or tertiary[@sortas]">
            <xsl:text>[</xsl:text>
            <xsl:if test="@significance and not(@significance = 'normal')">
               <xsl:call-template name="significance"/>
            </xsl:if>
            <xsl:if test="primary[@sortas]">
               <xsl:call-template name="normalize-escape">
                  <xsl:with-param name="string" select="primary/@sortas"/>
               </xsl:call-template>
            </xsl:if>
            <xsl:if test="secondary[@sortas]">
               <xsl:text>+</xsl:text>
               <xsl:call-template name="normalize-escape">
                  <xsl:with-param name="string" select="secondary/@sortas"/>
               </xsl:call-template>
            </xsl:if>
            <xsl:if test="tertiary[@sortas]">
               <xsl:choose>
                  <xsl:when test="secondary[@sortas]">+</xsl:when>
                  <xsl:otherwise>++</xsl:otherwise>
               </xsl:choose>
               <xsl:call-template name="normalize-escape">
                  <xsl:with-param name="string" select="tertiary/@sortas"/>
               </xsl:call-template>
            </xsl:if>
            <xsl:text>]</xsl:text>
         </xsl:when>
         <xsl:when test="@significance and not(@significance = 'normal')">
            <xsl:text>[</xsl:text>
            <xsl:call-template name="significance"/>
            <xsl:text>]</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>{</xsl:text>
      <xsl:call-template name="normalize-escape">
         <xsl:with-param name="string" select="primary"/>
      </xsl:call-template>
      <xsl:if test="secondary">
         <xsl:text>+</xsl:text>
         <xsl:call-template name="normalize-escape">
            <xsl:with-param name="string" select="secondary"/>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="tertiary">
         <xsl:text>+</xsl:text>
         <xsl:call-template name="normalize-escape">
            <xsl:with-param name="string" select="tertiary"/>
         </xsl:call-template>
      </xsl:if>
      <xsl:text>}</xsl:text>
      <xsl:if test="see|seealso">
         <xsl:text>{</xsl:text>
         <xsl:call-template name="normalize-escape">
            <xsl:with-param name="string" select="(see|seealso)[1]"/>
         </xsl:call-template>
         <xsl:text>}</xsl:text>
      </xsl:if>

      <xsl:if
         test="$isFromRange = 0 and not(parent::title or parent::subtitle or parent::bridgehead)">
         <xsl:text>}</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template match="indexterm[@class='startofrange']">
      <xsl:text>\startregister[</xsl:text>
      <xsl:call-template name="getRegisterName"/>
      <xsl:text>][</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>]</xsl:text>
      <xsl:call-template name="indexterm">
         <xsl:with-param name="isFromRange" select="1"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="indexterm[@class='endofrange']">
      <xsl:text>\stopregister[</xsl:text>
      <xsl:call-template name="getRegisterName"/>
      <xsl:text>][</xsl:text>
      <xsl:value-of select="@startref"/>
      <xsl:text>]</xsl:text>
   </xsl:template>

   <xsl:template match="primary|secondary|tertiary|see|seealso"/>
   <xsl:template match="indexentry"/>
   <xsl:template match="primaryie|secondaryie|tertiaryie|seeie|seealsoie"/>

   <!-- TBD: is this right? -->

   <xsl:template match="index|setindex"/>

   <xsl:template match="index/title"/>
   <xsl:template match="index/subtitle"/>
   <xsl:template match="index/titleabbrev"/>

   <xsl:template match="indexdiv">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="indexdiv/title"/>

   <xsl:template name="defineProcessors">
      <xsl:choose>
         <xsl:when test="$significanceValuesCount &gt; 0">
            <xsl:for-each
               select="//indexterm[not(@significance = 'normal')][generate-id() = generate-id(key('significanceValues', @significance))]">
               <xsl:variable name="significance" select="@significance"/>
               <xsl:text>\defineprocessor[</xsl:text>
               <xsl:call-template name="getProcessorName"/>
               <xsl:text>][style=bold]&#10;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="defineRegisters">
      <xsl:choose>
         <xsl:when test="$registersTypesCount &gt; 1">
            <xsl:for-each
               select="//indexterm[generate-id() = generate-id(key('registersTypes', @type))]">
               <xsl:variable name="registerName">
                  <xsl:call-template name="getRegisterName"/>
               </xsl:variable>
               <xsl:text>\defineregister[</xsl:text>
               <xsl:value-of select="$registerName"/>
               <xsl:text>][</xsl:text>
               <xsl:value-of select="$registerName"/>
               <xsl:text>s]&#10;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="setupRegistersHeadText">
      <xsl:for-each select="index">
         <xsl:text>\setupheadtext[</xsl:text>
         <xsl:call-template name="getRegisterName"/>
         <xsl:text>=</xsl:text>
         <xsl:choose>
            <xsl:when test="title">
               <xsl:value-of select="normalize-space(title)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:call-template name="gentext"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:text>]&#10;</xsl:text>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="placeRegisters">
      <xsl:for-each select="index">
         <xsl:text>\startbackmatter&#10;</xsl:text>
         <xsl:text>\complete</xsl:text>
         <xsl:call-template name="getRegisterName"/>
         <xsl:text>&#10;</xsl:text>
         <xsl:text>\stopbackmatter&#10;</xsl:text>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="getRegisterName">
      <xsl:text>index</xsl:text>
      <xsl:if test="$registersTypesCount &gt; 1">
         <xsl:value-of select="@type"/>
      </xsl:if>
   </xsl:template>

   <xsl:template name="significance">
      <xsl:call-template name="getProcessorName"/>
      <xsl:text>-></xsl:text>
   </xsl:template>

   <xsl:template name="getProcessorName">
      <xsl:param name="significance" select="@significance"/>
      <xsl:text>processor_</xsl:text>
      <xsl:value-of select="$significance"/>
   </xsl:template>

</xsl:stylesheet>
