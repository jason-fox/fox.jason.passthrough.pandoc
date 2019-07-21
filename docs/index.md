<h1>Pandoc Pass Through Plugin for DITA-OT</h1>

This is a DITA-OT Plug-in to used extend the available input formats for DITA-OT. Non DITA input sources can be
pre-processed using [Pandoc](https://pandoc.org/) to create create valid DITA source. Files written in multiple input
formats can be directly added to a `*.ditamap` and processed as if they had been written in DITA.

# Background

**Pandoc** is a Haskell library for converting from one markup format to another, and a command-line tool that uses this
library. It can convert from the following formats:

-   **Markdown:** `commonmark` ([CommonMark](http://commonmark.org) Markdown) ,`gfm`
    ([GitHub-Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/)) ,`markdown`
    ([Pandoc’s Markdown](#pandocs-markdown)) ,`markdown_mmd` ([MultiMarkdown](http://fletcherpenney.net/multimarkdown/))
    ,`markdown_phpextra` ([PHP Markdown Extra](https://michelf.ca/projects/php-markdown/extra/)) ,`markdown_strict`
    (original unextended [Markdown](http://daringfireball.net/projects/markdown/))

-   **Wiki Formats:** `dokuwiki` ([DokuWiki markup](https://www.dokuwiki.org/dokuwiki)) ,`mediawiki`
    ([MediaWiki markup](https://www.mediawiki.org/wiki/Help:Formatting)) ,`muse`
    ([Muse](https://amusewiki.org/library/manual)) ,`tikiwiki`
    ([TikiWiki markup](https://doc.tiki.org/Wiki-Syntax-Text#The_Markup_Language_Wiki-Syntax)) ,`twiki`
    ([TWiki markup](http://twiki.org/cgi-bin/view/TWiki/TextFormattingRules)) ,`vimwiki`
    ([Vimwiki](https://vimwiki.github.io))

-   **Other Formats:** `creole` ([Creole 1.0](http://www.wikicreole.org/wiki/Creole1.0)) ,`docbook`
    ([DocBook](http://docbook.org)) ,`docx` ([Word docx](https://en.wikipedia.org/wiki/Office_Open_XML)) ,`epub`
    ([EPUB](http://idpf.org/epub)) ,`fb2`
    ([FictionBook2](http://www.fictionbook.org/index.php/Eng:XML_Schema_Fictionbook_2.1) e-book) ,`haddock`
    ([Haddock markup](https://www.haskell.org/haddock/doc/html/ch03s08.html)) ,`html` ([HTML](http://www.w3.org/html/))
    ,`ipynb` ([Jupyter notebook](https://nbformat.readthedocs.io/en/latest/)) ,`jats` ([JATS](https://jats.nlm.nih.gov)
    XML) ,`json` (JSON version of native AST) ,`latex` ([LaTeX](http://latex-project.org)) ,`man`
    ([roff man](http://man7.org/linux/man-pages/man7/groff_man.7.html)) ,`native` (native Haskell) ,`odt`
    ([ODT](http://en.wikipedia.org/wiki/OpenDocument)) ,`opml` ([OPML](http://dev.opml.org/spec2.html)) ,`org`
    ([Emacs Org mode](http://orgmode.org)) ,`rst`
    ([reStructuredText](http://docutils.sourceforge.net/docs/ref/rst/introduction.html)) ,`t2t`
    ([txt2tags](http://txt2tags.org)) ,`textile` ([Textile](http://redcloth.org/textile))

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


