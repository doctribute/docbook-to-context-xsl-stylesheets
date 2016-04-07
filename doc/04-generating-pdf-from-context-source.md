Generating PDF from ConTeXt source
==================================

1. [Install ConTeXt](http://wiki.contextgarden.net/ConTeXt_Standalone). There are slight differences for particular platforms, but it generally consists of three steps:
   * Creating a dedicated folder, e.g. `D:\context`.
   * Downloading/copying/installing there an initial stuff containing first-setup script/batch.
   * Running the first-setup to downloading/updating the rest.
   
2. Convert the ConTeXt source into PDF
   * Type `context source.tex` into a shell/commandline and run the command. Lot of messages are printed in the console during the processing. An overall progress can be estimated from page numbers, but several passes may be performed till reaching an optimal composition.
   * The final `source.pdf` is stored in the same folder as the source file.
