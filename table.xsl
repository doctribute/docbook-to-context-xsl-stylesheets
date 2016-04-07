<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2006 Ben Guillon                                        -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <!-- 
      This stylesheet is derived from David Hedley's newtbl initially 
      done for translating DocBook tables to latex.

      The implementation for ConTeXt is far more easier than for latex 
      (so that there's no real merit for that port). It reuses most of
      initial methods, that is, creation of new complete and enriched  
      XML trees that make the final translation quite straight.
   -->

   <xsl:param name="table.default.rowsep" select="'1'"/>
   <xsl:param name="table.default.colsep" select="'1'"/>
   <xsl:param name="table.default.frame" select="'all'"/>

   <xsl:template match="informaltable[@condition='html']" priority="100"/>

   <!-- Step though each column, generating a colspec entry for it. If a  -->
   <!-- colspec was given in the xml, then use it, otherwise generate a -->
   <!-- default one -->
   <xsl:template name="tbl.defcolspec">
      <xsl:param name="colnum" select="1"/>
      <xsl:param name="colspec"/>
      <xsl:param name="align"/>
      <xsl:param name="rowsep"/>
      <xsl:param name="colsep"/>
      <xsl:param name="cols"/>

      <xsl:if test="$colnum &lt;= $cols">
         <xsl:choose>
            <xsl:when test="$colspec/colspec[@colnum = $colnum]">
               <xsl:copy-of select="$colspec/colspec[@colnum = $colnum]"/>
            </xsl:when>
            <xsl:otherwise>
               <colspec colnum="{$colnum}" star="1"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:call-template name="tbl.defcolspec">
            <xsl:with-param name="colnum" select="$colnum + 1"/>
            <xsl:with-param name="align" select="$align"/>
            <xsl:with-param name="rowsep" select="$rowsep"/>
            <xsl:with-param name="colsep" select="$colsep"/>
            <xsl:with-param name="cols" select="$cols"/>
            <xsl:with-param name="colspec" select="$colspec"/>
         </xsl:call-template>
      </xsl:if>
   </xsl:template>

   <!-- TODO: replace with built-in string.subst -->
   <xsl:template name="replace-string">
      <xsl:param name="text"/>
      <xsl:param name="replace"/>
      <xsl:param name="with"/>
      <xsl:choose>
         <xsl:when test="contains($text,$replace)">
            <xsl:value-of select="substring-before($text,$replace)"/>
            <xsl:value-of select="$with"/>
            <xsl:call-template name="replace-string">
               <xsl:with-param name="text" select="substring-after($text,$replace)"/>
               <xsl:with-param name="replace" select="$replace"/>
               <xsl:with-param name="with" select="$with"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$text"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- 
      This template extracts the fixed part of a colwidth specification.
      It should be able to do this:
         a+b+c+d*+e+f -> a+b+c+e+f
         a+b+c+d*     -> a+b+c
         d*+e+f       -> e+f      
   -->
   <xsl:template name="colfixed.get">
      <xsl:param name="width" select="@colwidth"/>
      <xsl:param name="stared" select="'0'"/>

      <xsl:choose>
         <xsl:when test="contains($width, '*')">
            <xsl:variable name="after" select="substring-after(substring-after($width, '*'), '+')"/>
            <xsl:if test="contains(substring-before($width, '*'), '+')">
               <xsl:call-template name="colfixed.get">
                  <xsl:with-param name="width" select="substring-before($width, '*')"/>
                  <xsl:with-param name="stared" select="'1'"/>
               </xsl:call-template>
               <xsl:if test="$after!=''">
                  <xsl:text>+</xsl:text>
               </xsl:if>
            </xsl:if>
            <xsl:value-of select="$after"/>
         </xsl:when>
         <xsl:when test="$stared='1'">
            <xsl:value-of select="substring-before($width, '+')"/>
            <xsl:if test="contains(substring-after($width, '+'), '+')">
               <xsl:text>+</xsl:text>
               <xsl:call-template name="colfixed.get">
                  <xsl:with-param name="width" select="substring-after($width, '+')"/>
                  <xsl:with-param name="stared" select="'1'"/>
               </xsl:call-template>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$width"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="colstar.get">
      <xsl:param name="width"/>
      <xsl:choose>
         <xsl:when test="contains($width, '+')">
            <xsl:call-template name="colstar.get">
               <xsl:with-param name="width" select="substring-after($width, '+')"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="string(number($width))='NaN'">1</xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="number($width)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- 
      Ensure each column has a colspec and each colspec has a valid column
      number, width, alignment, colsep, rowsep 
   -->
   <xsl:template match="colspec" mode="newtbl">
      <xsl:param name="colnum" select="1"/>
      <xsl:param name="cols"/>

      <xsl:copy>
         <xsl:for-each select="@*[local-name(.)!='colsep']">
            <xsl:copy/>
         </xsl:for-each>

         <!-- Ignore colsep for the last column (frame to apply instead) -->
         <xsl:if
            test="@colsep and
                 ((@colnum  and @colnum != $cols) or 
                  (not(@colnum) and $colnum != $cols))">
            <xsl:copy-of select="@colsep"/>
         </xsl:if>

         <xsl:if test="not(@colnum)">
            <xsl:attribute name="colnum">
               <xsl:value-of select="$colnum"/>
            </xsl:attribute>
         </xsl:if>

         <!-- Find out if the column width contains fixed width -->
         <xsl:variable name="fixed">
            <xsl:call-template name="colfixed.get"/>
         </xsl:variable>

         <xsl:if test="$fixed!=''">
            <xsl:attribute name="fixedwidth">
               <xsl:value-of select="$fixed"/>
            </xsl:attribute>
         </xsl:if>

         <!-- Replace '*' with our to-be-computed factor -->
         <xsl:if test="contains(@colwidth,'*')">
            <xsl:attribute name="colwidth">
               <xsl:call-template name="replace-string">
                  <xsl:with-param name="text" select="@colwidth"/>
                  <xsl:with-param name="replace">*</xsl:with-param>
                  <xsl:with-param name="with">\tblstarwd</xsl:with-param>
               </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="star">
               <xsl:call-template name="colstar.get">
                  <xsl:with-param name="width" select="substring-before(@colwidth, '*')"/>
               </xsl:call-template>
            </xsl:attribute>
         </xsl:if>
         <!-- No colwidth specified? Assume '*' -->
         <xsl:if test="not(string(@colwidth))">
            <xsl:attribute name="star">1</xsl:attribute>
         </xsl:if>
      </xsl:copy>

      <xsl:variable name="nextcolnum">
         <xsl:choose>
            <xsl:when test="@colnum">
               <xsl:value-of select="@colnum + 1"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$colnum + 1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:apply-templates mode="newtbl" select="following-sibling::colspec[1]">
         <xsl:with-param name="colnum" select="$nextcolnum"/>
         <xsl:with-param name="cols" select="$cols"/>
      </xsl:apply-templates>
   </xsl:template>

   <!-- Generate a complete set of colspecs for each column in the table -->
   <xsl:template name="tbl.colspec">
      <xsl:param name="align"/>
      <xsl:param name="rowsep"/>
      <xsl:param name="colsep"/>
      <xsl:param name="cols"/>

      <!-- First, get the colspecs that have been specified -->
      <xsl:variable name="givencolspec">
         <xsl:apply-templates mode="newtbl" select="colspec[1]">
            <xsl:with-param name="cols" select="$cols"/>
         </xsl:apply-templates>
      </xsl:variable>

      <!-- Now generate colspecs for each missing column -->
      <xsl:call-template name="tbl.defcolspec">
         <xsl:with-param name="colspec" select="exsl:node-set($givencolspec)"/>
         <xsl:with-param name="cols" select="$cols"/>
         <xsl:with-param name="align" select="$align"/>
         <xsl:with-param name="rowsep" select="$rowsep"/>
         <xsl:with-param name="colsep" select="$colsep"/>
      </xsl:call-template>
   </xsl:template>

   <!-- 
      Create a blank entry element. We check the 'entries' node-set
      to see if we should copy an entry from the row above instead 
   -->
   <xsl:template name="tbl.blankentry">
      <xsl:param name="colnum"/>
      <xsl:param name="colend"/>
      <xsl:param name="rownum"/>
      <xsl:param name="colspec"/>
      <xsl:param name="entries"/>

      <xsl:if test="$colnum &lt;= $colend">
         <xsl:choose>
            <xsl:when test="$entries/entry[@colstart=$colnum and @rowend &gt;= $rownum]">
               <!-- Just copy this entry then -->
               <xsl:copy-of select="$entries/entry[@colstart=$colnum]"/>
            </xsl:when>
            <xsl:otherwise>
               <!-- No rowspan entry found from the row above, so create a blank -->
               <entry colstart="{$colnum}" colend="{$colnum}" rowstart="{$rownum}"
                  rowend="{$rownum}"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:variable name="nextcol">
            <xsl:choose>
               <xsl:when test="$entries/entry[@colstart=$colnum and @rowend &gt;= $rownum]">
                  <xsl:value-of select="$entries/entry[@colstart=$colnum]/@colend"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$colnum"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:call-template name="tbl.blankentry">
            <xsl:with-param name="colnum" select="$nextcol + 1"/>
            <xsl:with-param name="colend" select="$colend"/>
            <xsl:with-param name="rownum" select="$rownum"/>
            <xsl:with-param name="colspec" select="$colspec"/>
            <xsl:with-param name="entries" select="$entries"/>
         </xsl:call-template>
      </xsl:if>
   </xsl:template>

   <!-- Returns a RTF of entry elements. rowsep, colsep and align are all -->
   <!-- extracted from spanspec/colspec as required -->
   <!-- Skipped columns have blank entry elements created -->
   <!-- Existing entry elements in the given entries node-set are checked to -->
   <!-- see if they should extend into this row and are copied if so -->
   <!-- Each element is given additional attributes: -->
   <!-- rowstart = The top row number of the table this entry -->
   <!-- rowend = The bottom row number of the table this entry -->
   <!-- colstart = The starting column number of this entry -->
   <!-- colend = The ending column number of this entry -->
   <!-- defrowsep = The default rowsep value inherited from the entry's span -->
   <!--     or colspec -->
   <xsl:template match="entry" mode="buildentries">
      <xsl:param name="colnum"/>
      <xsl:param name="rownum"/>
      <xsl:param name="colspec"/>
      <xsl:param name="spanspec"/>
      <xsl:param name="frame"/>
      <xsl:param name="rows"/>
      <xsl:param name="entries"/>

      <xsl:variable name="cols" select="count($colspec/*)"/>

      <xsl:if test="$colnum &lt;= $cols">

         <!-- Do we have an existing entry element from a previous row that -->
         <!-- should be copied into this row? -->
         <xsl:choose>
            <xsl:when
               test="exsl:node-set($entries)/entry[@colstart=$colnum and @rowend &gt;= $rownum]">
               <!-- Just copy this entry then -->
               <xsl:copy-of select="$entries/entry[@colstart=$colnum]"/>

               <!-- Process the next column using this current entry -->
               <xsl:apply-templates mode="buildentries" select=".">
                  <xsl:with-param name="colnum"
                     select="$entries/entry[@colstart=$colnum]/@colend + 1"/>
                  <xsl:with-param name="rownum" select="$rownum"/>
                  <xsl:with-param name="colspec" select="$colspec"/>
                  <xsl:with-param name="spanspec" select="$spanspec"/>
                  <xsl:with-param name="frame" select="$frame"/>
                  <xsl:with-param name="rows" select="$rows"/>
                  <xsl:with-param name="entries" select="$entries"/>
               </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
               <!-- Get any span for this entry -->
               <xsl:variable name="span">
                  <xsl:if test="@spanname and $spanspec[@spanname=current()/@spanname]">
                     <xsl:copy-of select="$spanspec[@spanname=current()/@spanname]"/>
                  </xsl:if>
               </xsl:variable>

               <!-- Get the starting column number for this cell -->
               <xsl:variable name="colstart">
                  <xsl:choose>
                     <!-- Check colname first -->
                     <xsl:when test="$colspec/colspec[@colname=current()/@colname]">
                        <xsl:value-of select="$colspec/colspec[@colname=current()/@colname]/@colnum"
                        />
                     </xsl:when>
                     <!-- Now check span -->
                     <xsl:when test="exsl:node-set($span)/spanspec/@namest">
                        <xsl:value-of
                           select="$colspec/colspec[@colname=exsl:node-set($span)/spanspec/@namest]/@colnum"
                        />
                     </xsl:when>
                     <!-- Now check namest attribute -->
                     <xsl:when test="@namest">
                        <xsl:value-of select="$colspec/colspec[@colname=current()/@namest]/@colnum"
                        />
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$colnum"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>

               <!-- Get the ending column number for this cell -->
               <xsl:variable name="colend">
                  <xsl:choose>
                     <!-- Check span -->
                     <xsl:when test="exsl:node-set($span)/spanspec/@nameend">
                        <xsl:value-of
                           select="$colspec/colspec[@colname=exsl:node-set($span)/spanspec/@nameend]/@colnum"
                        />
                     </xsl:when>
                     <!-- Check nameend attribute -->
                     <xsl:when test="@nameend">
                        <xsl:value-of select="$colspec/colspec[@colname=current()/@nameend]/@colnum"
                        />
                     </xsl:when>
                     <!-- Otherwise end == start -->
                     <xsl:otherwise>
                        <xsl:value-of select="$colstart"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>

               <!-- Does this entry want to start at a later column? -->
               <xsl:if test="$colnum &lt; $colstart">
                  <!-- If so, create some blank entries to fill in the gap -->
                  <xsl:call-template name="tbl.blankentry">
                     <xsl:with-param name="colnum" select="$colnum"/>
                     <xsl:with-param name="colend" select="$colstart - 1"/>
                     <xsl:with-param name="colspec" select="$colspec"/>
                     <xsl:with-param name="rownum" select="$rownum"/>
                     <xsl:with-param name="entries" select="$entries"/>
                  </xsl:call-template>
               </xsl:if>

               <!-- Get inherited cell alignment -->
               <xsl:variable name="inalign" select="(ancestor-or-self::*[@align])[last()]/@align"/>

               <xsl:variable name="valign">
                  <!-- Ancestor alignment -->
                  <xsl:value-of select="(ancestor-or-self::*[@valign])[last()]/@valign"/>
               </xsl:variable>

               <xsl:variable name="align">
                  <xsl:choose>
                     <!-- Entry element attribute first -->
                     <xsl:when test="string(@align)">
                        <xsl:value-of select="@align"/>
                     </xsl:when>
                     <!-- Then any span present -->
                     <xsl:when test="exsl:node-set($span)/spanspec/@align">
                        <xsl:value-of select="exsl:node-set($span)/spanspec/@align"/>
                     </xsl:when>
                     <!-- Ancestor or colspec alignment -->
                     <xsl:when test="$colspec[@colnum=$colstart]/@align">
                        <xsl:value-of select="$colspec[@colnum=$colstart]/@align"/>
                     </xsl:when>
                     <xsl:when test="$inalign">
                        <xsl:value-of select="$inalign"/>
                     </xsl:when>
                  </xsl:choose>
               </xsl:variable>

               <xsl:variable name="bgcolor">
                  <xsl:if test="processing-instruction('dblatex')">
                     <xsl:call-template name="pi-attribute">
                        <xsl:with-param name="pis" select="processing-instruction('dblatex')"/>
                        <xsl:with-param name="attribute" select="'bgcolor'"/>
                     </xsl:call-template>
                  </xsl:if>
               </xsl:variable>

               <xsl:copy>
                  <!-- First, copy attributes from the spanspec -->
                  <xsl:for-each select="exsl:node-set($span)/spanspec/@*">
                     <xsl:copy/>
                  </xsl:for-each>

                  <!-- Local attributes can override them -->
                  <xsl:for-each select="@*">
                     <xsl:copy/>
                  </xsl:for-each>

                  <!-- Original position in the row -->
                  <xsl:attribute name="pos">
                     <xsl:value-of select="count(preceding-sibling::entry)+1"/>
                  </xsl:attribute>

                  <!-- If somewhere horiz and vert align was given, must define both here -->
                  <xsl:if test="$align!='' and $valign!=''">
                     <xsl:attribute name="align">
                        <xsl:value-of select="$align"/>
                     </xsl:attribute>
                     <xsl:attribute name="valign">
                        <xsl:value-of select="$valign"/>
                     </xsl:attribute>
                  </xsl:if>

                  <xsl:variable name="nc" select="$colend - $colstart + 1"/>
                  <xsl:variable name="nr">
                     <xsl:choose>
                        <xsl:when test="@morerows and @morerows > 0">
                           <xsl:value-of select="@morerows + 1"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="1"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:variable>
                  <xsl:variable name="rowend" select="$rownum + $nr -1"/>

                  <!-- Beware with cell in last row and frame -->
                  <xsl:if test="$rows=$rowend">
                     <xsl:attribute name="rowsep">
                        <xsl:choose>
                           <xsl:when test="$nr > 1">
                              <!-- Force rowsep to match bottom frame -->
                              <xsl:call-template name="frame.is.bottom">
                                 <xsl:with-param name="frame" select="$frame"/>
                              </xsl:call-template>
                           </xsl:when>
                           <xsl:otherwise>
                              <!-- Force rowsep to be undefined for a last row cell (-1) -->
                              <xsl:value-of select="'-1'"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:attribute>
                  </xsl:if>

                  <xsl:if test="$cols=$colend">
                     <xsl:attribute name="colsep">
                        <xsl:choose>
                           <xsl:when test="$nc > 1">
                              <!-- Force colsep to match right side frame -->
                              <xsl:call-template name="frame.is.right">
                                 <xsl:with-param name="frame" select="$frame"/>
                              </xsl:call-template>
                           </xsl:when>
                           <xsl:otherwise>
                              <!-- Force colsep to be undefined for a last col cell (-1) -->
                              <xsl:value-of select="'-1'"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:attribute>
                  </xsl:if>

                  <xsl:if test="$bgcolor != ''">
                     <xsl:attribute name="bgcolor">
                        <xsl:value-of select="$bgcolor"/>
                     </xsl:attribute>
                  </xsl:if>

                  <!-- New attributes (provision) -->
                  <xsl:attribute name="colstart">
                     <xsl:value-of select="$colstart"/>
                  </xsl:attribute>
                  <xsl:attribute name="colend">
                     <xsl:value-of select="$colend"/>
                  </xsl:attribute>
                  <xsl:attribute name="rowstart">
                     <xsl:value-of select="$rownum"/>
                  </xsl:attribute>
                  <xsl:attribute name="rowend">
                     <xsl:value-of select="$rowend"/>
                  </xsl:attribute>

                  <!-- ConTeXt specific attributes -->
                  <xsl:if test="$nr > 1">
                     <xsl:attribute name="nr">
                        <xsl:value-of select="$nr"/>
                     </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$nc > 1">
                     <xsl:attribute name="nc">
                        <xsl:value-of select="$nc"/>
                     </xsl:attribute>
                  </xsl:if>

                  <!-- Copy all children -->
                  <xsl:copy-of select="child::node()"/>
               </xsl:copy>

               <!-- See if we've run out of entries for the current row -->
               <xsl:if test="$colend &lt; $cols and not(following-sibling::entry[1])">
                  <!-- Create more blank entries to pad the row -->
                  <xsl:call-template name="tbl.blankentry">
                     <xsl:with-param name="colnum" select="$colend + 1"/>
                     <xsl:with-param name="colend" select="$cols"/>
                     <xsl:with-param name="colspec" select="$colspec"/>
                     <xsl:with-param name="rownum" select="$rownum"/>
                     <xsl:with-param name="entries" select="$entries"/>
                  </xsl:call-template>
               </xsl:if>

               <xsl:apply-templates mode="buildentries" select="following-sibling::entry[1]">
                  <xsl:with-param name="colnum" select="$colend + 1"/>
                  <xsl:with-param name="rownum" select="$rownum"/>
                  <xsl:with-param name="rows" select="$rows"/>
                  <xsl:with-param name="colspec" select="$colspec"/>
                  <xsl:with-param name="spanspec" select="$spanspec"/>
                  <xsl:with-param name="frame" select="$frame"/>
                  <xsl:with-param name="entries" select="$entries"/>
               </xsl:apply-templates>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
      <!-- $colnum <= $cols -->
   </xsl:template>

   <!-- Output the current entry node -->
   <xsl:template match="entry" mode="newtbl">
      <xsl:param name="colspec"/>
      <xsl:param name="context"/>
      <xsl:param name="frame"/>
      <xsl:param name="rownum"/>

      <xsl:variable name="cols" select="count($colspec/*)"/>

      <xsl:if test="@colstart &lt;= $cols">

         <!-- Only output a cell not covered by another cell -->
         <xsl:if test="@rowstart=$rownum">

            <xsl:variable name="opts">
               <xsl:call-template name="opt.group">
                  <xsl:with-param name="opts" select="@rowsep|@colsep|@nr|@nc|@bgcolor"/>
               </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="optal" select="@align|@valign"/>

            <!-- Kind of cell -->
            <xsl:variable name="tx">
               <xsl:choose>
                  <xsl:when test="$context='thead'">
                     <xsl:value-of select="'TH'"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="'TD'"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>

            <xsl:text>\b</xsl:text>
            <xsl:value-of select="$tx"/>
            <xsl:if test="$opts!='' or $optal">
               <xsl:text>[</xsl:text>
               <xsl:value-of select="$opts"/>
               <xsl:if test="$optal">
                  <xsl:if test="$opts!=''">
                     <xsl:text>,</xsl:text>
                  </xsl:if>
                  <xsl:call-template name="opt.hvalign"/>
               </xsl:if>
               <xsl:text>]</xsl:text>
            </xsl:if>
            <xsl:text>{</xsl:text>

            <xsl:if test="@rotate and @rotate='1'">
               <xsl:text>\rotate[rotation=90]{</xsl:text>
            </xsl:if>

            <!-- Dump out the entry contents -->
            <xsl:apply-templates select="." mode="output"/>

            <xsl:if test="@rotate and @rotate='1'">
               <xsl:text>}</xsl:text>
            </xsl:if>

            <!-- End the cell -->
            <xsl:text>}\e</xsl:text>
            <xsl:value-of select="$tx"/>
            <xsl:text> </xsl:text>

         </xsl:if>
         <!-- rowstart = numrow -->
      </xsl:if>
      <!-- colstart > cols -->
   </xsl:template>


   <!-- Process each row in turn -->
   <xsl:template match="row" mode="newtbl">
      <xsl:param name="rownum"/>
      <xsl:param name="rows"/>
      <xsl:param name="colspec"/>
      <xsl:param name="spanspec"/>
      <xsl:param name="frame"/>
      <xsl:param name="oldentries"/>

      <!-- Build the entry node-set -->
      <xsl:variable name="entries">
         <xsl:apply-templates mode="buildentries" select="entry[1]">
            <xsl:with-param name="colnum" select="1"/>
            <xsl:with-param name="rownum" select="$rownum"/>
            <xsl:with-param name="rows" select="$rows"/>
            <xsl:with-param name="colspec" select="$colspec"/>
            <xsl:with-param name="spanspec" select="$spanspec"/>
            <xsl:with-param name="frame" select="$frame"/>
            <xsl:with-param name="entries">
               <xsl:if test="$oldentries">
                  <xsl:copy-of select="exsl:node-set($oldentries)"/>
               </xsl:if>
            </xsl:with-param>
         </xsl:apply-templates>
      </xsl:variable>

      <xsl:variable name="bgopt">
         <xsl:variable name="bgcolor">
            <xsl:if test="processing-instruction('dblatex')">
               <xsl:call-template name="pi-attribute">
                  <xsl:with-param name="pis" select="processing-instruction('dblatex')"/>
                  <xsl:with-param name="attribute" select="'bgcolor'"/>
               </xsl:call-template>
            </xsl:if>
         </xsl:variable>

         <xsl:element name="o">
            <xsl:if test="$bgcolor != ''">
               <xsl:message>color is <xsl:value-of select="$bgcolor"/></xsl:message>
               <xsl:attribute name="bgcolor">
                  <xsl:value-of select="$bgcolor"/>
               </xsl:attribute>
            </xsl:if>
         </xsl:element>
      </xsl:variable>

      <!-- Now output each entry -->
      <xsl:text>\bTR</xsl:text>
      <xsl:if test="@rowsep or @valign or exsl:node-set($bgopt)//@bgcolor">
         <xsl:text>[</xsl:text>
         <xsl:call-template name="opt.group">
            <xsl:with-param name="opts" select="@rowsep|@valign|exsl:node-set($bgopt)//@bgcolor"/>
         </xsl:call-template>
         <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text> </xsl:text>

      <xsl:variable name="context" select="local-name(..)"/>
      <xsl:apply-templates select="exsl:node-set($entries)/*" mode="newtbl">
         <xsl:with-param name="colspec" select="$colspec"/>
         <xsl:with-param name="frame" select="$frame"/>
         <xsl:with-param name="context" select="$context"/>
         <xsl:with-param name="rownum" select="$rownum"/>
         <xsl:with-param name="valign" select="@valign"/>
      </xsl:apply-templates>

      <!-- End this row -->
      <xsl:text>\eTR&#10;</xsl:text>

      <xsl:apply-templates mode="newtbl" select="following-sibling::row[1]">
         <xsl:with-param name="rownum" select="$rownum + 1"/>
         <xsl:with-param name="rows" select="$rows"/>
         <xsl:with-param name="colspec" select="$colspec"/>
         <xsl:with-param name="spanspec" select="$spanspec"/>
         <xsl:with-param name="frame" select="$frame"/>
         <xsl:with-param name="oldentries" select="$entries"/>
      </xsl:apply-templates>
   </xsl:template>


   <xsl:template match="table">
      <xsl:text>\placetable[here</xsl:text>
      <xsl:if test="@orient and @orient='land'">
         <xsl:text>,90</xsl:text>
      </xsl:if>
      <xsl:text>]</xsl:text>
      <xsl:if test="@id">
         <xsl:text>[</xsl:text>
         <xsl:value-of select="@id"/>
         <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text>&#10;{</xsl:text>
      <xsl:apply-templates select="title"/>
      <xsl:text>}&#10;{</xsl:text>
      <xsl:apply-templates select="*[not(self::title)]" mode="newtbl"/>
      <xsl:text>}&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="informaltable">
      <xsl:text>\blank&#10;</xsl:text>
      <xsl:text>{\tfx </xsl:text>
      <xsl:if test="@orient and @orient='land'">
         <xsl:text>\rotate[rotation=90]{%&#10;</xsl:text>
      </xsl:if>
      <xsl:apply-templates mode="newtbl"/>
      <xsl:if test="@orient and @orient='land'">
         <xsl:text>}&#10;</xsl:text>
      </xsl:if>
      <xsl:text>}&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="thead|tbody|tfoot" mode="newtbl">
      <xsl:param name="rownum"/>
      <xsl:param name="rows"/>
      <xsl:param name="frame"/>
      <xsl:param name="colspec"/>
      <xsl:param name="spanspec"/>

      <xsl:variable name="type">
         <xsl:choose>
            <xsl:when test="local-name(.)='thead'">head</xsl:when>
            <xsl:when test="local-name(.)='tbody'">body</xsl:when>
            <xsl:when test="local-name(.)='tfoot'">foot</xsl:when>
         </xsl:choose>
      </xsl:variable>

      <xsl:text>\bTABLE</xsl:text>
      <xsl:value-of select="$type"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates mode="newtbl" select="row[1]">
         <xsl:with-param name="rownum" select="$rownum"/>
         <xsl:with-param name="rows" select="$rows"/>
         <xsl:with-param name="frame" select="$frame"/>
         <xsl:with-param name="colspec" select="$colspec"/>
         <xsl:with-param name="spanspec" select="$spanspec"/>
      </xsl:apply-templates>
      <xsl:text>\eTABLE</xsl:text>
      <xsl:value-of select="$type"/>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <!-- The main starting point of the table handling -->
   <xsl:template match="tgroup" mode="newtbl">

      <!-- Get the number of columns -->
      <xsl:variable name="cols">
         <xsl:choose>
            <xsl:when test="@cols">
               <xsl:value-of select="@cols"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="count(tbody/row[1]/entry)"/>
               <xsl:message>Warning: table's tgroup lacks cols attribute. Assuming <xsl:value-of
                     select="count(tbody/row[1]/entry)"/>. </xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Get the number of rows -->
      <xsl:variable name="rows" select="count(thead/row|tbody/row|tfoot/row)"/>

      <!-- Find the table width -->
      <xsl:variable name="width">
         <xsl:choose>
            <xsl:when test="../@width">
               <xsl:value-of select="../@width"/>
            </xsl:when>
            <xsl:when test="../@pgwide and ../@pgwide='1'">
               <xsl:text>\textwidth</xsl:text>
            </xsl:when>
            <xsl:otherwise>\hsize</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Get default align -->
      <xsl:variable name="align" select="@align|parent::node()[not(*/@align)]/@align"/>

      <!-- Get default colsep -->
      <xsl:variable name="colsep" select="@colsep|parent::node()[not(*/@colsep)]/@colsep"/>

      <xsl:variable name="defcolsep">
         <xsl:choose>
            <xsl:when test="$colsep">
               <xsl:value-of select="$colsep"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$table.default.colsep"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Get default rowsep -->
      <xsl:variable name="rowsep" select="@rowsep|parent::node()[not(*/@rowsep)]/@rowsep"/>

      <xsl:variable name="defrowsep">
         <xsl:choose>
            <xsl:when test="$rowsep">
               <xsl:value-of select="$rowsep"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$table.default.rowsep"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Now the frame style -->
      <xsl:variable name="frame">
         <xsl:choose>
            <xsl:when test="../@frame">
               <xsl:value-of select="../@frame"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$table.default.frame"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Global frame setup? -->
      <xsl:variable name="frameon">
         <xsl:choose>
            <xsl:when test="$frame='all' and $defrowsep='1' and $defcolsep='1'">
               <xsl:value-of select="'on'"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="'off'"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Build up a complete colspec for each column -->
      <xsl:variable name="colspec">
         <xsl:call-template name="tbl.colspec">
            <xsl:with-param name="cols" select="$cols"/>
         </xsl:call-template>
      </xsl:variable>

      <!-- Get all the spanspecs as an RTF -->
      <xsl:variable name="spanspec" select="spanspec"/>

      <!-- Flexible '*' width setup -->
      <xsl:variable name="numstar" select="sum(exsl:node-set($colspec)/colspec/@star)"/>

      <xsl:variable name="fixedwd">
         <xsl:for-each select="exsl:node-set($colspec)/*">
            <xsl:if test="@fixedwidth">
               <xsl:text>-</xsl:text>
               <xsl:value-of select="translate(@fixedwidth,'+','-')"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>

      <!-- Fill the cell buffers if needed -->
      <xsl:apply-templates select="." mode="setbuffer"/>

      <!-- Start the table declaration -->
      <xsl:text>&#10;\bTABLE[frame=</xsl:text>
      <xsl:value-of select="$frameon"/>
      <xsl:if test="not(../@orient) or ../@orient!='land'">
         <xsl:text>,split=repeat</xsl:text>
      </xsl:if>

      <!-- Table background color -->
      <xsl:if test="../@bgcolor">
         <xsl:text>,</xsl:text>
         <xsl:apply-templates select="../@bgcolor" mode="opt"/>
      </xsl:if>

      <!-- Workaround (pb shown with informaltable.008) -->
      <xsl:text>,width=0.1pt</xsl:text>
      <xsl:text>]&#10;</xsl:text>

      <!-- Default '*' column width setup -->
      <xsl:if test="$numstar > 0">
         <!-- Define the '*' dimen and compute its width -->
         <xsl:text>\newdimen\tblstarwd&#10;</xsl:text>
         <xsl:text>\tblstarwd=\dimexpr((</xsl:text>
         <xsl:value-of select="$width"/>
         <xsl:value-of select="$fixedwd"/>
         <xsl:text>)/</xsl:text>
         <xsl:value-of select="$numstar"/>
         <xsl:text>)\relax&#10;</xsl:text>
         <!-- Apply the width to each column by default -->
         <xsl:text>\setupTABLE[column][each][</xsl:text>
         <xsl:text>width=\tblstarwd</xsl:text>
         <xsl:text>]&#10;</xsl:text>
      </xsl:if>

      <!-- Default row alignment -->
      <xsl:if test="$align!=''">
         <xsl:text>\setupTABLE[row][each][</xsl:text>
         <xsl:call-template name="opt.hvalign">
            <xsl:with-param name="align" select="$align"/>
         </xsl:call-template>
         <xsl:text>]&#10;</xsl:text>
      </xsl:if>

      <xsl:if test="$frameon='off'">
         <!-- Default cell border rules -->
         <xsl:if test="$defcolsep='1'">
            <xsl:text>\setupTABLE[column][each][rightframe=on]&#10;</xsl:text>
            <xsl:text>\setupTABLE[column][last][rightframe=off]&#10;</xsl:text>
         </xsl:if>
         <xsl:if test="$defrowsep='1'">
            <xsl:text>\setupTABLE[row][each][bottomframe=on]&#10;</xsl:text>
            <xsl:text>\setupTABLE[row][last][bottomframe=off]&#10;</xsl:text>
         </xsl:if>

         <!-- Frame rules -->
         <xsl:choose>
            <xsl:when test="$frame='' or $frame='all'">
               <xsl:text>\setupTABLE[row][first][topframe=on]&#10;</xsl:text>
               <xsl:text>\setupTABLE[row][last][bottomframe=on]&#10;</xsl:text>
               <xsl:text>\setupTABLE[column][first][leftframe=on]&#10;</xsl:text>
               <xsl:text>\setupTABLE[column][last][rightframe=on]&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="$frame='sides'">
               <xsl:text>\setupTABLE[column][first][leftframe=on]&#10;</xsl:text>
               <xsl:text>\setupTABLE[column][last][rightframe=on]&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="$frame='topbot'">
               <xsl:text>\setupTABLE[row][first][topframe=on]&#10;</xsl:text>
               <xsl:text>\setupTABLE[row][last][bottomframe=on]&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="$frame='top'">
               <xsl:text>\setupTABLE[row][first][topframe=on]&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="$frame='bottom'">
               <xsl:text>\setupTABLE[row][last][bottomframe=on]&#10;</xsl:text>
            </xsl:when>
         </xsl:choose>
      </xsl:if>

      <!-- Specific Columns setup -->
      <xsl:apply-templates select="exsl:node-set($colspec)" mode="setup">
         <xsl:with-param name="rows" select="$rows"/>
         <xsl:with-param name="framebot">
            <xsl:call-template name="frame.is.bottom">
               <xsl:with-param name="frame" select="$frame"/>
            </xsl:call-template>
         </xsl:with-param>
      </xsl:apply-templates>

      <!-- Go through each header row -->
      <xsl:apply-templates mode="newtbl" select="thead">
         <xsl:with-param name="rownum" select="1"/>
         <xsl:with-param name="rows" select="$rows"/>
         <xsl:with-param name="frame" select="$frame"/>
         <xsl:with-param name="colspec" select="exsl:node-set($colspec)"/>
         <xsl:with-param name="spanspec" select="exsl:node-set($spanspec)"/>
      </xsl:apply-templates>

      <!-- Go through each body row -->
      <xsl:apply-templates mode="newtbl" select="tbody">
         <xsl:with-param name="rownum" select="count(thead/row)+1"/>
         <xsl:with-param name="rows" select="$rows"/>
         <xsl:with-param name="frame" select="$frame"/>
         <xsl:with-param name="colspec" select="exsl:node-set($colspec)"/>
         <xsl:with-param name="spanspec" select="exsl:node-set($spanspec)"/>
      </xsl:apply-templates>

      <!-- Go through each footer row -->
      <xsl:apply-templates mode="newtbl" select="tfoot">
         <xsl:with-param name="rownum" select="count(thead/row|tbody/row)+1"/>
         <xsl:with-param name="rows" select="$rows"/>
         <xsl:with-param name="frame" select="$frame"/>
         <xsl:with-param name="colspec" select="exsl:node-set($colspec)"/>
         <xsl:with-param name="spanspec" select="exsl:node-set($spanspec)"/>
      </xsl:apply-templates>

      <xsl:text>\eTABLE&#10;</xsl:text>
   </xsl:template>

   <!-- Cell Buffering -->
   <xsl:template name="need.buffer">
      <xsl:choose>
         <xsl:when
            test="descendant::programlisting or
                  descendant::screen or
                  descendant::address or
                  descendant::literal or
                  descendant::literallayout">
            <xsl:value-of select="1"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="0"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="entry" mode="setbuffer">
      <xsl:param name="rownum" select="1"/>
      <xsl:variable name="needbuf">
         <xsl:call-template name="need.buffer"/>
      </xsl:variable>
      <xsl:if test="$needbuf=1">
         <xsl:text>\startbuffer[tbl:</xsl:text>
         <xsl:value-of select="$rownum"/>
         <xsl:text>.</xsl:text>
         <xsl:value-of select="position()"/>
         <xsl:text>]&#10;</xsl:text>
         <xsl:apply-templates/>
         <xsl:text>&#10;\stopbuffer&#10;</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template match="entry" mode="output">
      <xsl:choose>
         <xsl:when test="@pos">
            <xsl:variable name="needbuf">
               <xsl:call-template name="need.buffer"/>
            </xsl:variable>
            <xsl:choose>
               <xsl:when test="$needbuf=1">
                  <!-- Use the buffer for this cell -->
                  <xsl:text>\getbuffer[tbl:</xsl:text>
                  <xsl:value-of select="@rowstart"/>
                  <xsl:text>.</xsl:text>
                  <xsl:value-of select="@pos"/>
                  <xsl:text>]</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <!-- Nothing special, just process the content -->
                  <xsl:apply-templates/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="row" mode="setbuffer">
      <xsl:param name="rownum" select="1"/>
      <xsl:apply-templates mode="setbuffer" select="entry">
         <xsl:with-param name="rownum" select="$rownum+position()-1"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="thead|tbody|tfoot" mode="setbuffer">
      <xsl:param name="rownum" select="1"/>
      <xsl:apply-templates mode="setbuffer" select="row">
         <xsl:with-param name="rownum" select="$rownum"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="tgroup" mode="setbuffer">
      <xsl:apply-templates mode="setbuffer" select="thead"/>
      <xsl:apply-templates mode="setbuffer" select="tbody">
         <xsl:with-param name="rownum" select="count(thead/row)+1"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="setbuffer" select="tfoot">
         <xsl:with-param name="rownum" select="count(thead/row|tbody/row)+1"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template name="frame.is.bottom">
      <xsl:param name="frame"/>
      <xsl:choose>
         <xsl:when
            test="$frame='' or $frame='all' or
                  $frame='topbot' or
                  $frame='bottom'">
            <xsl:value-of select="'1'"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="'0'"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="frame.is.right">
      <xsl:param name="frame"/>
      <xsl:choose>
         <xsl:when test="$frame='' or $frame='all' or
                  $frame='sides'">
            <xsl:value-of select="'1'"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="'0'"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="@colwidth" mode="opt"/>

   <xsl:template match="@nr|@nc" mode="opt">
      <xsl:value-of select="local-name(.)"/>
      <xsl:text>=</xsl:text>
      <xsl:value-of select="."/>
   </xsl:template>

   <xsl:template match="@bgcolor" mode="opt">
      <xsl:text>background=color,backgroundcolor=</xsl:text>
      <xsl:value-of select="."/>
   </xsl:template>

   <xsl:template match="@rowsep" mode="opt">
      <xsl:variable name="value" select="."/>
      <xsl:if test="$value='0' or $value='1'">
         <xsl:text>bottomframe=</xsl:text>
         <xsl:choose>
            <xsl:when test="$value != '0'">
               <xsl:text>on</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>off</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>

   <xsl:template match="@colsep" mode="opt">
      <xsl:variable name="value" select="."/>
      <xsl:if test="$value='0' or $value='1'">
         <xsl:text>rightframe=</xsl:text>
         <xsl:choose>
            <xsl:when test="$value != '0'">
               <xsl:text>on</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>off</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>

   <xsl:template match="colspec" mode="setup">
      <xsl:param name="num" select="position()"/>
      <xsl:param name="framebot"/>
      <xsl:param name="rows"/>

      <!-- Actually setup something if some attributes are defined -->
      <xsl:if test="@align or @colwidth or @colsep or @rowsep">
         <xsl:text>\setupTABLE[c][</xsl:text>
         <xsl:value-of select="$num"/>
         <xsl:text>][</xsl:text>
         <xsl:call-template name="opt.group">
            <xsl:with-param name="opts" select="@align|@colsep|@rowsep"/>
         </xsl:call-template>

         <xsl:if test="@colwidth">
            <xsl:if test="@align or @colsep or @rowsep">,</xsl:if>
            <xsl:text>width={\dimexpr(</xsl:text>
            <xsl:value-of select="@colwidth"/>
            <xsl:text>)\relax}</xsl:text>
         </xsl:if>
         <xsl:text>]&#10;</xsl:text>

         <!-- Avoid frame bottom side effect -->
         <xsl:if test="@rowsep">
            <xsl:if test="@rowsep='1' and $framebot='0'">
               <xsl:text>\setupTABLE[</xsl:text>
               <xsl:value-of select="$num"/>
               <xsl:text>][</xsl:text>
               <xsl:value-of select="$rows"/>
               <xsl:text>][</xsl:text>
               <xsl:text>bottomframe=off</xsl:text>
               <xsl:text>]&#10;</xsl:text>
            </xsl:if>
            <xsl:if test="@rowsep='0' and $framebot='1'">
               <xsl:text>\setupTABLE[</xsl:text>
               <xsl:value-of select="$num"/>
               <xsl:text>][</xsl:text>
               <xsl:value-of select="$rows"/>
               <xsl:text>][</xsl:text>
               <xsl:text>bottomframe=on</xsl:text>
               <xsl:text>]&#10;</xsl:text>
            </xsl:if>
         </xsl:if>
      </xsl:if>
   </xsl:template>

   <!-- Things that can appear in a table -->
   <xsl:template match="indexterm" mode="newtbl">
      <xsl:apply-templates select="."/>
   </xsl:template>

</xsl:stylesheet>
