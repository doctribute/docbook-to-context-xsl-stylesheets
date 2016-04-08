Running XSLT transformation
===========================

As the provided [sample book](https://github.com/doctribute/docbook-projects/tree/master/books/sa-mekyzo-czolany-nycbytora) is based on DocBook v4.5, all following steps are tailored for this kind of source data (e.g. DTD based validation).

While it requires more complicated settings, it is recommended to setup XML catalogs to avoid downloading DocBook scheme every run. See details in e.g. [How to use a catalog file](http://www.sagehill.net/docbookxsl/UseCatalog.html) section in DocBook XSL: The Complete Guide.

Supposing [Saxon 6.5.5](http://saxon.sourceforge.net/saxon6.5.5/) is used and the following structure is created, just follow steps below:

```
D:\docbook
+-- docbook-system
|   +-- 4.5 (http://www.docbook.org/xml/4.5/docbook-xml-4.5.zip)
|   |   +-- calstblx.dtd
|   |   +-- catalog.xml
|   |   +-- ...
|   +-- ...
+-- docbook-xsl-stylesheets
|   +-- 1.79.1 (https://sourceforge.net/projects/docbook/files/docbook-xsl/1.79.1/)
|   |   +-- assembly
|   |   +-- common
|   |   +-- context (new folder)
|   |   +-- ...
|   +-- ...
+-- customized-xsl-stylesheets
|   +-- context
|   |   +-- docbook.xsl (importing the original context\docbook.xsl)
|   +-- ...
+-- projects
|   +-- sample-book
|   |   +-- images
|   |   |   +-- image.png
|   |   +-- source.xml
|   +-- ...
+-- tools
|   +-- CatalogManager.properties (see bellow)
|   +-- resolver.jar (http://www.apache.org/dist/xerces/xml-commons/xml-commons-resolver-1.2.zip)
|   +-- saxon.jar (https://sourceforge.net/projects/saxon/files/saxon6/6.5.5/)
```

1. Create a plain text file `CatalogManager.properties` with the following content

   ```
   catalogs=file:/D:/docbook/docbook-system/4.5/catalog.xml
   relative-catalogs=false
   static-catalog=yes
   catalog-class-name=org.apache.xml.resolver.Resolver
   verbosity=1
   ```
   
2. Create a batch file to execute XSLT processor with additional parameters

   ```
   SET BASE_FOLDER=D:\docbook
   SET TOOLS_FOLDER=%BASE_FOLDER%\tools
   SET SAXON_CLASS_PATH=%TOOLS_FOLDER%;%TOOLS_FOLDER%\resolver.jar;%TOOLS_FOLDER%\saxon.jar;
   SET SAXON_PARAM=-x org.apache.xml.resolver.tools.ResolvingXMLReader -y org.apache.xml.resolver.tools.ResolvingXMLReader -r org.apache.xml.resolver.tools.CatalogResolver
   java -Xmx1G -cp %SAXON_CLASS_PATH% com.icl.saxon.StyleSheet %SAXON_PARAM% -o %BASE_FOLDER%\output.tex %BASE_FOLDER%\projects\sample-book\source.xml %BASE_FOLDER%\customized-stylesheets\context\docbook.xsl
   ```
   
3. Run the batch file

The result should be stored in `D:\docbook\output.tex`.
