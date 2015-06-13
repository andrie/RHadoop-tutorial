Introduction to Using R with Hadoop
========================================================
author: Andrie de Vries & Simon Field
date: 2015-07-01, UseR!2015
width: 1680
height: 1050
css: css/custom.css

hdfs
====
type: section

What is the Hadoop dfs?
=======================

* Distributed file system
* Automatic redundancy
* Designed for large volumes of data, written once, read frequently
* Individual files get split across nodes

rhdfs function overview
=======================

* Initialize
  - `hdfs.init()`
  - `hdfs.defaults()`
* File and directory manipulation
  - `hdfs.ls()`
  - `hdfs.delete()`
  - `hdfs.mkdir()`
  - `hdfs.exists()`
* Copy and move from local <-> HDFS
  - `hdfs.put()`
  - `hdfs.get()`

***

* Manipulate files within HDFS
  - `hdfs.copy()`
  - `hdfs.move()`
  - `hdfs.rename()`
* Reading files directly from HDFS
  - `hdfs.file()`
  - `hdfs.read()`
  - `hdfs.write()`
  - `hdfs.flush()`
  - `hdfs.seek()`
  - `hdfs.tell(con)`
  - `hdfs.close()`
  - `hdfs.line.reader()`
  -  `hdfs.read.text.file()`


Exercise-3.R
============

* Download a book from Project Gutenberg to the local file system.
* Then put the file in hdfs using `hdfs.put()`

Word count
==========

![](images/xkcd-wordcount.png)

***

* Word count is the archetypal `hello world!` in Hadoop
* The mapper splits text into individual words and counts occurrences
* Reducer computes total across all mappers


Map Reduce Word Count Example
=============================

![](images/wordcount.png)

Exercise-4.R
============


Write a standard R script to count the number of words in the ebook you downloaded (use the local file system).

Don't use mapreduce just yet!


Exercise-5.R
============

Now complete the wordcount using `mapreduce()`



Demo 2
======




```r
groups <- rbinom(32, n = 50, prob = 0.4)
tapply(groups, groups, length)
```

```
 7  8  9 10 11 12 13 14 15 16 17 18 
 1  2  2  2  9  8  8  8  4  3  2  1 
```

Demo 2
======






```
Error in eval(expr, envir, enclos) : could not find function "to.dfs"
```
