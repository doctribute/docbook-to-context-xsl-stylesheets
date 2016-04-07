<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <xsl:import href="docbook.xsl"/>

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:template name="setup.document">
      <xsl:variable name="preamble" xml:space="preserve">
         
         \mainlanguage[[$LANGUAGE]]
         
         % layout
         \setuppapersize[B5]
         
         % orphan/widow settings (at least 2 lines together)
         \startsetups[grid][mypenalties]
           \setdefaultpenalties
           \setpenalties\widowpenalties{2}{10000}
           \setpenalties\clubpenalties {2}{10000}
         \stopsetups
         
         \setuplayout[header=0cm, footer=1cm, grid=yes, setups=mypenalties]
         \setuppagenumbering[alternative=doublesided, location={footer, right}, style=italic]
         
         % switching on debugging layers (grid, text area)
         \showgrid
         \showlayoutcomponents
         
         % page numbering styles
         \definestructureconversionset[frontpart:pagenumber][][romannumerals]
         \definestructureconversionset[bodypart:pagenumber] [][numbers]
         \definestructureconversionset[backpart:pagenumber] [][numbers]
         
         \startsectionblockenvironment[frontpart]
         \setupuserpagenumber[numberconversion=romannumerals]
         \stopsectionblockenvironment
         
         \startsectionblockenvironment[bodypart]
         \setupuserpagenumber[numberconversion=numbers]
         \stopsectionblockenvironment
         
         \startsectionblockenvironment[backpart]
         \setupuserpagenumber[numberconversion=numbers]
         \stopsectionblockenvironment
         
         % fonts
         \definefontfamily[palatino][rm][Palatino Linotype][features={default, quality}]
         \definefontfeature[f:superscript][sups=yes]
         \setupbodyfont[palatino, 10pt]
         
         % core styling
         \setupalign[hz, hanging]
         % to avoid overflowing lines (verystrict, strict, tolerant)
         \setuptolerance[verystrict]
         \setupindenting[yes, 2em]
         \setupnotation[footnote][way=bychapter, align={hz, hanging}]
         
         % headings
         \setuplabeltext[[$LANGUAGE]][chapter=[$CHAPTER]  ]
         
         \setuphead[chapter][
            alternative=middle,
            before={\blank[force,11.5mm]},
            after={\blank[1*line]},
            style=\bfc,
            numberstyle={\kerncharacters[0.125]\bfa},
            numbercommand=\groupedcommand{}{\blank[4mm]},
            sectionstopper={.},
            conversion=Romannumerals,
         ]
         
         \setuphead[section][
            align=middle,
            style=\bia,
            before={\testpage[7]\blank[1*line]},
            after={\blank[0mm]},   
            sectionsegments=section, % ignore component label
            sectionstopper={.},
         ]
         
         % TOC
         \define[1]\ChapterListNumbercommand{\offset[x=-2cm,width=0pt]{\simplealignedbox{1.5cm}{flushright}{#1}}}
         
         \setupcombinedlist[content][list=chapter, alternative=c]
         \setupcombinedlist[chapter][
            before=,
            distance=0cm,
            width=0cm,
            margin=2cm,
            numbercommand={\ChapterListNumbercommand},
            pageconversionset=pagenumber,
         ]
         
         % bookmarks, interactivity
         \setupinteraction[state=start, color=, contrastcolor=, focus=standard]
         \placebookmarks[chapter]
         \setupinteractionscreen[option=bookmark]
         
         % prefer superscript defined in the font 
         \define[1]\sup{\feature[+][f:superscript]#1}
         
         % last paragraph line ending
         
         \newdimen\lastlineminlength
         \newdimen\lastlinemingap
         
         \lastlineminlength=3em
         \lastlinemingap=1em
         
         \parfillskip \lastlinemingap plus \dimexpr\availablehsize-\lastlineminlength-\lastlinemingap\relax

      </xsl:variable>

      <xsl:variable name="replacementMap">
         <entry key="[$LANGUAGE]">
            <xsl:attribute name="value">
               <xsl:call-template name="l10n.language"/>
            </xsl:attribute>
         </entry>
         <entry key="[$CHAPTER]">
            <xsl:attribute name="value">
               <xsl:variable name="title">
                  <xsl:call-template name="gentext">
                     <xsl:with-param name="key">Chapter</xsl:with-param>
                  </xsl:call-template>
               </xsl:variable>
               <xsl:call-template name="string.upper">
                  <xsl:with-param name="string" select="$title"/>
               </xsl:call-template>
            </xsl:attribute>
         </entry>
      </xsl:variable>

      <xsl:call-template name="string.subst.map">
         <xsl:with-param name="string" select="$preamble"/>
         <xsl:with-param name="replacementMap" select="$replacementMap"/>
      </xsl:call-template>

   </xsl:template>

   <!-- ==================================================================== -->

   <!-- Prefer PDF version if exists -->

   <xsl:template match="imagedata|graphic|inlinegraphic" mode="filename.get"
      xmlns:file="java.io.File">
      <xsl:if test="@fileref">
         <xsl:variable name="pdfPath" select="concat(substring-before(@fileref, '.'), '.pdf')"/>
         <xsl:choose>
            <xsl:when test="file:exists(file:new($pdfPath))">
               <xsl:value-of select="$pdfPath"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="@fileref"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>

   <!-- ==================================================================== -->

   <!-- adding a divider to the end of the chapter -->

   <xsl:template match="chapter|preface">
      <xsl:apply-imports/>
      <!--  and not(child::*[last()][self::indexterm]) and not(section[last()]/child::*[last()][self::indexterm]) -->
      <xsl:if test="not(blockquote)">
         <xsl:call-template name="divider"/>
      </xsl:if>
   </xsl:template>

   <!-- ==================================================================== -->

   <!-- dedication in a narrow block -->

   <xsl:template match="para[@role='dedication']">
      <xsl:text>\startlinecorrection&#10;</xsl:text>
      <xsl:text>\setupinterlinespace[line=4.5ex]&#10;</xsl:text>
      <xsl:text>\setupnarrower[middle=3cm]&#10;</xsl:text>
      <xsl:text>\startnarrower&#10;</xsl:text>
      <xsl:text>\itb&#10;</xsl:text>
      <xsl:apply-imports/>
      <xsl:text>\stopnarrower&#10;</xsl:text>
      <xsl:text>\stoplinecorrection&#10;</xsl:text>
   </xsl:template>

   <!-- verse in a narrow block -->

   <xsl:template match="simplelist[@role='verse']">
      <xsl:text>{\noindenting&#10;</xsl:text>
      <xsl:text>\setupnarrower[left=2em]&#10;</xsl:text>
      <xsl:text>\startnarrower[left]&#10;</xsl:text>
      <xsl:text>\it&#10;</xsl:text>
      <xsl:apply-templates mode="verse"/>
      <xsl:text>\stopnarrower&#10;</xsl:text>
      <xsl:text>}&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="member" mode="verse">
      <xsl:apply-templates/>
      <xsl:text>\par&#10;</xsl:text>
   </xsl:template>

   <!-- ==================================================================== -->

   <!-- smaller font of index entries -->

   <xsl:template name="placeRegisters">
      <xsl:for-each select="index">
         <xsl:text>\startbackmatter&#10;</xsl:text>
         <xsl:text>\chapter{</xsl:text>
         <xsl:value-of select="title"/>
         <xsl:text>}&#10;</xsl:text>
         <xsl:text>\start&#10;</xsl:text>
         <xsl:text>\switchtobodyfont[8pt]&#10;</xsl:text>
         <xsl:text>\place</xsl:text>
         <xsl:call-template name="getRegisterName"/>
         <xsl:text>&#10;\stop&#10;</xsl:text>
         <xsl:text>\stopbackmatter&#10;</xsl:text>
      </xsl:for-each>
   </xsl:template>

   <!-- ==================================================================== -->

   <!-- linebreak -->

   <xsl:template match="processing-instruction('linebreak')">
      <xsl:text>\par&#10;</xsl:text>
   </xsl:template>

   <!-- divider -->

   <xsl:template match="processing-instruction('divider')">
      <xsl:call-template name="divider"/>
   </xsl:template>

   <xsl:template name="divider">
      <xsl:text>\page[no]\blank[4.1mm]\middlealigned{\color[darkgray]{\hl[4]}}\blank[6.05mm]&#10;</xsl:text>
   </xsl:template>

   <!-- vertical spacer -->

   <xsl:template match="processing-instruction('v-spacer')">

      <xsl:variable name="lines">
         <xsl:call-template name="pi-attribute">
            <xsl:with-param name="pis" select="."/>
            <xsl:with-param name="attribute">lines</xsl:with-param>
         </xsl:call-template>
      </xsl:variable>

      <xsl:text>\blank[</xsl:text>
      <xsl:choose>
         <xsl:when test="$lines != ''">
            <xsl:value-of select="$lines"/>
         </xsl:when>
         <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
      <xsl:text>*line]&#10;</xsl:text>

   </xsl:template>

   <!-- ==================================================================== -->

   <!-- local tweaking of alignment tolerance -->

   <xsl:template match="para[processing-instruction('alignment')]">

      <xsl:variable name="tolerance">
         <xsl:call-template name="pi-attribute">
            <xsl:with-param name="pis" select="processing-instruction('alignment')"/>
            <xsl:with-param name="attribute">tolerance</xsl:with-param>
         </xsl:call-template>
      </xsl:variable>

      <xsl:text>&#10;\start&#10;</xsl:text>
      <xsl:text>\setuptolerance[</xsl:text>
      <xsl:choose>
         <xsl:when test="$tolerance != ''">
            <xsl:value-of select="$tolerance"/>
         </xsl:when>
         <xsl:otherwise>verystrict</xsl:otherwise>
      </xsl:choose>
      <xsl:text>] </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\par\stop&#10;</xsl:text>

   </xsl:template>

   <!-- shift the first line a bit to achieve an optical edge (used mainly for » character) -->

   <xsl:template match="processing-instruction('hanging-indent')">

      <xsl:variable name="size">
         <xsl:call-template name="pi-attribute">
            <xsl:with-param name="pis" select="."/>
            <xsl:with-param name="attribute">size</xsl:with-param>
         </xsl:call-template>
      </xsl:variable>

      <xsl:text>{\hskip -</xsl:text>
      <xsl:choose>
         <xsl:when test="$size != ''">
            <xsl:value-of select="$size"/>
         </xsl:when>
         <xsl:otherwise>0.7mm</xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
   </xsl:template>

</xsl:stylesheet>
