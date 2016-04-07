<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

   <!-- ===================================================================== -->
   <!-- http://docbook.sourceforge.net/release/xsl/current/doc/copyright.html -->
   <!-- Copyright (c) 2016 Jan Tosovsky                                       -->
   <!-- ===================================================================== -->

   <xsl:param name="exsl.node.set.available">
      <xsl:choose>
         <xsl:when xmlns:exsl="http://exslt.org/common" exsl:foo=""
            test="function-available('exsl:node-set') or contains(system-property('xsl:vendor'), 'Apache Software Foundation')"
            >1</xsl:when>
         <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
   </xsl:param>
   <xsl:param name="rootid"/>

   <!-- dependencies for l10n.xsl -->
   <xsl:param name="l10n.gentext.default.language">en</xsl:param>
   <xsl:param name="l10n.gentext.language"/>
   <xsl:param name="l10n.gentext.use.xref.language" select="0"/>
   <xsl:param name="l10n.lang.value.rfc.compliant" select="1"/>

   <!-- dependencies for common.xsl -->
   <xsl:param name="author.othername.in.middle" select="1"/>
   <xsl:param name="generate.consistent.ids" select="0"/>
   <xsl:param name="graphic.default.extension"/>
   <xsl:param name="preferred.mediaobject.role"/>
   <xsl:param name="punct.honorific">.</xsl:param>
   <xsl:param name="qanda.defaultlabel">number</xsl:param>
   <xsl:param name="use.role.for.mediaobject" select="1"/>
   <xsl:param name="tex.math.in.alt"/>
   <xsl:param name="use.role.as.xrefstyle" select="1"/>
   <xsl:param name="use.svg" select="1"/>

   <!-- dependencies for labels.xsl -->
   <xsl:param name="appendix.autolabel">A</xsl:param>
   <xsl:param name="chapter.autolabel" select="1"/>
   <xsl:param name="component.label.includes.part.label" select="0"/>
   <xsl:param name="formal.procedures" select="1"/>
   <xsl:param name="label.from.part" select="0"/>
   <xsl:param name="part.autolabel">I</xsl:param>
   <xsl:param name="preface.autolabel" select="0"/>
   <xsl:param name="qanda.inherit.numeration" select="1"/>
   <xsl:param name="qandadiv.autolabel" select="1"/>
   <xsl:param name="reference.autolabel">I</xsl:param>
   <xsl:param name="section.autolabel" select="0"/>
   <xsl:param name="section.autolabel.max.depth">8</xsl:param>
   <xsl:param name="section.label.includes.component.label" select="0"/>

   <!-- dependencies for gentext.xsl -->
   <xsl:param name="insert.olink.page.number">no</xsl:param>
   <xsl:param name="insert.xref.page.number">no</xsl:param>
   <xsl:param name="olink.doctitle">no</xsl:param>
   <xsl:param name="xref.label-page.separator">
      <xsl:text> </xsl:text>
   </xsl:param>
   <xsl:param name="xref.label-title.separator">: </xsl:param>
   <xsl:param name="xref.title-page.separator">
      <xsl:text> </xsl:text>
   </xsl:param>
   <xsl:param name="xref.with.number.and.title" select="1"/>

   <!-- dependencies for olink.xsl -->
   <xsl:param name="activate.external.olinks" select="1"/>
   <xsl:param name="current.docid"/>
   <xsl:param name="insert.olink.pdf.frag" select="0"/>
   <xsl:param name="insert.xref.page.number.para">yes</xsl:param>
   <xsl:param name="olink.debug" select="0"/>
   <xsl:param name="olink.lang.fallback.sequence"/>
   <xsl:param name="prefer.internal.olink" select="0"/>
   <xsl:param name="target.database.document">olinkdb.xml</xsl:param>
   <xsl:param name="use.local.olink.style" select="0"/>

   <!-- dependencies for targets.xsl -->
   <xsl:param name="collect.xref.targets">no</xsl:param>
   <xsl:param name="targets.filename">target.db</xsl:param>
   <xsl:param name="olink.base.uri"/>
   <xsl:param name="glossary.collection"/>

   <!-- Custom params -->
   <xsl:param name="tex.character.replacement.map.filename"
      >tex/character-replacement-map.xml</xsl:param>
   <xsl:param name="tex.title.command.map.filename">tex/title-command-map.xml</xsl:param>

</xsl:stylesheet>
