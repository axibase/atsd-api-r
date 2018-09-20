## ----, echo = FALSE------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ----pander, echo=FALSE, results='hide'----------------------------------
library(pander)
panderOptions('table.split.table', 100)

## ----, eval = FALSE------------------------------------------------------
#  installed.packages()["atsd", "LibPath"]

## ----, eval = FALSE------------------------------------------------------
#  set_connection()

## ----, eval = FALSE------------------------------------------------------
#  show_connection()

## ----, eval = TRUE, echo=FALSE, results='hide'---------------------------
library(atsd)
set_connection(file = "/home/user001/8_connection.txt")

## ----, eval = TRUE, results='hide'---------------------------------------
# get historic data for the given entity, metric, and selection_interval
dfr <- query(entity = "nurswgvml007", metric = "cpu_busy", selection_interval = "1-Hour")

## ----, eval = TRUE, echo=TRUE--------------------------------------------
# look at head of fetched data frame with the pander package
pandoc.table(head(dfr, 3), style = "grid")

## ----, eval = FALSE------------------------------------------------------
#  # end_time usage example
#  query(entity = "host-383", metric = "cpu_usage", selection_interval = "1-Day",
#        end_time = "date('2015-02-10 10:15:03')")
#  
#  # get forecasts
#  query(metric = "cpu_busy", selection_interval = "30-Minute", export_type = "Forecast", verbose = FALSE)
#  
#  # use aggregation
#  query(metric = "disk_used_percent", entity_group = "Linux", tags = c("mount_point=/boot",
#        "file_system=/dev/sda1"), selection_interval = "1-Week", aggregate_interval = "1-Minute",
#        aggregate_statistics = c("Avg", "Min", "Max"), interpolation = "Linear", export_type = "Forecast")

## ----, eval = TRUE, echo=TRUE, results='hide'----------------------------
# query ATSD for data and transform it to zoo object
dfr <- query(entity = "nurswgvml007", metric = "cpu_busy", selection_interval = "1-Hour")
z <- to_zoo(dfr)

## ----, eval = TRUE-------------------------------------------------------
# show head of the zoo object
head(z, 3)

## ----, eval = TRUE, results='hide'---------------------------------------
# get all metrics and include all their tags in the data frame
metrics <- get_metrics()

## ----, eval = TRUE-------------------------------------------------------
colnames(metrics)
pandoc.table(metrics[1, ], style = "grid")

## ----, eval = TRUE, results='hide'---------------------------------------
# get the first 100 active metrics which have the tag, "table", 
# include this tag into response and exclude oter user-defined metric tags
metrics <- get_metrics(expression = "tags.table != ''", active = "true", tags = "table", limit = 100)

## ----, eval = TRUE-------------------------------------------------------
tail(metrics$name)

## ----, eval = TRUE, results='hide'---------------------------------------
# get all entities
entities <- get_entities()

## ----, eval = TRUE-------------------------------------------------------
names(entities)
nrow(entities)

## ----, eval = TRUE, results='hide'---------------------------------------
# select entities by name and user-defined tag "app" 
entities <- get_entities(expression = "name like 'nur*' and lower(tags.app) like '*hbase*'" )

## ----, eval = TRUE-------------------------------------------------------
entities$name

## ----, eval = TRUE, echo=FALSE, results='hide'---------------------------
set_connection(file = "/home/user001/8_connection.txt")

## ----, eval = TRUE, results='hide'---------------------------------------
# get all time series and their tags collected by ATSD for the "disk_used_percent" metric
tags <- get_series_tags(metric = "disk_used_percent")

## ----, eval = TRUE, echo = TRUE------------------------------------------
pandoc.table(head(tags, 3), style = "grid")

## ----, eval = FALSE------------------------------------------------------
#  # get all time series and their tags for the "disk_used_percent" metric
#  # end "nurswgvml007" entity
#  get_series_tags(metric = "disk_used_percent", entity = "nurswgvml007")

## ----, eval = FALSE, echo=FALSE, results='hide'--------------------------
#  set_connection(file = "/home/user001/8_connection.txt")

## ----, eval = FALSE, results='hide'--------------------------------------
#  # Save time-series from columns 3, 4, 5 of data frame dfr.
#  # Timestamps are saved as strings in 2nd column and their format string and time zone are provided.
#  # Entities and tags are in columns 1, 6, 7.
#  # All saved series will have tag "os_type" with value "linux".
#  save_series(dfr, time_col = 2, time_format = "%Y/%m/%d %H:%M:%S", tz = "Australia/Darwin",
#              metric_col = c(3, 4, 5), entity_col = 1, tags_col = c(6, 7), tags = "os_type = linux")

## ----, eval = TRUE-------------------------------------------------------
# get metric with name 'cpu_busy'
metrics <- get_metrics(expression = "name = 'cpu_busy'", verbose = FALSE)

## ----, eval = TRUE, echo = TRUE------------------------------------------
pandoc.table(metrics, style = "grid")

## ----, eval = FALSE, results='hide'--------------------------------------
#  # get metrics without 'source' tag, and include all tags of fetched metrics in output
#  get_metrics(expression = "tags.source != ''", tags = "*")

## ----, eval = TRUE-------------------------------------------------------
# get metrics whose tag 'table' is equal to 'System'
metrics <- get_metrics(expression = "tags.table = 'System'", tags = "*")

## ----, eval=TRUE, echo=TRUE----------------------------------------------
# look head of fetched metrics with the pander package
pandoc.table(head(metrics, 2), style = "grid")

## ----, eval = TRUE-------------------------------------------------------
entities <- get_entities(expression = "tags.app != '' and (tags.os != '' or tags.ip != '')")

## ----, eval=TRUE, echo=TRUE----------------------------------------------
# look at head of fetched entities with the pander package
pandoc.table(head(entities, 3), style = "grid")

## ----, eval = FALSE------------------------------------------------------
#  get_entities(expression = "name in ('derby-test', 'atom.axibase.com')")

## ----, eval = FALSE------------------------------------------------------
#  metrics <- get_metrics(expression = "name like '*cpu*' and tags.table = 'System'")

## ----, eval = TRUE, results='hide'---------------------------------------
# get metrics with names consisting of 3 letters
metrics <- get_metrics(expression = "name like '...'")

## ----, eval = TRUE-------------------------------------------------------
# print names of fetched metrics
print(metrics$name)

## ----, eval = FALSE------------------------------------------------------
#  get_metrics(expression = "likeAll(lower(name), list('cpu*,*use*'))")
#  get_metrics(expression = "likeAny(lower(name), list('cpu*,*use*'))")
#  get_metrics(expression = "name in collection('fs_ignore')")

## ----, eval = TRUE, echo=FALSE, results='hide'---------------------------
set_connection(file = "/home/user001/connection.config")

## ----, eval = TRUE-------------------------------------------------------
show_connection()

## ----, eval = TRUE, echo=FALSE, results='hide'---------------------------
set_connection(file = "/home/user001/connection.config")

## ----, eval = TRUE, results='hide'---------------------------------------
# Modify the user 
set_connection(user = "user001")

## ----, eval = TRUE, results='hide'---------------------------------------
# Modify the cryptographic protocol 
set_connection(encryption = "tls1")

## ----, eval = TRUE-------------------------------------------------------
show_connection()

## ----, eval = TRUE, results='hide'---------------------------------------
# Set the parameters of the https connection: url, user name, password 
# should the certificate of the server be verifyed 
# which cryptographic protocol is used for communication
set_connection(url = "https://my.company.com:8443", user = "user001", password = "123456", 
               verify = "no", encryption = "ssl3")

## ----, eval = TRUE-------------------------------------------------------
show_connection()

## ----, eval = FALSE------------------------------------------------------
#  # Set up the connection parameters from the file:
#  set_connection(file = "/home/user001/atsd_https_connection.txt")

## ----, eval = FALSE------------------------------------------------------
#  # Write the current values of the connection parameters to the configuration file.
#  save_connection()
#  
#  # Write the user name and password in the configuration file.
#  save_connection(user = "user00", password = "123456")
#  
#  # Write all parameters nedeed for the https connection to the configuration file.
#  save_connection(url = "https://my.company.com:8443", user = "user001", password = "123456",
#                 verify = "no", encryption = "ssl3")

