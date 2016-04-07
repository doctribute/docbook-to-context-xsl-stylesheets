<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template match="itemizedlist">
      <xsl:if test="title">
         <xsl:apply-templates select="title"/>
      </xsl:if>
      <xsl:text>\startitemize</xsl:text>
      <xsl:variable name="mark">
         <xsl:choose>
            <xsl:when test="@mark='bullet'">1</xsl:when>
            <xsl:when test="@mark='dash'">2</xsl:when>
            <xsl:when test="@mark='star'">3</xsl:when>
            <xsl:when test="@mark='triangle'">4</xsl:when>
            <xsl:when test="@mark='box'">8</xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="$mark!='' or @spacing='compact'">
         <xsl:text>[</xsl:text>
         <xsl:if test="@spacing='compact'">
            <xsl:text>packed</xsl:text>
            <xsl:if test="$mark!=''">
               <xsl:text>,</xsl:text>
            </xsl:if>
         </xsl:if>
         <xsl:if test="$mark!=''">
            <xsl:value-of select="$mark"/>
         </xsl:if>
         <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates select="listitem"/>
      <xsl:text>\stopitemize&#10;</xsl:text>
   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template match="orderedlist">
      <xsl:apply-templates select="title"/>
      <xsl:text>\startitemize[</xsl:text>
      <xsl:choose>
         <xsl:when test="@numeration">
            <xsl:choose>
               <xsl:when test="@numeration='arabic'">
                  <xsl:text>n</xsl:text>
               </xsl:when>
               <xsl:when test="@numeration='upperalpha'">
                  <xsl:text>A</xsl:text>
               </xsl:when>
               <xsl:when test="@numeration='loweralpha'">
                  <xsl:text>a</xsl:text>
               </xsl:when>
               <xsl:when test="@numeration='upperroman'">
                  <xsl:text>R</xsl:text>
               </xsl:when>
               <xsl:when test="@numeration='lowerroman'">
                  <xsl:text>r</xsl:text>
               </xsl:when>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <!-- by default, arabic -->
            <xsl:text>n</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@spacing='compact'">
         <xsl:text>,packed</xsl:text>
      </xsl:if>
      <xsl:if test="@continuation='continues'">
         <xsl:text>,continue</xsl:text>
      </xsl:if>
      <xsl:text>]&#10;</xsl:text>
      <xsl:apply-templates select="listitem"/>
      <xsl:text>\stopitemize&#10;</xsl:text>
   </xsl:template>

   <xsl:template name="orderedlist-starting-number">
      <xsl:param name="list" select="."/>
      <xsl:variable name="pi-start">
         <xsl:call-template name="pi.context_start">
            <xsl:with-param name="node" select="$list"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="output-orderedlist-starting-number">
         <xsl:with-param name="list" select="$list"/>
         <xsl:with-param name="pi-start" select="$pi-start"/>
      </xsl:call-template>
   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template match="variablelist">
      <xsl:apply-templates select="title"/>
      <xsl:apply-templates select="varlistentry"/>
   </xsl:template>

   <xsl:template match="varlistentry">
      <xsl:apply-templates select="." mode="termbuf"/>
      <xsl:text>\startdbvarentry</xsl:text>
      <xsl:if test="@id or term/@id">
         <xsl:text>[</xsl:text>
         <xsl:for-each select="@id|term/@id">
            <xsl:value-of select="."/>
            <xsl:if test="position()!=last()">
               <xsl:text>,</xsl:text>
            </xsl:if>
         </xsl:for-each>
         <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text>{</xsl:text>
      <xsl:apply-templates select="." mode="termout"/>
      <xsl:text>}&#10;</xsl:text>
      <xsl:apply-templates select="listitem"/>
      <xsl:text>\stopdbvarentry&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="varlistentry" mode="termbuf">
      <xsl:if test="term[descendant::footnote or descendant::literal]">
         <xsl:text>\startbuffer&#10;</xsl:text>
         <xsl:apply-templates select="term"/>
         <xsl:text>&#10;\stopbuffer&#10;</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template match="varlistentry" mode="termout">
      <xsl:choose>
         <xsl:when test="term[descendant::footnote or descendant::literal]">
            <xsl:text>\getbuffer</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="term"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="term">
      <xsl:apply-templates/>
      <xsl:if test="position()!=last()">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template match="varlistentry/listitem">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="variablelist[@role]">
      <xsl:text>&#10;\setupTABLE[frame=off]&#10;</xsl:text>
      <xsl:text>\setupTABLE[column][1][width=4cm, align={hz, hanging}]&#10;</xsl:text>
      <xsl:text>\setupTABLE[column][last][align={hz, hanging}]&#10;</xsl:text>
      <xsl:text>\bTABLE[columndistance=0.2cm]&#10;</xsl:text>
      <xsl:apply-templates mode="table"/>
      <xsl:text>\eTABLE&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="varlistentry" mode="table">
      <xsl:text>\bTR </xsl:text>
      <xsl:apply-templates mode="table"/>
      <xsl:text>\eTR&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="term" mode="table">
      <xsl:variable name="content">
         <xsl:apply-templates/>
      </xsl:variable>
      <xsl:text>\bTD </xsl:text>
      <xsl:text>\hangindent=1cm \hangafter=1 </xsl:text>
      <xsl:if test="normalize-space($content) != ''">
         <xsl:copy-of select="$content"/>
      </xsl:if>
      <xsl:text>\eTD </xsl:text>
   </xsl:template>

   <xsl:template match="listitem" mode="table">
      <xsl:text>\bTD </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\eTD </xsl:text>
   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template match="listitem">
      <xsl:choose>
         <xsl:when test="@title">
            <xsl:text>\head</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\item</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <!-- put the reference if any, or relax to be able to have brackets in text -->
      <xsl:choose>
         <xsl:when test="@id">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>]</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\relax</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <!-- put the title -->
      <xsl:if test="title">
         <xsl:text>{\sc </xsl:text>
         <xsl:apply-templates select="title"/>
         <xsl:text>}&#10;&#10;</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template match="variablelist/title|orderedlist/title|itemizedlist/title|simplelist/title">
      <xsl:text>&#10;{\sc </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}&#10;</xsl:text>
   </xsl:template>

   <!-- ==================================================================== -->

   <xsl:template match="simplelist|simplelist[@type='vert']">
      <xsl:variable name="cols">
         <xsl:choose>
            <xsl:when test="@columns">
               <xsl:value-of select="@columns"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:text>&#10;</xsl:text>
      <xsl:text>\starttabulate</xsl:text>
      <xsl:call-template name="tabular.string">
         <xsl:with-param name="i" select="1"/>
         <xsl:with-param name="cols" select="$cols"/>
      </xsl:call-template>
      <xsl:text>&#10;</xsl:text>
      <xsl:call-template name="simplelist.vert">
         <xsl:with-param name="cols" select="$cols"/>
      </xsl:call-template>
      <xsl:text>&#10;\stoptabulate&#10;</xsl:text>
   </xsl:template>

   <xsl:template name="simplelist.vert">
      <xsl:param name="cols">1</xsl:param>
      <xsl:param name="cell">1</xsl:param>
      <xsl:param name="members" select="./member"/>
      <xsl:param name="rows" select="floor((count($members)+$cols - 1) div $cols)"/>
      <xsl:if test="$cell &lt;= $rows">
         <xsl:text>&#10;\NC </xsl:text>
         <xsl:call-template name="simplelist.vert.row">
            <xsl:with-param name="cols" select="$cols"/>
            <xsl:with-param name="rows" select="$rows"/>
            <xsl:with-param name="cell" select="$cell"/>
            <xsl:with-param name="members" select="$members"/>
         </xsl:call-template>
         <xsl:text> \NR</xsl:text>
         <xsl:call-template name="simplelist.vert">
            <xsl:with-param name="cols" select="$cols"/>
            <xsl:with-param name="cell" select="$cell+1"/>
            <xsl:with-param name="members" select="$members"/>
            <xsl:with-param name="rows" select="$rows"/>
         </xsl:call-template>
      </xsl:if>
   </xsl:template>

   <xsl:template name="simplelist.vert.row">
      <xsl:param name="cols">1</xsl:param>
      <xsl:param name="rows">1</xsl:param>
      <xsl:param name="cell">1</xsl:param>
      <xsl:param name="members" select="./member"/>
      <xsl:param name="curcol">1</xsl:param>
      <xsl:if test="$curcol &lt;= $cols">
         <xsl:choose>
            <xsl:when test="$members[position()=$cell]">
               <xsl:apply-templates select="$members[position()=$cell]"/>
               <xsl:text>\NC </xsl:text>
            </xsl:when>
            <xsl:otherwise> </xsl:otherwise>
         </xsl:choose>
         <xsl:call-template name="simplelist.vert.row">
            <xsl:with-param name="cols" select="$cols"/>
            <xsl:with-param name="rows" select="$rows"/>
            <xsl:with-param name="cell" select="$cell+$rows"/>
            <xsl:with-param name="members" select="$members"/>
            <xsl:with-param name="curcol" select="$curcol+1"/>
         </xsl:call-template>
      </xsl:if>
   </xsl:template>

   <xsl:template match="member">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template name="tabular.string">
      <xsl:param name="cols" select="1"/>
      <xsl:param name="i" select="1"/>
      <xsl:if test="$i = 1">
         <xsl:text>[|</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$i > $cols">
            <xsl:text>]</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>l|</xsl:text>
            <xsl:call-template name="tabular.string">
               <xsl:with-param name="i" select="$i+1"/>
               <xsl:with-param name="cols" select="$cols"/>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- ==================================================================== -->

</xsl:stylesheet>
