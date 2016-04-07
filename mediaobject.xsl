<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:param name="imagedata.default.scale">pagebound</xsl:param>
   <xsl:param name="imagedata.boxed">0</xsl:param>

   <xsl:template match="mediaobject">
      <xsl:variable name="figcount"
         select="count((ancestor::figure|ancestor::informalfigure)/mediaobject[imageobject])"/>
      <xsl:variable name="figmedia" select="count(ancestor::figure|ancestor::informalfigure)"/>

      <!-- Put it into a block if not within a figure -->
      <xsl:if test="$figmedia=0">
         <xsl:text>\blank&#10;</xsl:text>
      </xsl:if>

      <!-- Put a legend if only one image having a caption -->
      <xsl:if test="caption and ($figmedia=0 or $figcount=1)">
         <xsl:text>\placelegend</xsl:text>
      </xsl:if>

      <!-- Display the media -->
      <xsl:if test="$figcount &gt; 1">
         <xsl:text>\startcontent&#10;</xsl:text>
         <xsl:text>\simplealignedbox{10cm}{middle}</xsl:text>
      </xsl:if>
      <xsl:call-template name="inlinemediaobject"/>
      <xsl:if test="$figcount &gt; 1">
         <xsl:text>\stopcontent&#10;</xsl:text>
      </xsl:if>

      <!-- The caption of the figure/subfigure -->

      <xsl:choose>
         <xsl:when test="$figcount &gt; 1">
            <xsl:text>\startcaption </xsl:text>
            <xsl:apply-templates select="caption"/>
            <xsl:text>\stopcaption&#10;</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="caption">
               <xsl:text>{</xsl:text>
               <xsl:apply-templates select="caption"/>
               <xsl:text>}&#10;</xsl:text>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="$figmedia=0">
         <xsl:text>\blank&#10;</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template match="inlinemediaobject" name="inlinemediaobject">
      <xsl:variable name="img"
         select="child::imageobject/imagedata[@format='PNG' or @format='PDF'][1]"/>
      <xsl:choose>
         <xsl:when test="$img">
            <xsl:apply-templates select="$img"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="child::imageobject[1]"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="imageobject">
      <xsl:apply-templates select="imagedata"/>
   </xsl:template>

   <xsl:template name="image.default.set">
      <xsl:choose>
         <xsl:when test="$imagedata.default.scale='pagebound'">
            <!-- use the natural size up to the page boundaries -->
            <xsl:text>maxwidth=\textwidth,maxheight=\textheight</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <!-- put the parameter value as is -->
            <xsl:value-of select="$imagedata.default.scale"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="@format" mode="opt.frame">
      <xsl:variable name="format" select="."/>
      <xsl:variable name="type">
         <xsl:choose>
            <xsl:when test="$format='EPS'">eps</xsl:when>
            <xsl:when test="$format='PDF'">pdf</xsl:when>
            <xsl:when test="$format='TIFF'">tif</xsl:when>
            <xsl:when test="$format='PNG'">png</xsl:when>
            <xsl:when test="$format='JPG'">jpg</xsl:when>
            <xsl:when test="$format='TEX'">tex</xsl:when>
         </xsl:choose>
      </xsl:variable>
      <!-- show this option only if the format is known -->
      <xsl:if test="$type!=''">
         <xsl:text>type=</xsl:text>
         <xsl:value-of select="$type"/>
      </xsl:if>
   </xsl:template>

   <!-- Alignment processing -->

   <xsl:template name="align.frame">
      <xsl:param name="pre"/>
      <xsl:param name="opts" select="@align"/>
      <xsl:if test="$opts">
         <!-- something to print before the option -->
         <xsl:value-of select="$pre"/>
         <xsl:text>align=</xsl:text>
         <xsl:if test="count($opts) &gt; 1">
            <!-- several alignment options? -->
            <xsl:text>{</xsl:text>
         </xsl:if>
         <xsl:for-each select="$opts">
            <xsl:apply-templates select="." mode="opt.frame"/>
            <xsl:if test="position()!=last()">
               <xsl:text>,</xsl:text>
            </xsl:if>
         </xsl:for-each>
         <xsl:if test="count($opts) &gt; 1">
            <xsl:text>}</xsl:text>
         </xsl:if>
      </xsl:if>
   </xsl:template>

   <xsl:template match="@align" mode="opt.frame">
      <xsl:param name="align" select="."/>
      <xsl:choose>
         <xsl:when test="$align='center'">
            <xsl:text>middle</xsl:text>
         </xsl:when>
         <xsl:when test="$align='left'">
            <xsl:text>right</xsl:text>
         </xsl:when>
         <xsl:when test="$align='right'">
            <xsl:text>left</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

   <!-- Lengths processing -->

   <xsl:template name="unit.eval">
      <xsl:param name="length"/>
      <xsl:param name="prop" select="''"/>
      <xsl:choose>
         <!-- percentage of something -->
         <xsl:when test="contains($length, '%') and substring-after($length, '%')=''">
            <xsl:value-of select="number(substring-before($length, '%')) div 100"/>
            <xsl:value-of select="$prop"/>
         </xsl:when>
         <!-- pixel unit is not handled -->
         <xsl:when test="contains($length, 'px') and substring-after($length, 'px')=''">
            <xsl:message>Pixel unit not handled (replaced by pt)</xsl:message>
            <xsl:value-of select="number(substring-before($length, 'px'))"/>
            <xsl:text>pt</xsl:text>
         </xsl:when>
         <!-- no unit provided means pixel -->
         <xsl:when test="$length and (number($length)=$length)">
            <xsl:message>Pixel unit not handled (replaced by pt)</xsl:message>
            <xsl:value-of select="$length"/>
            <xsl:text>pt</xsl:text>
         </xsl:when>
         <!-- hope the unit is handled -->
         <xsl:otherwise>
            <xsl:value-of select="$length"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="@depth" mode="opt.frame">
      <xsl:variable name="length" select="."/>
      <xsl:text>height=</xsl:text>
      <xsl:call-template name="unit.eval">
         <xsl:with-param name="length" select="$length"/>
         <xsl:with-param name="prop" select="'\textheight'"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="@width" mode="opt.frame">
      <xsl:variable name="length" select="."/>
      <xsl:text>width=</xsl:text>
      <xsl:call-template name="unit.eval">
         <xsl:with-param name="length" select="$length"/>
         <xsl:with-param name="prop" select="'\textwidth'"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="@contentdepth|@contentwidth" mode="opt.length">
      <xsl:param name="optdim"/>
      <xsl:param name="optscale"/>
      <xsl:variable name="length" select="."/>

      <!-- is it a percentage? -->
      <xsl:variable name="scale">
         <xsl:apply-templates select="." mode="permil"/>
      </xsl:variable>
      <!-- the option to use depends if it's a percentage or not -->
      <xsl:choose>
         <xsl:when test="$scale=0">
            <xsl:value-of select="$optdim"/>
            <xsl:call-template name="unit.eval">
               <xsl:with-param name="length" select="$length"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$optscale"/>
            <xsl:value-of select="$scale"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- Image filename to use -->
   <xsl:template match="imagedata|graphic|inlinegraphic" mode="filename.get">
      <xsl:choose>
         <xsl:when test="@entityref">
            <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
         </xsl:when>
         <xsl:when test="@fileref">
            <xsl:value-of select="@fileref"/>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

   <!-- Process a group of options -->
   <xsl:template name="opt.frame.group">
      <xsl:param name="pre"/>
      <xsl:param name="opts"/>
      <xsl:if test="$opts">
         <xsl:value-of select="$pre"/>
         <xsl:for-each select="$opts">
            <xsl:apply-templates select="." mode="opt.frame"/>
            <xsl:if test="position()!=last()">
               <xsl:text>,</xsl:text>
            </xsl:if>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>

   <xsl:template match="imagedata|graphic|inlinegraphic" mode="opt.content">
      <xsl:param name="widthperct"/>
      <xsl:param name="depthperct"/>

      <!-- TDG says that content, scale and scalefit are mutually exclusive -->
      <xsl:choose>
         <!-- content area spec -->
         <xsl:when test="@contentwidth or @contentdepth">
            <xsl:call-template name="opt.frame.group">
               <xsl:with-param name="opts" select="@contentwidth|@contentdepth"/>
            </xsl:call-template>
         </xsl:when>
         <!-- scaling -->
         <xsl:when test="@scale">
            <xsl:text>scale=</xsl:text>
            <xsl:value-of select="number(@scale) * 10"/>
         </xsl:when>
         <!-- only viewport area spec with scalefit -->
         <xsl:when test="(not(@scalefit) or @scalefit='1') and (@width or @depth)">
            <xsl:call-template name="opt.frame.group">
               <xsl:with-param name="opts" select="@width|@depth"/>
            </xsl:call-template>
            <!-- TDG says that scale to fit cannot be anamorphic -->
            <!-- it means that the factor size must reach the max of both sizes -->
            <xsl:text>,factor=max</xsl:text>
         </xsl:when>
         <!-- default scaling (if any) -->
         <xsl:otherwise>
            <xsl:call-template name="image.default.set"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="imagedata" name="imagedata">
      <!-- Figure out if there's some viewport -->
      <xsl:variable name="viewport">
         <xsl:choose>
            <xsl:when
               test="(@width or @depth) and
                    (@contentwidth or @contentdepth or @scale or
                    (@scalefit and @scalefit='0'))">
               <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="0"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:variable name="filename">
         <xsl:apply-templates select="." mode="filename.get"/>
      </xsl:variable>

      <xsl:text>{</xsl:text>
      <xsl:if test="$viewport=1">
         <xsl:text>\framed[</xsl:text>
         <!-- boxed imagedata? -->
         <xsl:if test="$imagedata.boxed='0'">
            <xsl:text>frame=off,</xsl:text>
         </xsl:if>
         <!-- viewport width/height -->
         <xsl:call-template name="opt.frame.group">
            <xsl:with-param name="opts" select="@width|@depth"/>
         </xsl:call-template>
         <!-- alignment of the image in the frame -->
         <xsl:call-template name="align.frame">
            <xsl:with-param name="pre" select="','"/>
            <xsl:with-param name="opts" select="@align"/>
         </xsl:call-template>
         <xsl:text>]{</xsl:text>
      </xsl:if>

      <xsl:text>\externalfigure[</xsl:text>
      <xsl:value-of select="$filename"/>
      <xsl:text>]</xsl:text>

      <!-- image options (scale, width, etc.) -->
      <xsl:variable name="optc">
         <xsl:apply-templates select="." mode="opt.content"/>
      </xsl:variable>
      <!-- add the frame if asked -->
      <xsl:variable name="opts">
         <xsl:if test="$viewport=0 and $imagedata.boxed='1'">
            <xsl:text>frame=on</xsl:text>
            <xsl:if test="$optc!=''">
               <xsl:text>,</xsl:text>
            </xsl:if>
         </xsl:if>
         <xsl:value-of select="$optc"/>
      </xsl:variable>
      <xsl:if test="$opts!=''">
         <xsl:text>[</xsl:text>
         <xsl:value-of select="$opts"/>
         <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text>}&#10;</xsl:text>
      <xsl:if test="$viewport=1">
         <xsl:text>}</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template match="caption">
      <xsl:apply-templates/>
   </xsl:template>

</xsl:stylesheet>
