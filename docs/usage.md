<h1>Usage</h1>

To mark a file to be passed through for **Pandoc** processing, label it with `format="pandoc"` within the `*.ditamap` as
shown:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE bookmap PUBLIC "-//OASIS//DTD DITA BookMap//EN" "bookmap.dtd">
<bookmap>
    ...etc
    <chapter format="pandoc" processing-role="normal" type="topic" href="Word_Document.docx"/>
</bookmap>
```

The additional file will run against the Pandoc _XXX-to-DITA_ lua filter to be converted to a `*.dita` file and will be added to the build job without further processing. The title of the included topic will be the same as root name of the file. Any underscores in the filename will be replaced by spaces in title.