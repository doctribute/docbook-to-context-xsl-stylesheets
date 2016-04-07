<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:exsl="http://exslt.org/common" xmlns:ng="http://docbook.org/docbook-ng"
   xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="db ng exsl" version="1.0">

   <xsl:output method="text"/>

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:include href="../VERSION.xsl"/>
   <xsl:include href="param.xsl"/>
   <xsl:include href="../lib/lib.xsl"/>
   <xsl:include href="../common/l10n.xsl"/>
   <xsl:include href="../common/common.xsl"/>
   <xsl:include href="../common/utility.xsl"/>
   <xsl:include href="../common/labels.xsl"/>
   <xsl:include href="../common/titles.xsl"/>
   <xsl:include href="../common/subtitles.xsl"/>
   <xsl:include href="../common/gentext.xsl"/>
   <xsl:include href="../common/olink.xsl"/>
   <xsl:include href="../common/targets.xsl"/>
   <xsl:include href="../common/pi.xsl"/>

   <xsl:include href="context.xsl"/>
   <xsl:include href="format.xsl"/>
   <xsl:include href="pagesetup.xsl"/>
   <xsl:include href="titlepage.xsl"/>
   <xsl:include href="division.xsl"/>
   <xsl:include href="component.xsl"/>
   <xsl:include href="section.xsl"/>
   <xsl:include href="title.xsl"/>
   <xsl:include href="block.xsl"/>
   <xsl:include href="inline.xsl"/>
   <xsl:include href="lists.xsl"/>
   <xsl:include href="graphics.xsl"/>
   <xsl:include href="figure.xsl"/>
   <xsl:include href="mediaobject.xsl"/>
   <xsl:include href="table.xsl"/>
   <xsl:include href="footnote.xsl"/>
   <xsl:include href="index.xsl"/>
   <xsl:include href="xref.xsl"/>
   <xsl:include href="pi.xsl"/>

   <xsl:include href="../common/stripns.xsl"/>

   <xsl:param name="stylesheet.result.type" select="'context'"/>

   <!-- ==================================================================== -->

   <xsl:key name="id" match="*" use="@id|@xml:id"/>

   <!-- ==================================================================== -->

   <xsl:template match="*">
      <xsl:message>
         <xsl:text>Element </xsl:text>
         <xsl:value-of select="local-name(.)"/>
         <xsl:text> in namespace '</xsl:text>
         <xsl:value-of select="namespace-uri(.)"/>
         <xsl:text>' encountered</xsl:text>
         <xsl:if test="parent::*">
            <xsl:text> in </xsl:text>
            <xsl:value-of select="name(parent::*)"/>
         </xsl:if>
         <xsl:text>, but no template matches.</xsl:text>
      </xsl:message>

      <xsl:text>\color[red]{&lt;</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:text>&gt;}</xsl:text>

   </xsl:template>

   <!-- Update this list if new root elements supported -->
   <xsl:variable name="root.elements" select="' article book '"/>

   <xsl:template match="/">
      <!-- * Get a title for current doc so that we let the user -->
      <!-- * know what document we are processing at this point. -->
      <xsl:variable name="doc.title">
         <xsl:call-template name="get.doc.title"/>
      </xsl:variable>
      <xsl:choose>
         <!-- fix namespace if necessary -->
         <xsl:when
            test="$exsl.node.set.available != 0 and 
                  namespace-uri(/*) = 'http://docbook.org/ns/docbook'">
            <xsl:variable name="no.namespace">
               <xsl:apply-templates select="/*" mode="stripNS"/>
            </xsl:variable>

            <xsl:call-template name="log.message">
               <xsl:with-param name="level">Note</xsl:with-param>
               <xsl:with-param name="source" select="$doc.title"/>
               <xsl:with-param name="context-desc">
                  <xsl:text>namesp. cut</xsl:text>
               </xsl:with-param>
               <xsl:with-param name="message">
                  <xsl:text>stripped namespace before processing</xsl:text>
               </xsl:with-param>
            </xsl:call-template>

            <xsl:apply-templates select="exsl:node-set($no.namespace)"/>

         </xsl:when>
         <!-- Can't process unless namespace fixed with exsl node-set()-->
         <xsl:when test="namespace-uri(/*) = 'http://docbook.org/ns/docbook'">
            <xsl:message terminate="yes">
               <xsl:text>Unable to strip the namespace from DB5 document,</xsl:text>
               <xsl:text> cannot proceed.</xsl:text>
            </xsl:message>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$rootid != ''">
                  <xsl:variable name="root.element" select="key('id', $rootid)"/>
                  <xsl:choose>
                     <xsl:when test="count($root.element) = 0">
                        <xsl:message terminate="yes">
                           <xsl:text>ID '</xsl:text>
                           <xsl:value-of select="$rootid"/>
                           <xsl:text>' not found in document.</xsl:text>
                        </xsl:message>
                     </xsl:when>
                     <xsl:when
                        test="not(contains($root.elements, concat(' ', local-name($root.element), ' ')))">
                        <xsl:message terminate="yes">
                           <xsl:text>ERROR: Document root element ($rootid=</xsl:text>
                           <xsl:value-of select="$rootid"/>
                           <xsl:text>) for ConTeXt output </xsl:text>
                           <xsl:text>must be one of the following elements:</xsl:text>
                           <xsl:value-of select="$root.elements"/>
                        </xsl:message>
                     </xsl:when>
                     <!-- Otherwise proceed -->
                     <xsl:otherwise>
                        <xsl:if
                           test="$collect.xref.targets = 'yes' or
                            $collect.xref.targets = 'only'">
                           <xsl:apply-templates select="$root.element" mode="collect.targets"/>
                        </xsl:if>
                        <xsl:if test="$collect.xref.targets != 'only'">
                           <xsl:apply-templates select="$root.element" mode="process.root"/>
                        </xsl:if>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <!-- Otherwise process the document root element -->
               <xsl:otherwise>
                  <xsl:variable name="document.element" select="*[1]"/>
                  <xsl:choose>
                     <xsl:when
                        test="not(contains($root.elements, concat(' ', local-name($document.element), ' ')))">
                        <xsl:message terminate="yes">
                           <xsl:text>ERROR: Document root element for ConTeXt output </xsl:text>
                           <xsl:text>must be one of the following elements:</xsl:text>
                           <xsl:value-of select="$root.elements"/>
                        </xsl:message>
                     </xsl:when>
                     <!-- Otherwise proceed -->
                     <xsl:otherwise>
                        <xsl:if
                           test="$collect.xref.targets = 'yes' or $collect.xref.targets = 'only'">
                           <xsl:apply-templates select="/" mode="collect.targets"/>
                        </xsl:if>
                        <xsl:if test="$collect.xref.targets != 'only'">
                           <xsl:apply-templates select="/" mode="process.root"/>
                        </xsl:if>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="*" mode="process.root">
      <xsl:variable name="document.element" select="self::*"/>
      <xsl:variable name="title">
         <xsl:choose>
            <xsl:when test="$document.element/title | $document.element/info/title">
               <xsl:value-of select="($document.element/title | $document.element/info/title)[1]"/>
            </xsl:when>
            <xsl:otherwise>[could not find document title]</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:call-template name="setup.document"/>

      <xsl:apply-templates select="$document.element"/>
   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template name="write.chunk"/>

</xsl:stylesheet>
