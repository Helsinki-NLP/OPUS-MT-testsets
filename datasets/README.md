
# Test set catalog

The list of available test sets is stored in TSV files with the following columns

* source language ID
* target language ID
* benchmark name (needs to be unique in the entire collection)
* optional domain labels
* optional source language label (e.g. language variety)
* optional target language label (e.g. language variety)
* path to the source language file (input)
* path to the target language file (reference translation)
* optional reference file(s) (one per extra column)


Source and target language files need to be aligned with linked units on corresponding lines (typically sentences). Empty lines can be used to mark document boundaries. All files should be encoded in Unicode UTF-8.

