DocBook to ConTeXt XSL stylesheets
==================================

A set of stylesheets for conversion a [DocBook](http://docbook.sourceforge.net/) XML source into the format of [ConTeXt](http://wiki.contextgarden.net/What_is_ConTeXt) typesetting system, which can be further processed into a PDF output.

It is an alternative approach to a more common XML -> [XSL-FO](https://en.wikipedia.org/wiki/XSL_Formatting_Objects) -> PDF route.

The main driver here is to offer solution for publishing books (novels, proses, fiction) with the best available typographic quality from the DocBook XML source.

Sample output
-------------
To help embrace this technology a [sample DocBook book](https://github.com/doctribute/docbook-projects/tree/master/books/sa-mekyzo-czolany-nycbytora) has been released together with a real [customization layer](https://github.com/doctribute/docbook-to-context-xsl-stylesheets/blob/master/docbook-custom.xsl). For next steps see the Usage section below.

For your convenience, the result of an XSLT transformation can be downloaded directly, even in two forms:

* [Zip archive](http://doctribute.com/blog/resources/003/source.zip) (0.3 MB) containing the ConTeXt source together with all the images. It needs to be unpacked and then converted into the PDF output as described in the Usage section (step #4).

* [Final PDF](http://doctribute.com/blog/resources/003/final.pdf) (3.9 MB).

The red grid is provided as a separate PDF layer and can be switched off.

This output needs further tweaks. Namely fixing lines exceeding the text area by [setting the less strict alignment tolerance](https://github.com/doctribute/docbook-projects/tree/master/books/sa-mekyzo-czolany-nycbytora). However, majority of cases are caused by inability to properly hyphenate those dummy words. In the real content such occurrences should be rare.

Motivation
----------
* While the most natural conversion from XML to PDF is via XSL-FO intermediate markup, **no XSL-FO engine offers advanced typographic features**. This method is hence disqualified for book production with high typographic standards. 
* For professional workflows Adobe InDesign XML import capabilities can be [employed](http://shop.oreilly.com/product/0636920027966.do), but even **InDesign has its own limits**, namely in footnotes processing.
* Fortunately, there are **TeX-based systems**, which **are flexible enough, yet open source**. The most advanced [seems to be](http://doctribute.com/blog/002-outstanding-typographic-quality-with-open-source-typesetting-tools-en.html) the [ConTeXt](http://wiki.contextgarden.net/What_is_ConTeXt) typesetting system. While there is a dedicated [dbcontext](https://sourceforge.net/projects/dblatex/files/dbcontext/) project available, bringing a decent set of DocBook to ConTeXt XSL stylesheets, it doesn't reflect recent 10+ years of ConTeXt development.

This project started as dbcontext fork for one specific book. While these updates were supplied to the original dbcontext author, it has been decided to create a barely new set of stylesheets.

Main reasons
------------
* simplifying settting up the tools to the end user (not necessary to patch dbcontext with these updates)
* utilizing the current DocBook XSL stylesheets distribution (localizations, string manipulations)
* including verified stylesheets only

Main goals
----------
* to offer generating PDF outputs with advanced typographic features
* utilizing the current DocBook stylesheets infrastructure
* potentially become an integral part of DocBook stylesheets distribution

Known limitations
-----------------
1. Support for very narrow subset of elements, namely chapter, section, para, footnotes, images, tables, index and few others. While not numerous, still sufficient for majority of non-technical books.
2. Advanced index features are not supported in DocBook v5.x as the syntax has changed since v4.x substantially.

Usage
-----
1. [Integrate DocBook to ConTeXt XSL stylesheets into DocBook XSL stylesheets](doc/01-integrating-docbook-to-context-xsl-stylesheets-into-docbook-xsl-stylesheets.md
).
2. [Optionally make your own stylesheets customizations](doc/02-customizing-docbook-to-context-xsl-stylesheets.md).
3. [Run the transformation via an XSLT processor](doc/03-running-xslt-transformation.md).
4. [Convert the ConTeXt source into a PDF output](doc/04-generating-pdf-from-context-source.md).

Future
------
The long term plan is to continuously extend the element coverage to support more complex documents. Feel free to speed-up this process by your pull requests :-)

Aknowledgement
--------------
* Norman Walsh, Bob Stayton and Jirka Kosek (DocBook developers & evangelists)
* Hans Hagen (ConTeXt developer)
* Wolfgang Schuster (ConTeXt community supporter)
* Ben Guillon (dbcontext developer)
