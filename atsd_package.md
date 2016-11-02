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

The package allows you query time-series data and statistics from the [Axibase Time Series Database](http://axibase.com/axibase-time-series-database/) (ATSD) and save time-series data in ATSD. Below is a list of package functions:

-   [set\_connection()](#set_connection), [save\_connection()](#save_connection), [show\_connection()](#show_connection) - used to manage the connection with ATSD. Set up and store the url, user name, and password. Configure cryptographic protocol and enforce SSL certificate validation in the case of https connection.
-   [query()](#query) - get historical data and forecasts from ATSD.
-   [get\_metrics()](#get_metrics) - get metadata about the metrics collected by ATSD.
-   [get\_entities()](#get_entities) - get metadata about the entities collected by ATSD.
-   [get\_series\_tags()](#get_series_tags) - get unique series tags for the metric.
-   [save\_series()](#save_series) - save time series into ATSD.
-   [to\_zoo()](#to_zoo) - converts a time-series data frame to a 'zoo' object for manipulating irregular time-series with built-in functions in zoo package.

[Return to Table of Contents](#contents).

2. <a name = "connecting"></a> Connecting to ATSD
-------------------------------------------------

Execute `library(atsd)` to start working with the atsd package. The connection parameters are loaded from the package configuration file, <tt><font color = "SaddleBrown">atsd/connection.config</font></tt>, which is located in the atsd package folder.

``` r
installed.packages()["atsd", "LibPath"]
```

The command shows you where the atsd package folder is. Open a text editor and modify the configuration file. It should look as follows:

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

[Return to Table of Contents](#contents).

3. <a name = "querying"></a>Querying ATSD
-----------------------------------------

<a name = "query"></a> **Function name:** `query()`

**Description:** The function retrieves historical time-series data or forecasts from ATSD.

**Returns object:** data frame 

**Arguments:**

-   <tt><font color = "SaddleBrown">metric</font></tt> (required, string):
    name of the metric you want to get data for. For example, `disk_used_percent`.
    To obtain a list of metrics collected by ATSD, use the `get_metrics()` function, which can be found [here](#get_metrics).

-   <tt><font color = "SaddleBrown">selection_interval</font></tt> (required, string):
     time interval for which the data will be selected. Specify it as "n-unit", where
     "unit" is a Second, Minute, Hour, Day, Week, Month, Quarter, or Year, and "n" is the number of units. For example, "3-Week" or "12-Hour".

-   <tt><font color = "SaddleBrown">entity</font></tt> (optional, string):
    name of the entity you want to get data for. If not provided, then data for all entities will be fetched for the specified metric. Obtain the list of entities with the `get_entities()`, which can be found [here](#get_entities).

-   <tt><font color = "SaddleBrown">entity_group</font></tt> (optional, string):
    name of entity group. For example, "HP Servers". Extracts data for all entities belonging to this group.

-   <tt><font color = "SaddleBrown">tags</font></tt> (optional, string vector):
    list of user-defined series tags to filter the fetched time-series data. For example, <tt>c("disk_name=sda1", "mount_point=/")</font></tt>.

-   <tt><font color = "SaddleBrown">end_time</font></tt> (optional, string):
    end time of the selection interval. For example, `end_time = "date('2014-12-27')"`. If not provided, the current time will be used. Specify the date and time, or use one of the supported [end time syntax](http://axibase.com/products/axibase-time-series-database/visualization/end-time/) expressions. For example, `current_day` would set the end of selection interval to 00:00:00 of the current day.

-   <tt><font color = "SaddleBrown">aggregate_interval</font></tt> (optional, string):
    length of the aggregation interval. The period of produced time-series will be equal to <tt><font color = "SaddleBrown">aggregate_interval</font></tt>.  The value for each period is computed by the <tt><font color = "SaddleBrown">aggregate_statistics</font></tt>  function applied to all samples of the original time-series within the period. The format of <tt><font color = "SaddleBrown">aggregate_interval</font></tt>  is the same as for the <tt><font color = "SaddleBrown">selection_interval</font></tt>  argument (for example, "1-Minute").

-   <tt><font color = "SaddleBrown">aggregate_statistics</font></tt> (optional, string vector):
    statistic functions used for aggregation. Multiple values are supported. For example, `c("Min", "Avg", "StDev")`. The default value is "Avg".

-   <tt><font color = "SaddleBrown">interpolation</font></tt> (optional, string):
    if aggregation is enabled, then the values for the periods without data will be computed by one of the following interpolation functions: "None", "Linear", "Step". The default value is "None".

-   <tt><font color = "SaddleBrown">export_type</font></tt> (optional, string):
     supported options: "History" or "Forecast". The default value is "History".

-   <tt><font color = "SaddleBrown">verbose</font></tt> (optional, string):
    if <tt>verbose = FALSE</tt>,  then all console output will be suppressed. By default, <tt>verbose = TRUE</tt>.

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

[Return to Table of Contents](#contents).

4. <a name = "zoo"></a>Transforming Data Frame to a `zoo` Object
--------------------------------------------------------------

<a name = "to_zoo"></a> **Function name:** `to_zoo()`

**Description:** the function builds a zoo object from the given data frame. The <tt><font color = "SaddleBrown">timestamp</font></tt>  argument provides a column of the data frame which is used as the index for the zoo object. The <tt><font color = "SaddleBrown">value</font></tt>  argument indicates the series which will be saved in a zoo object. If several columns are listed in the <tt><font color = "SaddleBrown">value</font></tt>  argument, they will all be saved in a multivariate zoo object. Information from other columns is ignored. To use this function the 'zoo' package should be installed.

**Returns object:** [zoo](http://cran.r-project.org/web/packages/zoo/index.html) object

**Arguments:**

-   <tt><font color = "SaddleBrown">dfr</font></tt> (required, data frame):
     the data frame.

-   <tt><font color = "SaddleBrown">timestamp</font></tt> (optional, character or numeric vector):
     name or number of the column with timestamps. By default, `timestamp = "Timestamp"`.

-   <tt><font color = "SaddleBrown">value</font></tt> (optional, character or numeric vector):
     names or numbers of columns with series values. By default, `value = "Value"`.

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

[Return to Table of Contents](#contents).

5. <a name = "metrics"></a>Getting Metrics
------------------------------------------

<a name = "get_metrics"></a> **Function name:** `get_metrics()`

**Description:** This function fetches a list of metrics and their tags from ATSD, and converts it to a data frame.

**Returns object:** data frame

Each row of the data frame corresponds to a metric and its tags:

-   <tt><font color = "DarkGreen">name</font></tt>:
     metric name (unique)

-   <tt><font color = "DarkGreen">counter</font></tt>:
     counters are metrics with continuously incrementing values.

-   <tt><font color = "DarkGreen">lastInsertTime</font></tt>:
     last time the value was received by ATSD for this metric.

-   <tt><font color = "DarkGreen">tags</font></tt>:
     user-defined tags (as requested by the `tags` argument).

**Arguments:**

-   <tt><font color = "SaddleBrown">expression</font></tt> (optional, string):
    select metrics matching particular name pattern and/or user-defined metric tags. For examples, refer to [Expression syntax](https://github.com/axibase/atsd-api-r/blob/master/atsd_package.md#expression) chapter.

-   <tt><font color = "SaddleBrown">active</font></tt> (optional, one of strings: "true" or "false"):
    filter metrics by the <tt>lastInsertTime</tt>  attribute. If <tt>active = "true"</tt>,  only metrics with positive <tt>lastInsertTime</tt>  are included in the response.

-   <tt><font color = "SaddleBrown">tags</font></tt> (optional, string vector):
    user-defined metric tags to be included in the response. By default, all the tags will be included.

-   <tt><font color = "SaddleBrown">limit</font></tt> (optional, integer):
    if limit > 0, the response shows the top-N metrics ordered by name.

-   <tt><font color = "SaddleBrown">verbose</font></tt> (optional, string):
    if <tt>verbose = FALSE</tt>, then all console output will be suppressed.

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

[Return to to Table of Contents](#contents).

6. <a name = "entities"></a>Getting Entities
--------------------------------------------

<a name = "get_entities"></a> **Function name:** `get_entities()`

**Description:** This function fetches a list of entities and their tags from ATSD, and converts it to a data frame.

**Returns object:** data frame

Each row of the data frame corresponds to an entity and its tags:

-   <tt><font color = "DarkGreen">name</font></tt>:
     entity name (unique).

-   <tt><font color = "DarkGreen">enabled</font></tt>:
     enabled status, incoming data is discarded for disabled entities.

-   <tt><font color = "DarkGreen">lastInsertTime</font></tt>:
     last time a value was received by ATSD for this entity.

-   <tt><font color = "DarkGreen">tags</font></tt>:
     user-defined tags (as requested by the "tags" argument).

**Arguments:**

-   <tt><font color = "SaddleBrown">expression</font></tt> (optional, string):
    select entities matching particular name pattern and/or user-defined entity tags. For examples refer to [Expression syntax](https://github.com/axibase/atsd-api-r/blob/master/atsd_package.md#expression) chapter.

-   <tt><font color = "SaddleBrown"> active</font></tt> (optional, one of strings: "true" or "false"):
    filter entities by the <tt>lastInsertTime</tt> attribute. If <tt>active = "true"</tt>,  only entities with positive <tt>lastInsertTime</tt>  are included in the response.

-   <tt><font color = "SaddleBrown">tags</font></tt> (optional, string vector):
    user-defined entity tags to be included in the response. By default, all the tags will be included.

-   <tt><font color = "SaddleBrown">limit</font></tt> (optional, integer):
    if limit > 0, the response shows the top-N entities ordered by name.

-   <tt><font color = "SaddleBrown">verbose</font></tt> (optional, string):
    if <tt>verbose = FALSE</tt>, then all of the console outputs will be suppressed.

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

[Return to Table of Contents](#contents).

7. <a name = "gtst"></a> Getting Time Series Tags
-------------------------------------------------

<a name = "get_series_tags"></a> **Function name:** `get_series_tags()`

**Description:** The function determines the time series collected by ATSD for a given metric. For each time series, `get_series_tags()` lists tags associated with the series, and the last time the series was updated. The list of fetched time series is based on data stored on disk for the last 24 hours.

**Returns object:** data frame

Each row of the data frame corresponds to a time series and its tags:

-   <tt><font color = "DarkGreen">entity</font></tt>:
     name of the entity which generate the time series.

-   <tt><font color = "DarkGreen">lastInsertTime</font></tt>:
     last time a value was received by ATSD for this time series.

-   <tt><font color = "DarkGreen">tags</font></tt>:
     tags of the series.

**Arguments:**

-   <tt><font color = "SaddleBrown">metric</font></tt> (required, string):
    the name of the metric you want to get a time series for. For example, `disk_used_percent`.
    To obtain a list of metrics collected by ATSD, use the `get_metrics()` function, which can be found [here](#get_metrics).

-   <tt><font color = "SaddleBrown">entity</font></tt> (optional, string):
    the name of the entity you want to get time series for. If not provided, then data for all entities will be fetched for the specified metric. Obtain the list of entities with the `get_entities()` function, which can be found [here](#get_entities).

-   <tt><font color = "SaddleBrown">verbose</font></tt> (optional, string):
    if <tt>verbose = FALSE</tt>,  then all of the console outputs will be suppressed.

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

[Return to Table of Contents](#contents).

8. <a name = "saving_ts"></a> Saving Time-Series in ATSD
--------------------------------------------------------

<a name = "save_series"></a> **Function name:** `save_series()`

**Description:** save time-series from the data frame into ATSD. The data frame should have a column with timestamps and at least one numeric column with values of a metric.

**Returns object:** NULL

**Arguments:**

-   <tt><font color = "SaddleBrown">dfr</font></tt> (required, data frame):
     the data frame should have a column with timestamps and at least one numeric column with values of a metric.

-   <tt><font color = "SaddleBrown">time_col</font></tt> (optional, numeric or character):
     number or name of the column with the timestamps. Default value is 1. For example, <tt><font color = "SaddleBrown">time_col = 1</font></tt>,  or <tt><font color = "SaddleBrown">time_col = "Timestamp"</font></tt>.  Read the "Timestamps format" section directly below for supported timestamp classes and formats.

-   <tt><font color = "SaddleBrown">time_format</font></tt> (optional, string):
     optional string argument, indicates format of timestamps. This argument is used in the case when the timestamp format is not clear from their class. The value of this argument can be one of the following: `"ms"` (for epoch milliseconds), `"sec"` (for epoch seconds), or a format string, for example `"\%Y-\%m-\%d \%H:\%M:\%S"`. This format string will be used to convert the provided timestamps to epoch milliseconds before storing the timestamps in ATSD. Read "Timestamp format" section for more details.

-   <tt><font color = "SaddleBrown">tz</font></tt> (optional, string):
     by default, `tz = "GMT"`. Specify the time zone when timestamps are strings formatted as described in the <tt><font color = "SaddleBrown">time_format</font></tt> argument. For example, `tz = "Australia/Darwin"`. View the "TZ" column of [the time zones table](http://en.wikipedia.org/wiki/Zone.tab) for a list of possible values.

-   <tt><font color = "SaddleBrown">metric_col</font></tt> (required, numeric or character vector):
     specifies numbers or names of the columns where metric values are stored. For example, `metric_col = c(2, 3, 4)`, or `metric_col = c("Value", "Avg")`. If the <tt><font color = "SaddleBrown">metric_name</font></tt>  argument is not given, then names of columns, in lower case, are used as metric names when saving them in ATSD.

-   <tt><font color = "SaddleBrown">metric_name</font></tt> (optional, character vector):
     specifies metric names. The series indicated by the <tt><font color = "SaddleBrown">metric_col</font></tt>  argument are saved in ATSD along with the metric names, provided by the <tt><font color = "SaddleBrown">metric_name</font></tt>. The number and order of names in the <tt><font color = "SaddleBrown">metric_name</font></tt>  should match to columns in <tt><font color = "SaddleBrown">metric_col</font></tt>. If the <tt><font color = "SaddleBrown">metric_name</font></tt>  argument is not provided, then names of the columns, in lower case, are used as metric names when saving them in ATSD.

-   <tt><font color = "SaddleBrown">entity_col</font></tt> (optional, numeric or character):
     optional argument, should be provided if the entity argument is not given. Number or name of a column with entities. Several entities in the column are allowed. For example, `entity_col = 4` or `entity_col = "server001"`.

-   <tt><font color = "SaddleBrown">entity</font></tt> (optional, character):
     should be provided if the <tt><font color = "SaddleBrown">entity_col</font></tt>  argument is not given. Name of the entity.

-   <tt><font color = "SaddleBrown">tags_col</font></tt> (optional, numeric or character vector):
     lists numbers or names of the columns containing tag values. So the name of a column is a tag name, and values in the column are the tag values.

-   <tt><font color = "SaddleBrown">tags</font></tt> (optional, character vector):
     lists tags and their values in "tag=value" format. Each indicated tag will be saved with each series. Whitespace symbols are ignored.

-   <tt><font color = "SaddleBrown">verbose</font></tt> (optional, string):
    if <tt>verbose = FALSE</tt>, then all console outputs will be suppressed.

**Timestamp format.**

Below is the list of allowed timestamp types:

-   Numeric, in epoch milliseconds or epoch seconds. In this case `time_format = "ms"` or `time_format = "sec"` should be used, and the time zone argument <tt><font color = "SaddleBrown">tz</font></tt>  is ignored.

-   Object of one of the following types: `Date`, `POSIXct`, `POSIXlt`, `chron` from the `chron` package or `timeDate` from the `timeDate` package. In this case, the arguments <tt><font color = "SaddleBrown">time_format</font></tt>  and <tt><font color = "SaddleBrown">tz</font></tt>  are ignored.

-   String. For example, `"2015-01-03 10:07:15"`. In this case, the <tt><font color = "SaddleBrown">time_format</font></tt>  argument should specify which format string is used for the timestamps. For example, `time_format = "\%Y-\%m-\%d \%H:\%M:\%S"`. Enter `?strptime` to see a list of format symbols. This format string will be used to convert provided timestamps to epoch milliseconds before storing the timestamps in ATSD. Time zone, as written in the <tt><font color = "SaddleBrown">tz</font></tt> argument, and standard origin `"1970-01-01 00:00:00"` are used for the conversion. In fact, the conversion is done with use of the command: `as.POSIXct(time_stamp, format = time_format, origin="1970-01-01", tz = tz)`.

Note that timestamps will be stored in epoch milliseconds. If you enter data into ATSD and then retrieve it back, the timestamps will refer to the same time but in GMT time zone. For example, if you save the timestamp `"2015-02-15 10:00:00"` with `tz = "Australia/Darwin"` in ATSD, and then retrieve it back, you will get the timestamp `"2015-02-15 00:30:00"` because Australia/Darwin time zone has a +09:30 shift relative to the GMT zone.

**Entity specification**

You can provide an entity name in one of the <tt><font color = "SaddleBrown">entity</font></tt>  or <tt><font color = "SaddleBrown">entity_col</font></tt>  arguments. In the first case, all series will have the same entity. In the second case, entities specified in the <tt><font color = "SaddleBrown">entity_col</font></tt>  column will be saved along with their corresponding series.

**Tags specification**

The <tt><font color = "SaddleBrown">tags_col</font></tt>  argument indicates which columns of the data frame keeps the time-series tags. The name of each column specified by the <tt><font color = "SaddleBrown">tags_col</font></tt>  argument is a tag name, and the values in the column are tag values.

Before storing the series in ATSD, the data frame will be split into several data frames, each of them having a unique entity and unique list of tag values. This entity and tags are stored in ATSD along with the time-series from the data frame. NA's and missing values in the time-series will be ignored.

In the <tt><font color = "SaddleBrown">tags</font></tt> argument you can specify tags, which are the same for all rows (records) of the data frame. Each series value saved in ATSD will have tags provided in the <tt><font color = "SaddleBrown">tags</font></tt>  argument.

**Examples:**

``` r
# Save time-series from columns 3, 4, 5 of data frame dfr.
# Timestamps are saved as strings in 2nd column and their format string and time zone are provided.
# Entities and tags are in columns 1, 6, 7.
# All saved series will have tag "os_type" with value "linux".
save_series(dfr, time_col = 2, time_format = "%Y/%m/%d %H:%M:%S", tz = "Australia/Darwin", 
            metric_col = c(3, 4, 5), entity_col = 1, tags_col = c(6, 7), tags = "os_type = linux")
```

[Return to Table of Contents](#contents)

9. <a name = "expression"></a> Expression Syntax
------------------------------------------------

In this section, we explain the syntax of the <tt><font color = "SaddleBrown">expression</font></tt>  argument of the functions `get_metrics()` and `get_entities()`. The <tt><font color = "SaddleBrown">expression</font></tt>  is used to filter results, for which <tt><font color = "SaddleBrown">expression</font></tt>  evaluates to `TRUE` .

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

Metrics and entities have user-defined tags. Each of these tags is a pair ("tag_name" : "tag_value"). The variable `tags.tag_name` in an expression refers to the `tag_value` for the given metric/entity. If a metric/entity does not have this tag, the `tag_value` will be an empty string.

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

To test if a string is in a collections, use the `in` operator:

``` r
get_entities(expression = "name in ('derby-test', 'atom.axibase.com')")
```

Use the `like` operator to match values with expressions containing wildcards: `expression = "name like 'disk*'"`. The wildcard `*` mean zero or more characters. The wildcard `.` means any one character.

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

-   `list(string, delimeter))`: splits the string by delimeter. The default delimiter is a comma.

-   `upper(string)`: converts the string argument to upper case.

-   `lower(string)`: converts the string argument to lower case.

-   `collection(name)`: refers to a named collection of strings created in ATSD.

-   `likeAll(string, collection of patterns)`: returns true if every element in the collection of patterns matches the given string.

-   `likeAny(string, collection of patterns)`: returns true if at least one element in the collection of patterns matches the given string.

``` r
get_metrics(expression = "likeAll(lower(name), list('cpu*,*use*'))")
get_metrics(expression = "likeAny(lower(name), list('cpu*,*use*'))")
get_metrics(expression = "name in collection('fs_ignore')")
```

[Return to Table of Contents](#contents).

10. <a name = "advanced"></a> Advanced Connection Options
---------------------------------------------------------

The atsd package uses connection parameters to connect with ATSD. These parameters are:

-   <tt><font color = "SaddleBrown">url</font></tt>  - the url of ATSD including port number.

-   <tt><font color = "SaddleBrown">user</font></tt>  - the user name.

-   <tt><font color = "SaddleBrown">password</font></tt>  - the user's password.

-   <tt><font color = "SaddleBrown">verify</font></tt>  - should ATSD SSL certificate need be validated.

-   <tt><font color = "SaddleBrown">encryption</font></tt>  - cryptographic protocol used by the ATSD https server.

The configuration parameters are loaded from the package configuration file when you load the atsd package into R (See Section 2).

The functions `show_connection()`,  `set_connection()`,  and `save_connection()` show configuration parameters, change them, and store them in the configuration file.

<a name = "show_connection"></a> **Function name:** `show_connection()`

**Returns object:** NULL

**Description:** the function prints current values of the connection parameters. They may be different from the values in the configuration file.

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

<br> <a name = "set_connection"></a> **Function name:** `set_connection()`

**Returns object:** NULL

**Description:** The function overrides the connection parameters for the duration of the current R session without changing the configuration file. If called without arguments, the function sets the connection parameters from the configuration file. If the <tt><font color = "SaddleBrown">file</font></tt>  argument is provided, the function will use it. In both cases the current values of the parameters became the same as in the file. In case the <tt><font color = "SaddleBrown">file</font></tt>  argument is not provided, but some of other arguments are specified, only the specified parameters will be changed.

**Arguments:**

-   <tt><font color = "SaddleBrown">url</font></tt> (optional, string):
     the url of ATSD including port number.

-   <tt><font color = "SaddleBrown">user</font></tt> (optional, string):
     the user name.

-   <tt><font color = "SaddleBrown">password</font></tt> (optional, string):
     the user's password.

-   <tt><font color = "SaddleBrown">verify</font></tt> (optional, string):
     string - "yes" or "no". `verify = "yes"`  ensures validation of the ATSD SSL certificate and `verify = "no"`  suppresses the validation (applicable in the case of 'https' protocol).

-   <tt><font color = "SaddleBrown">encryption</font></tt> (optional, string):
     cryptographic protocol used by the ATSD https server. Possible values are: "default", "ssl2", "ssl3", and "tls1" (in most cases, use "ssl3" or "tls1".)

-   <tt><font color = "SaddleBrown">file</font></tt> (optional, string):
     the absolute path to the file from which the connection parameters could be read. The file should be formatted as the package configuration file (see Section 2 for more information).

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

<br> <a name = "save_connection"></a> **Function name:** `save_connection()`

**Returns object:** NULL

**Description:** The function writes the connection parameters into the configuration file. If called without arguments, the functions will use the current values of the connection parameters (including NAs). Otherwise, only the provided arguments will be written to the configuration file. If the configuration file is absent, it will be created in the atsd package folder. **Arguments:**

-   <tt><font color = "SaddleBrown">url</font></tt> (optional, string):
     the url of ATSD including port number.

-   <tt><font color = "SaddleBrown">user</font></tt> (optional, string):
     the user name.

-   <tt><font color = "SaddleBrown">password</font></tt> (optional, string):
     the user's password.

-   <tt><font color = "SaddleBrown">verify</font></tt> (optional, string):
     string - "yes" or "no". `verify = "yes"` ensures validation of ATSD SSL certificate and `verify = "no"`  suppresses the validation (applicable in the case of 'https' protocol).

-   <tt><font color = "SaddleBrown">encryption</font></tt> (optional, string):
     cryptographic protocol used by the ATSD https server. Possible values are: "default", "ssl2", "ssl3", and "tls1" (in most cases, use "ssl3" or "tls1".)

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

[Return to Table of Contents](#contents).
