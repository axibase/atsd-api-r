# ATSD R Package Documentation

![](./images/axibase-and-r.png)

## Table of Contents

* [Overview](#overview)
* [Connecting to ATSD](#connecting-to-atsd)
* [Functions](#functions)
  * [`to_zoo()`](#to_zoo())
  * [`query()`](#query())
  * [`get_metrics()`](#get_metrics())
  * [`get_entities()`](#get_entities())
  * [`get_series_tags()`](#get_series_tags())
  * [`save_series()`](#save_series())
* [Expression Syntax](#expression-syntax)
* [Configure Connection](#configure-connection)

---

## Overview

**ATSD R Package** enables R developers to communicate with  [Axibase Time Series Database](https://axibase.com/docs/atsd/); a non-relational clustered database for storing performance measurements from IT infrastructure resources such as servers, network devices, storage systems, and applications.

### Connection Functions

Manage ATSD connection. Set up and store ATSD URL, username, and password. Configure cryptographic protocol and enforce SSL certificate validation when using HTTPS connection.

* `set_connection()`
* `save_connection()`
* `show_connection()`

---

## Connecting to ATSD

Begin working with `atsd` package using the `library()` functions:

```r
library(atsd)
```

Retrieve the location of the `atsd` package.

``` r
installed.packages()["atsd", "LibPath"]
```

Open the file in a text editor and modify the configuration file to match the template below:

```r
# ATSD URL and port number
url=http://host_name:port_number

# Username
user=atsd_user_name

# Password
password=atsd_user_password

# Validate ATSD SSL certificate? Possible values: yes, no
verify=no

# ATSD HTTPS Cryptographic protocol server:
# Default, ssl2, ssl3, tls1
encryption=tls1
```

Load modified connection parameters from the configuration file:

```r
set_connection()
```

Confirm connections settings:

```r
show_connection()
```

---

## Functions

### `to_zoo()`

Builds a [`zoo` object](http://cran.r-project.org/web/packages/zoo/index.html) from the given Data Frame.

* `timestamp` provides a column from the Data Frame which is used as the index for the `zoo` object.
* `value` indicates the series saved as a `zoo` object. If several columns are listed by `value`, these columns are saved as a multivariate `zoo` object. Information from other columns is ignored. To use this function the `zoo` package must be installed.

**Arguments**:

Argument | Type | Required | Description
--|--|:--:|--
`dfr` | Data Frame | ![](./images/ok.svg) | Retrieved Data Frame.
`timestamp` | character or numeric vector | | Name or number of the column containing series timestamps.<br>Default value: `timestamp = "Timestamp"`.
`value` | character or numeric vector | | Name or number of one or more columns containing series values.<br>Default value: `value = "Value"`

**Examples**:

``` r
# Query ATSD for data and transform it to zoo object
dfr <- query(entity = "nurswgvml007", metric = "cpu_busy", selection_interval = "1-Hour")
z <- to_zoo(dfr)
```

``` r
# Show head of the zoo object
head(z, 3)
#> 2015-04-08 09:17:24 2015-04-08 09:17:40 2015-04-08 09:17:56 
#>               15.79                9.00               10.10
```

---

### `query()`

Retrieves historical time series data or forecasts from ATSD as a Data Frame object.

**Arguments**:

Argument | Type | Required | Description
--|--|:--:|--
`metric` | string | ![](./images/ok.svg) | Name of retrieved metric.<br>For example: `disk_used_percent`<br>To retrieve a list of available metrics use `get_metrics()` function.
`selection_interval` | string | ![](./images/ok.svg) | Time interval for which data is retrieved.<br>Specify selection interval as `n-unit`.<br>For example: `3-Week`, `12-Hour`.<br>Available units: `Second`, `Minute`, `Hour`, `Day`, `Week`, `Month`, `Quarter`, `Year`.
`entity` | string | | Name of retrieved entity.<br>If no `entity` argument is provided, data for all entities which contain the given metric are retrieved.<br>To retrieve a list of available entities, use `get_entities()` function.
`entity_group` | string | | Name of retrieved [entity group](https://axibase.com/docs/atsd/configuration/entity_groups.html).<br>For example: [`aws-cloudwatch`](https://axibase.com/use-cases/integrations/aws/cloud-watch-alert/)
`tags` | string vector | | Name of one or more [series tags](https://axibase.com/docs/atsd/schema.html#series) fetched for retrieved metrics.<br>For example: `c("disk_name=sda1", "mount_point=/"`)
`end_time` | string | | End time of the selection interval.<br>If omitted, current time is used.<br>Specify both date and time, or use supported [`end_time` syntax](https://axibase.com/products/axibase-time-series-database/visualization/end-time/).<br>For example `end_time = current_day` sets the end of the selection interval to `00:00:00` of the current day.
`aggregate_interval` | string | | Length of aggregation interval.<br>Resulting time series are equal in length to `aggregate_interval`.<br>Value for interval is determined by `aggregate_statistics` function.<br>Express `aggregate_interval` with the same format as `selection_interval`.
`aggregate_statistics`| string vector | | [Statistical function](https://axibase.com/docs/atsd/api/data/aggregation.html) used for aggregation.<br>Multiple values are supported.<br>For example: `c("Min", "Avg", "StDev")`<br>Default value: `Avg`
`interpolation` | string | | [Interpolate](https://axibase.com/docs/atsd/api/data/series/aggregate.html#interpolation-functions) values for empty periods.<br>Supported functions: `"None"`, `"Linear"`, `"Step"`.<br>Default value: `"None"`
`export_type` | string | | Data export format.<br>Supported options: `"History"` and `"Forecast"`.<br>Default value: `"History"`
`verbose` | string:<br>`true` or `false` | | Suppress console output.<br>Default value: `true`.

**Examples**:

```r
# Retrieve historical data for the given entity, metric, and selection_interval
dfr <- query(entity = "nurswgvml007", metric = "cpu_busy", selection_interval = "1-Hour")
```

```r
# Look at head of fetched data frame with the pander package
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

# Get forecasts
query(metric = "cpu_busy", selection_interval = "30-Minute", export_type = "Forecast", verbose = FALSE)

# Use aggregation
query(metric = "disk_used_percent", entity_group = "Linux", tags = c("mount_point=/boot",  
      "file_system=/dev/sda1"), selection_interval = "1-Week", aggregate_interval = "1-Minute",
      aggregate_statistics = c("Avg", "Min", "Max"), interpolation = "Linear", export_type = "Forecast")
```

---

### `get_metrics()`

Retrieves a list of metrics and associated tags from ATSD, and converts them to Data Frame object.

Each row of the data frame corresponds to a metric and its tags:

* `name`: Unique metric name.
* `counter`: Metrics with continuously incrementing values.
* `lastInsertTime`: Time of the most recently received value.
* `tags`: User-defined tags, as requested by `tags` argument.

**Arguments**:

Argument | Type | Required | Description
--|--|:--:|--
`expression` | string | | Selects all metrics which match the defined name pattern.<br>Refer to [Expression Syntax](#expression-syntax) for more information.
`active` | string:<br>`true` or `false` | | Filters metrics by `lastInsertTime` attribute.<br>When `active = "true"`, only metrics with a positive `lastInsertTime` are included in the response.
`tags` | string vector | | User-defined metric tags to be included in the response.<br>By default, all tags are included.
`limit`| integer | | Limit to returned metrics.
`verbose` | string:<br>`true` or `false` | | Suppress console output.<br>Default value: `true`.

**Examples**:

```r
# Retrieves all metrics and associated tags in the Data Frame
metrics <- get_metrics()
```

```r
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
# Retrieve the first 100 active metrics which have the tag, "table",
# Include this tag into response and exclude other user-defined metric tags
metrics <- get_metrics(expression = "tags.table != ''", active = "true", tags = "table", limit = 100)
```

``` r
tail(metrics$name)
#> [1] "collector-jdbc-query-rows" "cpu_busy"                 
#> [3] "cpu_idle"                  "cpu_iowait"               
#> [5] "cpu_nice"                  "cpu_steal"
```

---

### `get_entities()`

Retrieves a list of entities and associated tags from ATSD, and converts them to a Data Frame object.

Each row of the data frame corresponds to an entity and its tags:

* `name`: Unique entity name.
* `enabled`: Entity status, incoming data is discarded for disabled history.
* `lastInsertTime`: Time of the most recently received value.
* `tags`: User-defined tags, as requested by `tags` argument.

**Arguments**:

Argument | Type | Required | Description
--|--|:--:|--
`expression` | string | | Selects all entities which match the defined name pattern.<br>Refer to [Expression Syntax](#expression-syntax) for more information.
`active` | string:<br>`true` or `false` | | Filters entities by `lastInsertTime` attribute.<br>When `active = "true"`, only entities with a positive `lastInsertTime` are included in the response.
`tags` | string vector | | User-defined entity tags to be included in the response.<br>By default, all tags are included.
`limit` | integer | | Limit to returned entities.
`verbose` | string:<br>`true` or `false` | | Suppress console output.<br>Default value: `true`.

**Examples**:

```r
# Get all entities
entities <- get_entities()
```

```r
names(entities)
#>  [1] "name"             "enabled"          "lastInsertTime"  
#>  [4] "tags.test"        "tags.app"         "tags.ip"         
#>  [7] "tags.os"          "tags.loc_area"    "tags.loc_code"   
#> [10] "tags.environment" "tags.uuu.tag"     "tags.uuu.tag.1"
nrow(entities)
#> [1] 230
```

``` r
# Select entities by name and user-defined tag "app" 
entities <- get_entities(expression = "name like 'nur*' and lower(tags.app) like '*hbase*'" )
```

``` r
entities$name
#> [1] "nurswgvml006" "nurswgvml203" "nurswgvml204" "nurswgvml205"
#> [5] "nurswgvml206" "nurswgvml207" "nurswgvml208"
```

---

### `get_series_tags()`

Retrieves series tags for the defined metric and returns a Data Frame object. For each time series, the function enumerates tags and last update time associated with the series. The list of fetched time series is based on data stored on disk for the last 24 hours.

Each row of the Data Frame corresponds to a time series and associated tags:

* `entity`: Name of the entity generating the time series.
* `lastInsertTime`: Last time a value was received by ATSD for this time series.
* `tags`: Series tags.

**Arguments:**

Argument | Type | Required | Description
--|--|:--:|--
`metric` | string | ![](./images/ok.svg) | Name of the metric for which to retrieve time series.<br>For example: `disk_used_percent`.<br> Use [`get_metrics()`](#get_metrics()) to return a complete list of stored metrics.
`entity` | string | | Name of the entity for which to retreive time series.<br>If omitted, data for all entities which track the defined metric are returned.<br>Use [`get_entities()`](#get_entities()) to return a complete list of stored entities.
`verbose` | string:<br>`true` or `false`| | Suppress console output.<br>Default value: `true`.

**Examples:**

```r
# Get all time series and associated tags collected by ATSD for metric "disk_used_percent"
tags <- get_series_tags(metric = "disk_used_percent")
```

```r
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
# Get all time series and their tags for the "disk_used_percent" metric
# End "nurswgvml007" entity
get_series_tags(metric = "disk_used_percent", entity = "nurswgvml007")
```

---

### `save_series()`

Saves time series from a Data Frame into ATSD. Data Frame must contain a column with timestamps and at least one numeric column with metric values.

**Arguments:**

Argument | Type | Required | Description
--|--|:--:|--
`dfr` | Data Frame | ![](./images/ok.svg) | Name of Data Frame with a timestamp column and at least on numeric column with metric values to be stored in ATSD.
`time_col` | Data Frame | ![](./images/ok.svg) | Number of name of the column which contains timestamps.<br>Default value: `1`.<br>Refer to [Timestamp Format](#timestamp-format) for more information.
`time_format`| string | | Optional string argument which indicates the timestamp format.<br>Possible values:<br><li>`"ms"` Unix milliseconds.<br><li>`"sec"` Unix seconds.<br><li>Format string: `"\%Y-\%m-\%d \%H:\%M:\%S"`<br>Format string is used to convert the provided timestamps to Unix milliseconds before storing the timestamp in ATSD.<br>Refer to [Timestamp Format](#timestamp-format) for more information.
`tz`| string | | Specifies timestamp time zone.<br>Default value: `tz = "GMT"`.<br>For example: `tz = "Australia/Darwin"`.<br>Refer to `TZ` column of [Database Time Zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) for possible values
`metric_col` | numeric or character vector | ![](./images/ok.svg) | Specifies one or more numbers or names of Data Frame columns which contain metric values.<br>For example: `metric_col = c(2,3,4)`, or `metric_col = c("Value","Avg")`<br>If `metric_name` argument is not provided, **lowercased** column names are used as metric names upon storage in ATSD.
`metric_name` | character vector | | Specifies metric names to be saved in ATSD. Quantity and order of provided names must match the quantity and order of imported columns.
`entity_col` | numeric or character vector | | Number or name of Data Frame column containing entities.<br>For example: `entity_col = 4` or `entity_col = "server001"`.<br>Either `entity` **or** `entity_col` argument must be provided.
`entity` | string | | Entity name.<br>Either `entity` **or** `entity_col` argument must be provided.
`tags_col` | numeric or character vector | | Specifies one or more numbers or names which contain tag values.<br>Column name is key in tag `key:value` pair.<br>For example: Value `linux` in column `system` corresponds to series tag `system: linux`.
`tags` | character vector | | Specifies one or more tag `key:value` pairs in `"key=value"` format.<br>Each tag enumerated is saved to each series.<br>Whitespace symbols are ignored.
`verbose`| string:<br>`true` or `false`| | Suppress console output.<br>Default value: `true`.

#### Timestamp Format

Supported timestamp formats are enumerated below:

* **Numeric**: Unix seconds or milliseconds.
  * `time_format = "ms"` or `time_format = "sec"` must be used.
  * Time zone argument `tz`  is ignored.
* **Object**: Supported object include:
  * `Date`
  * `POSIXct`
  * `POSIXlt`
  * `chron` from [`chron`](https://cran.r-project.org/web/packages/chron/index.html) package.
  * `timeDate` from [`timeDate`](https://cran.r-project.org/web/packages/timeDate/index.html) package.
  * Note that `time_format` and `tz` arguments are ignored.
* **String**: For example, `"2015-01-03 10:07:15"`.
  * `time_format` argument must specify which format string is used.
  * For example: `time_format = "\%Y-\%m-\%d \%H:\%M:\%S"`.
    * Enter `?strptime` to review format symbols.
  * This format string is used to convert timestamps to Unix milliseconds before storage in ATSD.
  * Time zone provided by `tz` argument and standard origin `"1970-01-01 00:00:00"` are used for the conversion.
  * Conversion is performed by command `as.POSIXct(time_stamp, format = time_format, origin="1970-01-01", tz = tz)`.

Timestamps are stored by ATSD in Unix milliseconds. When retrieving data inserted into the database, timestamps refer to the same time converted to GMT time zone. For example, the timestamp `"2015-02-15 10:00:00"` with `tz = "Australia/Darwin"` is returned as `"2015-02-15 00:30:00"` because indicated time zone deviates from GMT by `+09:30` hours.

**Examples**:

```r
# Save time series from columns 3, 4, 5 of data frame dfr.
# Timestamps are saved as strings in 2nd column and their format string and time zone are provided.
# Entities and tags are in columns 1, 6, 7.
# All saved series will have tag "os_type" with value "linux".
save_series(dfr, time_col = 2, time_format = "%Y/%m/%d %H:%M:%S", tz = "Australia/Darwin", 
            metric_col = c(3, 4, 5), entity_col = 1, tags_col = c(6, 7), tags = "os_type = linux")
```

---

## Expression Syntax

The `expression` argument is used to filter results for `get_metrics()` and `get_entities()` functions. Expressions which evaluate to `true` are included in resulting Data Frame.

Variable `name` is used to select metrics and entities by name:

```r
# Retrieve metric 'cpu_busy'
metrics <- get_metrics(expression = "name = 'cpu_busy'", verbose = FALSE)
```

```r
pandoc.table(metrics, style = "grid")
#>
#>
#> +----------+-----------+---------------------+---------------+--------------+
#> |   name   |  counter  |   lastInsertTime    |  tags.source  |  tags.table  |
#> +==========+===========+=====================+===============+==============+
#> | cpu_busy |   FALSE   | 2015-04-08 10:17:34 |    iostat     |    System    |
#> +----------+-----------+---------------------+---------------+--------------+
```

Metrics and entities can include user-defined tags, expressed as `key:value` pairs. The variable `tags.tag_name` in an expression refers to the `tag_value` for the given metric/entity. If a metric/entity does not have this tag, the `tag_value` will be an empty string.

```r
# Retrieve metrics without 'source' tag, and include all tags of fetched metrics in output
get_metrics(expression = "tags.source != ''", tags = "*")
```

To retrieve metrics with a user-defined tag `table` equal to `System`:

```r
metrics <- get_metrics(expression = "tags.table = 'System'", tags = "*")
#> Your request was successfully processed by server. Start parsing and filtering.
#> Parsing and filtering done. Start converting to data frame.
#> Converting to data frame done.
```

```r
# Read head of fetched metrics with the pander package
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

To build more complex expressions, use round brackets `( )`, logical operators `and`, `or`, `not` or  `&&` , `||`, `!`.

```r
entities <- get_entities(expression = "tags.app != '' and (tags.os != '' or tags.ip != '')")
#> Your request was successfully processed by server. Start parsing and filtering.
#> Parsing and filtering done. Start converting to data frame.
#> Converting to data frame done.
```

```r
# Read head of fetched entities with the pander package
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

To test if a string is in a collection, use the `in` operator:

```r
get_entities(expression = "name in ('derby-test', 'atom.axibase.com')")
```

Use operator `like` to match values with expressions containing wildcards, for example: `expression = "name like 'disk*'"`. Wildcard character `*` includes those names with the preceding expression plus `0` or more characters. Wildcard character `.` includes those names with the preceding expression plus exactly `1` character.

```r
metrics <- get_metrics(expression = "name like '*cpu*' and tags.table = 'System'")
```

```r
# Retrieve metrics with names consisting of 3 letters
metrics <- get_metrics(expression = "name like '...'")
```

```r
# Print names of fetched metrics
print(metrics$name)
#> [1] "ask" "bid" "jmx"
```

**Additional Expression Functions**:

* `list(string, delimeter))`: Splits the string by delimeter. Default delimiter is comma (`,`).
* `upper(string)`: Converts the string argument to upper case.
* `lower(string)`: Converts the string argument to lower case.
* `collection(name)`: Refers to a named collection of strings created in ATSD.
* `likeAll(string, collection of patterns)`: Returns `true` if every element in the collection of patterns matches the given string.
* `likeAny(string, collection of patterns)`: Returns `true` if at least one element in the collection of patterns matches the given string.

```r
get_metrics(expression = "likeAll(lower(name), list('cpu*,*use*'))")
get_metrics(expression = "likeAny(lower(name), list('cpu*,*use*'))")
get_metrics(expression = "name in collection('fs_ignore')")
```

---

## Configure Connection

**ATSD R Package** uses the connection parameters enumerated below to connect with ATSD:

* `url`: ATSD URL and port number.
* `user`: Username.
* `password`: Password.
* `verify`: Optionally require SSL validation.
* `encryption`: Cryptographic protocol used by ATSD HTTPS server.

Configuration parameters are loaded from the package configuration file upon initial package upload into R.

### `show_connection()`

Prints current values of the connection parameters. These values can differ from values in the [configuration file](./source/inst/connection.config).

**Example**:

```r
show_connection()
#> url = NA
#> user = NA
#> password = NA
#> verify = no
#> encryption = ssl3
```

### `set_connection()`

Overrides connection parameters for the duration of the current R session without changing the configuration file. If called without arguments, the function sets the connection parameters from the configuration file, otherwise `file` argument defines the `connection.config` file to use.

In either case, current values of the parameters became the same as `connection.config` file. If only certain parameters are specified, default `connection.config` file is used for remaining values.

**Arguments**:

Argument | Type | Required | Description
--|--|:--:|--
`url` | string | | ATSD URL and port number.
`user` | string | | Username.
`password` | string | | Password.
`verify`| string:<br>`yes` or `no` | | Optionally require SSL validation (`yes`) or surpress validation (`no`) when using HTTPS protocol.
`encryption`| string | | Cryptographic protocol used by ATSD HTTPS server.<br>Possible values:<br><li>`default`<br><li>`ssl2`<br><li>`ssl3`<br><li>`tls1`<br>Most typically, `ssl3` or `tls1` is used.
`file` | string| | **Absolute** path to the file which contains connection parameters.<br>Refer to [`connection.config`](./source/inst/connection.config) for a template.

**Example**:

```r
# Modify user
set_connection(user = "user001")
```

```r
# Modify the cryptographic protocol 
set_connection(encryption = "tls1")
```

```r
show_connection()
#> url = NA
#> user = user001
#> password = NA
#> verify = no
#> encryption = tls1
```

```r
# Set the parameters of the https connection: url, username, password.
# Do not verify SSL certificates.
# Define which cryptographic protocol is used for communication.
set_connection(url = "https://my.company.com:8443", user = "user001", password = "123456",
               verify = "no", encryption = "ssl3")
```

```r
show_connection()
#> url = https://my.company.com:8443
#> user = user001
#> password = 123456
#> verify = no
#> encryption = ssl3
```

```r
# Set up the connection parameters from the file:
set_connection(file = "/home/user001/atsd_https_connection.txt")
```

### `save_connection()`

Writes connection parameters into the default configuration file. If called without arguments, the function uses the current values of the connection parameters. Otherwise, only provided arguments are written to the configuration file. If no configuration file exists, the function creates one and writes the defined properties there.

**Arguments**:

Argument | Type | Required | Description
--|--|:--:|--
`url` | string | | ATSD URL and port number.
`user` | string | | Username.
`password` | string | | Password.
`verify`| string:<br>`yes` or `no` | | Optionally require SSL validation (`yes`) or surpress validation (`no`) when using HTTPS protocol.
`encryption`| string | | Cryptographic protocol used by ATSD HTTPS server.<br>Possible values:<br><li>`default`<br><li>`ssl2`<br><li>`ssl3`<br><li>`tls1`<br>Most typically, `ssl3` or `tls1` is used.

**Example**:

```r
# Write the current values of the connection parameters to the configuration file.
save_connection()

# Write the user name and password in the configuration file.
save_connection(user = "user00", password = "123456")

# Write all parameters needed for HTTPS connection to the configuration file.
save_connection(url = "https://my.company.com:8443", user = "user001", password = "123456",
               verify = "no", encryption = "ssl3")
```