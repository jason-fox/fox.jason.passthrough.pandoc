<h1>Usage</h1>

To mark a file to be passed through for **Pandoc** processing, label it with `format="pandoc"` within the `*.ditamap` as
shown:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE bookmap PUBLIC "-//OASIS//DTD DITA BookMap//EN" "bookmap.dtd">
<bookmap>
    ...etc
    <chapter format="pandoc" href="sample.docx"/>
</bookmap>
```

The additional file will run against the Pandoc _XXX-to-DITA_ lua filter to be converted to a `*.dita` file and will be
added to the build job without further processing. The `navtitle` of the included topic will be the same as root name of
the file. Any underscores in the filename will be replaced by spaces in title.

## How to annotate Pandoc passthrough files

The examples below use Markdown as a passthrough format, other formats need to provide equivalent annotations to obtain
full functionality. Where possible, annotation aligns with the
[Markdown DITA syntax reference](https://www.dita-ot.org/dev/topics/markdown-dita-syntax-reference.html) based on
[CommonMark](http://commonmark.org/). The chapter `title` is taken from the first header found. Thereafter the document
is processed as expected:

```markdown
# Chapter title

The abstract (if any) goes here...

## Topic 1

Body of topic 1 goes here.

## Topic 2

Body of topic 2 goes here.

...etc
```

Ideally input files should only contain a single `<h1>` header

### ID and outputclass

Pandoc [header_attributes](http://pandoc.org/MANUAL.html#extension-header_attributes) can be used to define `id` or
`outputclass` attributes:

```markdown
# Topic title {#carrot .juice}
```

### Sections

The following class values in [header_attributes](http://pandoc.org/MANUAL.html#extension-header_attributes) have a
special meaning on header levels.

-   `section`
-   `example`

They are used to generate `<section>` and `<example>` elements:

```markdown
# Topic title

## Section title {.section}

## Example title {.example}
```

### Metadata

[YAML](http://www.yaml.org/) metadata block as defined in Pandoc pandoc_metadata_block can be used to specify different
metadata elements. The supported elements are:

-   `author`
-   `source`
-   `publisher`
-   `permissions`
-   `audience`
-   `category`
-   `keyword`
-   `resourceid`
-   `shortdesc`

Unrecognized keys are output using data element.

```markdown
---
author:
    - Author One
    - Author Two
source: Source
publisher: Publisher
permissions: Permissions
audience: Audience
category: Category
keyword:
    - Keyword1
    - Keyword2
resourceid:
    - Resourceid1
    - Resourceid2
workflow: review
---
```

#### Sample output with YAML header

```xml
<title>Sample with YAML header</title>
<prolog>
  <author>Author One</author>
  <author>Author Two</author>
  <source>Source</source>
  <publisher>Publisher</publisher>
  <permissions view="Permissions"/>
  <metadata>
    <audience audience="Audience"/>
    <category>Category</category>
    <keywords>
      <keyword>Keyword1</keyword>
      <keyword>Keyword2</keyword>
    </keywords>
  </metadata>
  <resourceid appid="Resourceid1"/>
  <resourceid appid="Resourceid2"/>
  <data name="workflow" value="review"/>
</prolog>
```

## Ditamap TopicMeta for Pandoc Files

Ditamap `<topicmeta>` processing is also supported.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE bookmap PUBLIC "-//OASIS//DTD DITA BookMap//EN" "bookmap.dtd">
<bookmap>
    <chapter format="pandoc" processing-role="normal" type="topic" href="markdown.md">
        <topicmeta>
            <shortdesc>This is where the shortdesc goes</shortdesc>
            <metadata>
                 <keywords>
                    <keyword>Keyword1</keyword>
                    <keyword>Keyword2</keyword>
                </keywords>
            </metadata>
        </topicmeta>
    </chapter>
</bookmap>
```

This allows for topic metadata to be added to files for formats other than Markdown.
