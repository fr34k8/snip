![alt tag](https://raw.githubusercontent.com/lateralblast/snip/master/snip.jpg)

SNIP
====

Service Now Information Processor

Information
-----------

Processes a Service Now XLSX CMDB extract

License
-------

This software is licensed as CC-BA (Creative Commons By Attrbution)

http://creativecommons.org/licenses/by/4.0/legalcode

Usage
-----

```
$ snip.pl -h

-h: Display help/usage
-V: Display version
-c: Check CMDB data
-i: Input file (Default ./cmdb.xlsx)
```

Examples
--------

Check CMDB extract

```
$ snip.pl -c -i CMDB.xlsx
```

Requirements
------------

Perl Modules:

- use Spreadsheet::XLSX
- Getopt::Std
- Text::Iconv
