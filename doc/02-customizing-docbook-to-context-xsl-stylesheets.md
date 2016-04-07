Customizing DocBook to ConTeXt XSL stylesheets
==============================================

It is supposed the main tweaking will take place directly in the generated ConTeXt source – after an initial XSLT transformation. This is the reason why most of formatting is concentrated in a single plain text template in favour of individual stylesheet parameters. The same approach is used also for a title page.

See two most important templates:
* `<xsl:template name="setup.document">` in [pagesetup.xsl](pagesetup.xsl)
* `<xsl:template match="book|article" mode="titlepage.mode">` in [titlepage.xsl](titlepage.xsl)

The integral part of stylesheets is a [customization](docbook-custom.xsl) used for typesetting the [sample book](https://github.com/doctribute/docbook-projects/tree/master/books/sa-mekyzo-czolany-nycbytora).
