<a name = "contents"></a>Contents
---------------------------------

1.  [Package Overview](#overview)
2.  [Connecting to ATSD](#connecting)
3.  [Querying ATSD](#querying)
4.  [Transforming Data Frame to zoo Object](#zoo)
5.  [Getting Metrics](#metrics)
6.  [Getting Entities](#entities)
7.  [Getting Time Series Tags](#gtst)
8.  [Saving time series in ATSD](#saving_ts)
9.  [Expression Syntax](#expression)
10. [Advanced Connection Options](#advanced)

1. <a name = "overview"></a> Package Overview
---------------------------------------------

The package allows you query time-series data and statistics from [Axibase Time-Series Database](http://axibase.com/axibase-time-series-database/) (ATSD) and save time-series data in ATSD. List of package functions:

-   [set\_connection()](#set_connection), [save\_connection()](#save_connection), [show\_connection()](#show_connection) -- are used to manage the connection with ATSD. Set up and store the url, user name, and password. Configure cryptographic protocol and enforce SSL certificate validation in the case of https connection.
-   [query()](#query) -- get historical data and forecasts from ATSD.
-   [get\_metrics()](#get_metrics) -- get information about the metrics collected by ATSD.
-   [get\_entities()](#get_entities) -- get information about the entities collected by ATSD.
-   [get\_series\_tags()](#get_series_tags) -- get unique series tags for the metric.
-   [save\_series()](#save_series) -- save time series into ATSD.
-   [to\_zoo()](#to_zoo) -- converts a time-series data frame to 'zoo' object for manipulating irregular time-series with built-in functions in zoo package.

[Return to Contents](#contents)

2. <a name = "connecting"></a> Connecting to ATSD
-------------------------------------------------

Execute `library(atsd)`  to start working with the atsd package. The connection parameters are loaded from the package configuration file, <tt><font color = "SaddleBrown">atsd/connection.config</font></tt>,  which is located in the atsd package folder. The command

``` r
installed.packages()["atsd", "LibPath"]
```

shows you where the atsd package folder is. Open a text editor and modify the configuration file. It should look as follows:

     # the url of ATSD including port number
     url=http://host_name:port_number   
     # the user name
     user=atsd_user_name
     # the user's password
     password=atsd_user_password   
     # validate ATSD SSL certificate: yes, no
     verify=no  
     # cryptographic protocol used by ATSD https server:
     # default, ssl2, ssl3, tls1
     encryption=ssl3   

Reload the modified connection parameters from the configuration file:

``` r
set_connection()
```

Check that parameters are correct:

``` r
show_connection()
```

Refer to Chapter 9 for more options on managing ATSD connection parameters.

[Return to Contents](#contents)

3. <a name = "querying"></a>Querying ATSD
-----------------------------------------

<a name = "query"></a> **Function name:** query()

**Description:** The function retrieves historical time-series data or forecasts from ATSD.

**Returns object:** data frame

**Arguments:**

-   <tt><font color = "SaddleBrown">metric</font></tt>  (required, string)
    The name of the metric you want to get data for, for example, "disk\_used\_percent".
    To obtain a list of metrics collected by ATSD use the [get\_metrics()](#get_metrics) function.

-   <tt><font color = "SaddleBrown">selection\_interval</font></tt>  (required, string)
     This is the time interval for which the data will be selected. Specify it as "n-unit", where
     unit is a Second, Minute, Hour, Day, Week, Month, Quarter, or Year and n is the number of units, for example, "3-Week" or "12-Hour".

-   <tt><font color = "SaddleBrown"> entity </font></tt>  (optional, string)
    The name of the entity you want to get data for. If not provided, then data for all entities will be fetched for the specified metric. Obtain the list of entities with the [get\_entities()](#get_entities) function.

-   <tt><font color = "SaddleBrown"> entity\_group </font></tt>  (optional, string)
    The name of entity group, for example, "HP Servers". Extracts data for all entities belonging to this group.

-   <tt><font color = "SaddleBrown"> tags </font></tt>  (optional, string vector)
    List of user-defined series tags to filter the fetched time-series data, for example, <tt>c("disk\_name=sda1", "mount\_point=/") </font></tt>.

-   <tt><font color = "SaddleBrown"> end\_time </font></tt>  (optional, string)
    The end time of the selection interval, for example, `end_time = "date('2014-12-27')"`. If not provided, the current time will be used. Specify the date and time, or use one of the supported expressions: [end time syntax](http://axibase.com/products/axibase-time-series-database/visualization/end-time/). For example, 'current\_day' would set the end of selection interval to 00:00:00 of the current day.

-   <tt><font color = "SaddleBrown">aggregate\_interval</font></tt>  (optional, string)
    The length of the aggregation interval. The period of produced time-series will be equal to the <tt><font color = "SaddleBrown">aggregate\_interval</font></tt>.  The value for each period is computed by the <tt><font color = "SaddleBrown">aggregate\_statistics</font></tt>  function applied to all samples of the original time-series within the period. The format of the <tt><font color = "SaddleBrown">aggregate\_interval</font></tt>  is the same as for the <tt><font color = "SaddleBrown">selection\_interval</font></tt>  argument, for example, "1-Minute".

-   <tt><font color = "SaddleBrown"> aggregate\_statistics </font></tt>  (optional, string vector)
    The statistic functions used for aggregation. Multiple values are supported, for example, c("Min", "Avg", "StDev"). The default value is "Avg".

-   <tt><font color = "SaddleBrown"> interpolation </font></tt>  (optional, string)
    If aggregation is enabled, then the values for the periods without data will be computed by one of the following interpolation functions: "None", "Linear", "Step". The default value is "None".

-   <tt><font color = "SaddleBrown">export\_type</font></tt>  (optional, string)
     Supported options: "History" or "Forecast". The default value is "History".

-   <tt><font color = "SaddleBrown"> verbose </font></tt>  (optional, string)
    If <tt>verbose = FALSE</tt>,  then all console output will be suppressed. By default, <tt>verbose = TRUE</tt>.

**Examples:**

``` r
# get historic data for the given entity, metric, and selection_interval
dfr <- query(entity = "nurswgvml007", metric = "cpu_busy", selection_interval = "1-Hour")
```

``` r
# look at head of fetched data frame with the pander package
pandoc.table(head(dfr, 3), style = "grid")
#> 
#> 
#> +---------------------+---------+----------+--------------+
#> |      Timestamp      |  Value  |  metric  |    entity    |
#> +=====================+=========+==========+==============+
#> | 2015-04-08 09:17:24 |  15.79  | cpu_busy | nurswgvml007 |
#> +---------------------+---------+----------+--------------+
#> | 2015-04-08 09:17:40 |    9    | cpu_busy | nurswgvml007 |
#> +---------------------+---------+----------+--------------+
#> | 2015-04-08 09:17:56 |  10.1   | cpu_busy | nurswgvml007 |
#> +---------------------+---------+----------+--------------+
```

``` r
# end_time usage example
query(entity = "host-383", metric = "cpu_usage", selection_interval = "1-Day", 
      end_time = "date('2015-02-10 10:15:03')")

# get forecasts
query(metric = "cpu_busy", selection_interval = "30-Minute", export_type = "Forecast", verbose = FALSE)

# use aggregation
query(metric = "disk_used_percent", entity_group = "Linux", tags = c("mount_point=/boot",  
      "file_system=/dev/sda1"), selection_interval = "1-Week", aggregate_interval = "1-Minute",
      aggregate_statistics = c("Avg", "Min", "Max"), interpolation = "Linear", export_type = "Forecast")
```

[Return to Contents](#contents)

4. <a name = "zoo"></a>Transforming Data Frame to a zoo Object
--------------------------------------------------------------

<a name = "to_zoo"></a> **Function name:** to\_zoo()

**Description:** The function builds a zoo object from the given data frame. The <tt><font color = "SaddleBrown">timestamp</font></tt>  argument provides column of the data frame which is used as the index for the zoo object. The <tt><font color = "SaddleBrown">value</font></tt>  argument indicates the series which will be saved in a zoo object. If several columns are listed in the <tt><font color = "SaddleBrown">value</font></tt>  argument, they will all be saved in a multivariate zoo object. Information from other columns is ignored. To use this function the 'zoo' package should be installed.

**Returns object:** [zoo](http://cran.r-project.org/web/packages/zoo/index.html) object

**Arguments:**

-   <tt><font color = "SaddleBrown">dfr</font></tt>  (required, data frame)
     The data frame.

-   <tt><font color = "SaddleBrown">timestamp</font></tt>  (optional, character or numeric)
     Name or number of a column with time stamps. By default, `timestamp = "Timestamp"`.

-   <tt><font color = "SaddleBrown">value</font></tt>  (optional, character vector or numeric vector)
     Names or numbers of columns with series values. By default, `value = "Value"`.

**Examples:**

``` r
# query ATSD for data and transform it to zoo object
dfr <- query(entity = "nurswgvml007", metric = "cpu_busy", selection_interval = "1-Hour")
z <- to_zoo(dfr)
```

``` r
# show head of the zoo object
head(z, 3)
#> 2015-04-08 09:17:24 2015-04-08 09:17:40 2015-04-08 09:17:56 
#>               15.79                9.00               10.10
```

[Return to Contents](#contents)

5. <a name = "metrics"></a>Getting Metrics
------------------------------------------

<a name = "get_metrics"></a> **Function name:** get\_metrics()

**Description:** This function fetches a list of metrics and their tags from ATSD, and converts it to a data frame.

**Returns object:** data frame

Each row of the data frame corresponds to a metric and its tags:

-   <tt><font color = "DarkGreen"> name </font></tt> 
     Metric name (unique)

-   <tt><font color = "DarkGreen"> counter </font></tt> 
     Counters are metrics with continuously incrementing value

-   <tt><font color = "DarkGreen"> lastInsertTime </font></tt> 
     Last time value was received by ATSD for this metric

-   <tt><font color = "DarkGreen"> tags </font></tt> 
     User-defined tags (as requested by the "tags" argument)

**Arguments:**

-   <tt><font color = "SaddleBrown">expression</font></tt>  (optional, string)
    Select metrics matching particular name pattern and/or user-defined metric tags. For examples refer to "Expression syntax" chapter.

-   <tt><font color = "SaddleBrown"> active</font></tt>  (optional, one of strings: "true" or "false")
    Filter metrics by <tt>lastInsertTime</tt>  attribute. If <tt>active = "true"</tt>,  only metrics with positive <tt>lastInsertTime</tt>  are included in the response.

-   <tt><font color = "SaddleBrown">tags</font></tt>  (optional, string vector)
    User-defined metric tags to be included in the response. By default, all the tags will be included.

-   <tt><font color = "SaddleBrown">limit</font></tt>  (optional, integer)
    If limit \> 0, the response shows the top-N metrics ordered by name.

-   <tt><font color = "SaddleBrown">verbose</font></tt>  (optional, string)
    If <tt>verbose = FALSE</tt>,  then all console output will be suppressed.

**Examples:**

``` r
# get all metrics and include all their tags in the data frame
metrics <- get_metrics()
```

``` r
colnames(metrics)
#> [1] "name"           "counter"        "label"          "lastInsertTime"
#> [5] "tags.table"     "tags.source"
pandoc.table(metrics[1, ], style = "grid")
#> 
#> 
#> +-------------------+-----------+---------+------------------+--------------+---------------+
#> |       name        |  counter  |  label  |  lastInsertTime  |  tags.table  |  tags.source  |
#> +===================+===========+=========+==================+==============+===============+
#> | %_privileged_time |   FALSE   |   NA    |        NA        |      NA      |      NA       |
#> +-------------------+-----------+---------+------------------+--------------+---------------+
```

``` r
# get the first 100 active metrics which have the tag, "table", 
# include this tag into response and exclude oter user-defined metric tags
metrics <- get_metrics(expression = "tags.table != ''", active = "true", tags = "table", limit = 100)
```

``` r
tail(metrics$name)
#> [1] "collector-jdbc-query-rows" "cpu_busy"                 
#> [3] "cpu_idle"                  "cpu_iowait"               
#> [5] "cpu_nice"                  "cpu_steal"
```

[Return to Contents](#contents)

6. <a name = "entities"></a>Getting Entities
--------------------------------------------

<a name = "get_entities"></a> **Function name:** get\_entities()

**Description:** This function fetches a list of entities and their tags from ATSD, and converts it to a data frame.

**Returns object:** data frame

Each row of the data frame corresponds to an entity and its tags:

-   <tt><font color = "DarkGreen"> name </font></tt> 
     Entity name (unique)

-   <tt><font color = "DarkGreen"> enabled </font></tt> 
     Enabled status, incoming data is discarded for disabled entities

-   <tt><font color = "DarkGreen"> lastInsertTime </font></tt> 
     Last time value was received by ATSD for this entity

-   <tt><font color = "DarkGreen"> tags </font></tt> 
     User-defined tags (as requested by the "tags" argument)

**Arguments:**

-   <tt><font color = "SaddleBrown">expression</font></tt>  (optional, string)
    Select entities matching particular name pattern and/or user-defined entity tags. For examples refer to "Expression syntax" chapter.

-   <tt><font color = "SaddleBrown"> active</font></tt>  (optional, one of strings: "true" or "false")
    Filter entities by <tt>lastInsertTime</tt>  attribute. If <tt>active = "true"</tt>,  only entities with positive <tt>lastInsertTime</tt>  are included in the response.

-   <tt><font color = "SaddleBrown">tags</font></tt>  (optional, string vector)
    User-defined entity tags to be included in the response. By default, all the tags will be included.

-   <tt><font color = "SaddleBrown">limit</font></tt>  (optional, integer)
    If limit \> 0, the response shows the top-N entities ordered by name.

-   <tt><font color = "SaddleBrown">verbose</font></tt>  (optional, string)
    If <tt>verbose = FALSE</tt>,  then all console output will be suppressed.

**Examples:**

``` r
# get all entities
entities <- get_entities()
```

``` r
names(entities)
#>  [1] "name"             "enabled"          "lastInsertTime"  
#>  [4] "tags.test"        "tags.app"         "tags.ip"         
#>  [7] "tags.os"          "tags.loc_area"    "tags.loc_code"   
#> [10] "tags.environment" "tags.uuu.tag"     "tags.uuu.tag.1"
nrow(entities)
#> [1] 230
```

``` r
# select entities by name and user-defined tag "app" 
entities <- get_entities(expression = "name like 'nur*' and lower(tags.app) like '*hbase*'" )
```

``` r
entities$name
#> [1] "nurswgvml006" "nurswgvml203" "nurswgvml204" "nurswgvml205"
#> [5] "nurswgvml206" "nurswgvml207" "nurswgvml208"
```

[Return to Contents](#contents)

7. <a name = "gtst"></a> Getting Time Series Tags
-------------------------------------------------

<a name = "get_series_tags"></a> **Function name:** get\_series\_tags()

**Description:** The function determines time series collected by ATSD for a given metric. For each time series it lists tags associated whith the series, and last time the series was updated. The list of fetched time series is based on data stored on disk for the last 24 hours.

**Returns object:** data frame

Each row of the data frame corresponds to a time series and its tags:

-   <tt><font color = "DarkGreen"> entity </font></tt> 
     Name of entity which generate the time series.

-   <tt><font color = "DarkGreen"> lastInsertTime </font></tt> 
     Last time value was received by ATSD for this time series.

-   <tt><font color = "DarkGreen"> tags </font></tt> 
     Tags of the series.

**Arguments:**

-   <tt><font color = "SaddleBrown">metric</font></tt>  (required, string)
    The name of the metric you want to get time series for, for example, "disk\_used\_percent".
    To obtain a list of metrics collected by ATSD use the [get\_metrics()](#get_metrics) function.

-   <tt><font color = "SaddleBrown"> entity </font></tt>  (optional, string)
    The name of the entity you want to get time series for. If not provided, then data for all entities will be fetched for the specified metric. Obtain the list of entities with the [get\_entities()](#get_entities) function.

-   <tt><font color = "SaddleBrown">verbose</font></tt>  (optional, string)
    If <tt>verbose = FALSE</tt>,  then all console output will be suppressed.

**Examples:**

``` r
# get all time series and their tags collected by ATSD for the "disk_used_percent" metric
tags <- get_series_tags(metric = "disk_used_percent")
```

``` r
pandoc.table(head(tags, 3), style = "grid")
#> 
#> 
#> +--------------+---------------------+-------------------------------------+--------------------+
#> |    entity    |   lastInsertTime    |          tags.file_system           |  tags.mount_point  |
#> +==============+=====================+=====================================+====================+
#> | nurswgvml007 | 2015-04-08 10:17:15 | /dev/mapper/vg_nurswgvml007-lv_root |         /          |
#> +--------------+---------------------+-------------------------------------+--------------------+
#> | nurswgvml007 | 2015-04-08 10:17:15 |    10.102.0.2:/home/store/share     |     /mnt/share     |
#> +--------------+---------------------+-------------------------------------+--------------------+
#> | nurswgvml006 | 2015-04-08 10:17:21 | /dev/mapper/vg_nurswgvml006-lv_root |         /          |
#> +--------------+---------------------+-------------------------------------+--------------------+
```

``` r
# get all time series and their tags for the "disk_used_percent" metric
# end "nurswgvml007" entity
get_series_tags(metric = "disk_used_percent", entity = "nurswgvml007")
```

[Return to Contents](#contents)

8. <a name = "saving_ts"></a> Saving Time-series in ATSD
--------------------------------------------------------

<a name = "save_series"></a> **Function name:** save\_series()

**Description:** Save time-series from the data frame into ATSD. The data frame should have a column with timestamps and at least one numeric column with values of a metric.

**Returns object:** NULL

**Arguments:**

-   <tt><font color = "SaddleBrown">dfr</font></tt>  (required, data frame)
     The data frame should have a column with timestamps and at least one numeric column with values of a metric.

-   <tt><font color = "SaddleBrown">time\_col</font></tt>  (optional, numeric or character)
     Number or name of the column with the timestamps. Default value is 1. For example, <tt><font color = "SaddleBrown">time\_col = 1</font></tt>,  or <tt><font color = "SaddleBrown">time\_col = "Timestamp"</font></tt>.  Read "Timestamps format" section below for suppported timestamp classes and formats.

-   <tt><font color = "SaddleBrown"> time\_format</font></tt>  (optional, string)
     Optional string argument, indicates format of timestamps. This argument is used in the case when timestamp format is not clear from their class. The value of this argument can be one of the following: `"ms"` (for epoch milliseconds), `"sec"` (for epoch seconds), or a format string, for example `"\%Y-\%m-\%d \%H:\%M:\%S"`. This format string will be used to convert the provided timestamps to epoch milliseconds before storing the timestamps in ATSD. Read "Timestamp format" section for details.

-   <tt><font color = "SaddleBrown"> tz</font></tt>  (optional, string)
     By default, `tz = "GMT"`. Specify time zone, when timestamps are strings formatted as described in the <tt><font color = "SaddleBrown">time\_format</font></tt>  argument. For example, `tz = "Australia/Darwin"`. View the "TZ" column of [the time zones table](http://en.wikipedia.org/wiki/Zone.tab) for a list of possible values.

-   <tt><font color = "SaddleBrown"> metric\_col</font></tt>  (required, numeric or character vector)
     Specifies numbers or names of the columns where metric values are stored. For example, `metric_col = c(2, 3, 4)`, or `metric_col = c("Value", "Avg")`. If <tt><font color = "SaddleBrown">metric\_name</font></tt>  argument is not given, then names of columns, in lower case, are used as metric names when saving them in ATSD.

-   <tt><font color = "SaddleBrown">metric\_name</font></tt>  (optional, character vector)
     Specifies names of metrics. The series pointed by <tt><font color = "SaddleBrown">metric\_col</font></tt>  argument are saved in ATSD along with metric names, provided by the <tt><font color = "SaddleBrown">metric\_name</font></tt> . So the number and order of names in the <tt><font color = "SaddleBrown">metric\_name</font></tt>  should match to columns in \<tt\><font color = "SaddleBrown">metric\_col</font></tt> . If <tt><font color = "SaddleBrown">metric\_name</font></tt>  argument is not provided, then names of columns, in lower case, are used as metric names when saving them in ATSD.

-   <tt><font color = "SaddleBrown"> entity\_col</font></tt>  (optional, numeric or character)
     Optional argument, should be provided if the entity argument is not given. Number or name of a column with entities. Several entities in the column are allowed. For example, `entity_col = 4`, or `entity_col = "server001"`.

-   <tt><font color = "SaddleBrown"> entity</font></tt>  (optional, character)
     Should be provided if the <tt><font color = "SaddleBrown">entity\_col</font></tt>  argument is not given. Name of the entity.

-   <tt><font color = "SaddleBrown"> tags\_col</font></tt>  (optional, numeric or character vector)
     Lists numbers or names of the columns containing values of tags. So the name of a column is a tag name, and values in the column are the tag values.

-   <tt><font color = "SaddleBrown"> tags</font></tt>  (optional, character vector)
     Lists tags and their values in "tag=value" format. Each indicated tag will be saved with each series. Witespace symbols are ignored.

-   <tt><font color = "SaddleBrown">verbose</font></tt>  (optional, string)
    If <tt>verbose = FALSE</tt>,  then all console output will be suppressed.

**Time stamps format.**

The list of allowed timestamp types.

-   Numeric, in epoch milliseconds or epoch seconds. In that case `time_format = "ms"` or `time_format = "sec"` should be used, and time zone argument <tt><font color = "SaddleBrown">tz</font></tt>  is ignored.

-   Object of one of type `Date`, `POSIXct`, `POSIXlt`, `chron` from the `chron` package or `timeDate` from the `timeDate` package. In that case arguments <tt><font color = "SaddleBrown">time\_format</font></tt>  and <tt><font color = "SaddleBrown">tz</font></tt>  are ignored.

-   String, for example, "2015-01-03 10:07:15". In that case <tt><font color = "SaddleBrown">time\_format</font></tt>  argument should specify which format string is used for the timestamps. For example, `time_format = "\%Y-\%m-\%d \%H:\%M:\%S"`. Type `?strptime` to see list of format symbols. This format string will be used to convert provided timestamps to epoch milliseconds before storing the timestamps in ATSD. So time zone, as written in <tt><font color = "SaddleBrown">tz</font></tt>  argument, and standard origin "1970-01-01 00:00:00" are used for conversion. In fact conversion is done with use of command: `as.POSIXct(time_stamp, format = time_format, origin="1970-01-01", tz = tz)`.

Note that timestamps will be stored in epoch milliseconds. So if you put some data into ATSD and then retrieve it back, the timestamps will refer to the same time but in GMT time zone. For example, if you save time stamp `"2015-02-15 10:00:00"` with `tz = "Australia/Darwin"` in ATSD, and then retrieve it back, you will get the timestamp `"2015-02-15 00:30:00"` because Australia/Darwin time zone has +09:30 shift relative to the GMT zone.

**Entity specification**

You can provide entity name in one of <tt><font color = "SaddleBrown">entity</font></tt>  or <tt><font color = "SaddleBrown">entity\_col</font></tt>  arguments. In the first case all series will have the same entity. In the second case, entities specified in <tt><font color = "SaddleBrown">entity\_col</font></tt>  column will be saved along with corresponding series.

**Tags specification**

The <tt><font color = "SaddleBrown">tags\_col</font></tt>  argument points which columns of the data frame keep tags of time-series. The name of each column specified by the <tt><font color = "SaddleBrown">tags\_col</font></tt>  argument is a tag name, and the values in the column are tag values.

Before storing the series in ATSD, the data frame will be split into several data frames, each of them has a unique entity and unique list of tag values. This entity and tags are stored in ATSD along with the time-series from the data frame. NA's and missing values in time-series will be ignored.

In <tt><font color = "SaddleBrown">tags</font></tt>  argument you can specify tags which are the same for all rows (records) of the data frame. So each series value saved in ATSD will have tags, provided in the <tt><font color = "SaddleBrown">tags</font></tt>  argument.

**Examples:**

``` r
# Save time-series from columns 3, 4, 5 of data frame dfr.
# Timestamps are saved as strings in 2nd column and their format string and time zone are provided.
# Entities and tags are in columns 1, 6, 7.
# All saved series will have tag "os_type" with value "linux".
save_series(dfr, time_col = 2, time_format = "%Y/%m/%d %H:%M:%S", tz = "Australia/Darwin", 
            metric_col = c(3, 4, 5), entity_col = 1, tags_col = c(6, 7), tags = "os_type = linux")
```

[Return to Contents](#contents)

9. <a name = "expression"></a> Expression Syntax
------------------------------------------------

In this section, we explain the syntax of the <tt><font color = "SaddleBrown">expression</font></tt>  argument of the functions `get_metrics()`   and `get_entities()`. The <tt><font color = "SaddleBrown">expression</font></tt>  is used to filter result for which <tt><font color = "SaddleBrown">expression</font></tt>  evaluates to `TRUE` .

The variable `name` is used to select metrics/entities by names:

``` r
# get metric with name 'cpu_busy'
metrics <- get_metrics(expression = "name = 'cpu_busy'", verbose = FALSE)
```

``` r
pandoc.table(metrics, style = "grid")
#> 
#> 
#> +----------+-----------+---------------------+---------------+--------------+
#> |   name   |  counter  |   lastInsertTime    |  tags.source  |  tags.table  |
#> +==========+===========+=====================+===============+==============+
#> | cpu_busy |   FALSE   | 2015-04-08 10:17:34 |    iostat     |    System    |
#> +----------+-----------+---------------------+---------------+--------------+
```

Metrics and entities have user-defined tags. Each of these tags is a pair ("tag\_name" : "tag\_value"). The variable `tags.tag_name`  in an expression refers to the `tag_value` for given metric/entity. If a metric/entity does not have this tag, the `tag_value` will be an empty string.

``` r
# get metrics without 'source' tag, and include all tags of fetched metrics in output
get_metrics(expression = "tags.source != ''", tags = "*")
```

To get metrics with a user-defined tag 'table' equal to 'System':

``` r
# get metrics whose tag 'table' is equal to 'System'
metrics <- get_metrics(expression = "tags.table = 'System'", tags = "*")
#> Your request was successfully processed by server. Start parsing and filtering.
#> Parsing and filtering done. Start converting to data frame.
#> Converting to data frame done.
```

``` r
# look head of fetched metrics with the pander package
pandoc.table(head(metrics, 2), style = "grid")
#> 
#> 
#> +----------+-----------+---------------------+---------------+--------------+
#> |   name   |  counter  |   lastInsertTime    |  tags.source  |  tags.table  |
#> +==========+===========+=====================+===============+==============+
#> | cpu_busy |   FALSE   | 2015-04-08 10:17:34 |    iostat     |    System    |
#> +----------+-----------+---------------------+---------------+--------------+
#> | cpu_idle |   FALSE   | 2015-04-08 10:17:34 |      NA       |    System    |
#> +----------+-----------+---------------------+---------------+--------------+
```

<!---
So in the expression, you could use the variable `name`&nbsp; whose value is the name
of the metric/entity, variables whose names are names of the user defined tags,
and values are values of these tags.
-->
To build more complex expressions, use brackets `(`, `)`, and `and`, `or`, `not`  logical operators as well as `&&` , `||`, `!`.

``` r
entities <- get_entities(expression = "tags.app != '' and (tags.os != '' or tags.ip != '')")
#> Your request was successfully processed by server. Start parsing and filtering.
#> Parsing and filtering done. Start converting to data frame.
#> Converting to data frame done.
```

``` r
# look at head of fetched entities with the pander package
pandoc.table(head(entities, 3), style = "grid")
#> 
#> 
#> +--------------+-----------+---------------------+---------------------------+------------+
#> |     name     |  enabled  |   lastInsertTime    |         tags.app          |  tags.ip   |
#> +==============+===========+=====================+===========================+============+
#> | nurswgvml003 |   TRUE    | 2015-04-08 10:17:29 | Shared NFS/CIFS disk, ntp | 10.102.0.2 |
#> |              |           |                     |          server           |            |
#> +--------------+-----------+---------------------+---------------------------+------------+
#> | nurswgvml006 |   TRUE    | 2015-04-08 10:17:29 |       Hadoop/HBASE        | 10.102.0.5 |
#> +--------------+-----------+---------------------+---------------------------+------------+
#> | nurswgvml007 |   TRUE    | 2015-04-08 10:17:31 |           ATSD            | 10.102.0.6 |
#> +--------------+-----------+---------------------+---------------------------+------------+
#> 
#> Table: Table continues below
#> 
#>  
#> 
#> +-----------+-----------------+-----------------+
#> |  tags.os  |  tags.loc_area  |  tags.loc_code  |
#> +===========+=================+=================+
#> |   Linux   |       NA        |       NA        |
#> +-----------+-----------------+-----------------+
#> |   Linux   |       NA        |       NA        |
#> +-----------+-----------------+-----------------+
#> |   Linux   |       dc2       |       nur       |
#> +-----------+-----------------+-----------------+
```

To test if a string is in a collections, use `in`  operator:

``` r
get_entities(expression = "name in ('derby-test', 'atom.axibase.com')")
```

Use `like`  operator to match values with expressions containing wildcards: `expression = "name like 'disk*'"` . The wildcard `*`  mean zero or more characters. The wildcard `.`  means any one character.

``` r
metrics <- get_metrics(expression = "name like '*cpu*' and tags.table = 'System'")
```

``` r
# get metrics with names consisting of 3 letters
metrics <- get_metrics(expression = "name like '...'")
```

``` r
# print names of fetched metrics
print(metrics$name)
#> [1] "ask" "bid" "jmx"
```

There are additional functions you can use in an expression:

-   `list(string, delimeter))`  Splits the string by delimeter. The default delimiter is a comma.

-   `upper(string)`  Converts the string argument to upper case.

-   `lower(string)`  Converts the string argument to lower case.

-   `collection(name)`  Refers to a named collection of strings created in ATSD.

-   `likeAll(string, collection of patterns)`  Returns true if every element in the collection of patterns matches the given string.

-   `likeAny(string, collection of patterns)`  Returns true if at least one element in the collection of patterns matches the given string.

``` r
get_metrics(expression = "likeAll(lower(name), list('cpu*,*use*'))")
get_metrics(expression = "likeAny(lower(name), list('cpu*,*use*'))")
get_metrics(expression = "name in collection('fs_ignore')")
```

[Return to Contents](#contents)

10. <a name = "advanced"></a> Advanced Connection Options
---------------------------------------------------------

The atsd package uses connection parameters to connect with ATSD. These parameters are:

-   <tt><font color = "SaddleBrown">url</font></tt>  - the url of ATSD including port number

-   <tt><font color = "SaddleBrown">user</font></tt>  - the user name

-   <tt><font color = "SaddleBrown">password</font></tt>  - the user's password

-   <tt><font color = "SaddleBrown">verify</font></tt>  - should ATSD SSL certificate be validated

-   <tt><font color = "SaddleBrown">encryption</font></tt>  - cryptographic protocol used by ATSD https server

The configuration parameters are loaded from the package configuration file when you load the atsd package into R. (See Section 2.)

The functions `show_connection()`,  `set_connection()`,  and `save_connection()`,  show configuration parameters, change them, and store them in the configuration file.

<br> <a name = "show_connection"></a> **Function name:** show\_connection()

**Returns object:** NULL

**Description:** The function prints current values of the connection parameters. (They may be different from the values in the configuration file.)

**Arguments:** no

**Examples:**

``` r
show_connection()
#> url = NA
#> user = NA
#> password = NA
#> verify = no
#> encryption = ssl3
```

<br> <a name = "set_connection"></a> **Function name:** set\_connection()

**Returns object:** NULL

**Description:** The function overrides the connection parameters for the duration of the current R session without changing the configuration file. If called without arguments the function sets the connection parameters from the configuration file. If the <tt><font color = "SaddleBrown">file</font></tt>  argument is provided the function use it. In both cases the current values of the parameters became the same as in the file. In case the <tt><font color = "SaddleBrown">file</font></tt>  argument is not provided, but some of other arguments are specified, the only specified parameters will be changed.

**Arguments:**

-   <tt><font color = "SaddleBrown"> url </font></tt>  (optional, string)
     The url of ATSD including port number.

-   <tt><font color = "SaddleBrown"> user </font></tt>  (optional, string)
     The user name.

-   <tt><font color = "SaddleBrown"> password </font></tt>  (optional, string)
     The user's password.

-   <tt><font color = "SaddleBrown"> verify </font></tt>  (optional, string)
     String - "yes" or "no", `verify = "yes"`  ensures validation of ATSD SSL certificate and `verify = "no"`  suppresses the validation (applicable in the case of 'https' protocol).

-   <tt><font color = "SaddleBrown"> encryption </font></tt>  (optional, string)
     Cryptographic protocol used by ATSD https server. Possible values are: "default", "ssl2", "ssl3", and "tls1" (In most cases, use "ssl3" or "tls1".)

-   <tt><font color = "SaddleBrown"> file</font></tt>  (optional, string)
     The absolute path to the file from which the connection parameters could be read. The file should be formatted as the package configuration file, see Section 2.

**Examples:**

``` r
# Modify the user 
set_connection(user = "user001")
```

``` r
# Modify the cryptographic protocol 
set_connection(encryption = "tls1")
```

``` r
show_connection()
#> url = NA
#> user = user001
#> password = NA
#> verify = no
#> encryption = tls1
```

``` r
# Set the parameters of the https connection: url, user name, password 
# should the certificate of the server be verifyed 
# which cryptographic protocol is used for communication
set_connection(url = "https://my.company.com:8443", user = "user001", password = "123456", 
               verify = "no", encryption = "ssl3")
```

``` r
show_connection()
#> url = https://my.company.com:8443
#> user = user001
#> password = 123456
#> verify = no
#> encryption = ssl3
```

``` r
# Set up the connection parameters from the file:
set_connection(file = "/home/user001/atsd_https_connection.txt")
```

<br> <a name = "save_connection"></a> **Function name:** save\_connection()

**Returns object:** NULL

**Description:** The function writes the connection parameters into the configuration file. If called without arguments the functions use current values of the connection parameters (including NAs). Otherwise only the provided arguments will be written to the configuration file. If configuration file is absent it will be created in the atsd package folder. **Arguments:**

-   <tt><font color = "SaddleBrown"> url </font></tt>  (optional, string)
     The url of ATSD including port number.

-   <tt><font color = "SaddleBrown"> user </font></tt>  (optional, string)
     The user name.

-   <tt><font color = "SaddleBrown"> password </font></tt>  (optional, string)
     The user's password.

-   <tt><font color = "SaddleBrown"> verify </font></tt>  (optional, string)
     String - "yes" or "no", `verify = "yes"`  ensures validation of ATSD SSL certificate and `verify = "no"`  suppresses the validation (applicable in the case of 'https' protocol).

-   <tt><font color = "SaddleBrown"> encryption </font></tt>  (optional, string)
     Cryptographic protocol used by ATSD https server. Possible values are: "default", "ssl2", "ssl3", and "tls1" (In most cases, use "ssl3" or "tls1".)

**Examples:**

``` r
# Write the current values of the connection parameters to the configuration file.
save_connection()
 
# Write the user name and password in the configuration file.
save_connection(user = "user00", password = "123456")
 
# Write all parameters nedeed for the https connection to the configuration file.
save_connection(url = "https://my.company.com:8443", user = "user001", password = "123456", 
               verify = "no", encryption = "ssl3")
```

[Return to Contents](#contents)
