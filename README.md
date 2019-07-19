# Pandoc Pass Through Plugin for DITA-OT

[![license](https://img.shields.io/github/license/jason-fox/fox.jason.passthrough.pandoc.svg)](http://www.apache.org/licenses/LICENSE-2.0)
[![DITA-OT 3.3](https://img.shields.io/badge/DITA--OT-3.3-blue.svg)](http://www.dita-ot.org/3.3/) <br/>

This is a DITA-OT Plug-in to used extend the available input formats for DITA-OT. Non DITA input sources can be
pre-processed using [Pandoc](https://pandoc.org/) to create create valid DITA source. Files written in multiple input
formats can be directly added to a `*.ditamap` and processed as if they had been written in DITA.

# Table of Contents

-   [Background](#background)
-   [Install](#install)
    -   [Installing DITA-OT](#installing-dita-ot)
    -   [Installing the Plug-in](#installing-the-plug-in)
    -   [Installing Pandoc](#installing-pandoc)
-   [Usage](#usage)
-   [License](#license)

# Background

**Pandoc** is a Haskell library for converting from one markup format to another, and a command-line tool that uses this
library. It can convert from the following formats:

-  **Markdown:**  `commonmark` ([CommonMark](http://commonmark.org) Markdown)
,`gfm` ([GitHub-Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/))
,`markdown` ([Pandoc’s Markdown](#pandocs-markdown))
,`markdown_mmd` ([MultiMarkdown](http://fletcherpenney.net/multimarkdown/))
,`markdown_phpextra` ([PHP Markdown Extra](https://michelf.ca/projects/php-markdown/extra/))
,`markdown_strict` (original unextended [Markdown](http://daringfireball.net/projects/markdown/))

-  **Wiki Formats:**  `dokuwiki` ([DokuWiki markup](https://www.dokuwiki.org/dokuwiki))
,`mediawiki` ([MediaWiki markup](https://www.mediawiki.org/wiki/Help:Formatting))
,`muse` ([Muse](https://amusewiki.org/library/manual))
,`tikiwiki` ([TikiWiki markup](https://doc.tiki.org/Wiki-Syntax-Text#The_Markup_Language_Wiki-Syntax))
,`twiki` ([TWiki markup](http://twiki.org/cgi-bin/view/TWiki/TextFormattingRules))
,`vimwiki` ([Vimwiki](https://vimwiki.github.io))

- **Other Formats:**
,`creole` ([Creole 1.0](http://www.wikicreole.org/wiki/Creole1.0))
,`docbook` ([DocBook](http://docbook.org))
,`docx` ([Word docx](https://en.wikipedia.org/wiki/Office_Open_XML))
,`epub` ([EPUB](http://idpf.org/epub))
,`fb2` ([FictionBook2](http://www.fictionbook.org/index.php/Eng:XML_Schema_Fictionbook_2.1) e-book)
,`haddock` ([Haddock markup](https://www.haskell.org/haddock/doc/html/ch03s08.html))
,`html` ([HTML](http://www.w3.org/html/))
,`ipynb` ([Jupyter notebook](https://nbformat.readthedocs.io/en/latest/))
,`jats` ([JATS](https://jats.nlm.nih.gov) XML)
,`json` (JSON version of native AST)
,`latex` ([LaTeX](http://latex-project.org))
,`man` ([roff man](http://man7.org/linux/man-pages/man7/groff_man.7.html))
,`native` (native Haskell)
,`odt` ([ODT](http://en.wikipedia.org/wiki/OpenDocument))
,`opml` ([OPML](http://dev.opml.org/spec2.html))
,`org` ([Emacs Org mode](http://orgmode.org))
,`rst` ([reStructuredText](http://docutils.sourceforge.net/docs/ref/rst/introduction.html))
,`t2t` ([txt2tags](http://txt2tags.org))
,`textile` ([Textile](http://redcloth.org/textile))


This plug-in contains a Lua template which extends the output formats supported by **Pandoc** to include DITA. The
output consists of a single DITA topic for each input file added to the ditamap.

Unlike the standard [Markdown Plug-in](https://github.com/jelovirt/org.lwdita), this plug-in does not fail if the
`h1...h6` headers are incorrectly incremented. This is because the Lua template has been designed to calculate that
headers are incrementing at most one level at a time - the downside of this is that the output maybe unexpected.

Note that because pandoc’s intermediate representation of a document is less expressive than many of the formats it
converts between, one should not expect perfect conversions between every format and every other. Pandoc attempts to
preserve the structural elements of a document, but not formatting details such as margin size. And some document
elements, such as complex tables, may not fit into pandoc’s simple document model. While conversions from pandoc’s
Markdown to all formats aspire to be perfect, conversions from formats more expressive than pandoc’s Markdown can be
expected to be lossy.

# Install

The DITA-OT Pandoc Pass Through plug-in has been tested against [DITA-OT 3.x](http://www.dita-ot.org/download). It is
recommended that you upgrade to the latest version.

## Installing DITA-OT

<a href="https://www.dita-ot.org"><img src="https://www.dita-ot.org/images/dita-ot-logo.svg" align="right" height="55"></a>

The DITA-OT Pandoc plug-in is a file reader for the DITA Open Toolkit.

-   Full installation instructions for downloading DITA-OT can be found
    [here](https://www.dita-ot.org/3.3/topics/installing-client.html).

    1.  Download the `dita-ot-3.3.zip` package from the project website at
        [dita-ot.org/download](https://www.dita-ot.org/download)
    2.  Extract the contents of the package to the directory where you want to install DITA-OT.
    3.  **Optional**: Add the absolute path for the `bin` directory to the _PATH_ system variable.

    This defines the necessary environment variable to run the `dita` command from the command line.

```console
curl -LO https://github.com/dita-ot/dita-ot/releases/download/3.3/dita-ot-3.3.zip
unzip -q dita-ot-3.3.zip
rm dita-ot-3.3.zip
```

## Installing the Plug-in

-   Run the plug-in installation commands:

```console
dita --install https://github.com/doctales/org.doctales.xmltask/archive/master.zip
dita -install https://github.com/jason-fox/fox.jason.passthrough/archive/master.zip
dita -install https://github.com/jason-fox/fox.jason.passthrough.pandoc/archive/master.zip
```

The `dita` command line tool requires no additional configuration.

---

## Installing Pandoc

To download a copy follow the instructions on the [Install page](https://github.com/jgm/pandoc/blob/master/INSTALL.md)

# Usage

To mark a file to be passed through for **Pandoc** processing, label it with `format="pandoc"` within the `*.ditamap` as shown:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE bookmap PUBLIC "-//OASIS//DTD DITA BookMap//EN" "bookmap.dtd">
<bookmap>
    ...etc
    <mapref format="pandoc" href="sample.docx"/>
</bookmap>
```

The additional file will be added to the build job without processing.

# License

[Apache 2.0](LICENSE) © 2019 Jason Fox

The Program includes the following additional software components which were obtained under license:

-   xmltask.jar - http://www.oopsconsultancy.com/software/xmltask/ - **Apache 1.1 license** (within
    `org.doctales.xmltask` plug-in)
