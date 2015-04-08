#############################################################################
# 
# Copyright 2015 Axibase Corporation or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
# https://www.axibase.com/atsd/axibase-apache-2.0.pdf
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
#
#############################################################################

#' Save time series into ATSD.
#'
#'@description
#' Save time series from given data frame into ATSD.
#' The data frame should have a column with time stamps and
#' at least one numeric column with values of a metric.
#'               
#'@param dfr 
#' Required argument, a data frame. 
#' The data frame should have a column with timestamps and
#' at least one numeric column with values of a metric.
#' 
#'@param time_col
#' Optional numeric or character argument, default value is 1.
#' Number or name of the column with timestaps.
#' For example, time_col = 1, or time_col = "Timestamp".
#' Read "Time stamps format" section for suppported time stamps formats.
#' 
#'@param time_format
#' Optional string argument, indicates format of time stamps.
#' This argument is used in the case when time stamps format is not clear from their class.
#' The value of this argument can be one of strings: "ms" (for epoch milliseconds), 
#' "sec" (for epoch seconds), or format string, 
#' for example "\%Y-\%m-\%d \%H:\%M:\%S".
#' This format string will be used to convert provided time stamps
#' to epoch milliseconds before storing time stamps into ATSD.
#' Read "Time stamps format" section for details.
#' 
#'@param tz
#' Optional string argument. By default, \code{tz = "GMT"}. Specify time zone, when time stamps 
#' are strings formatted as setted in the \code{time_format} argument.
#' For example, \code{tz = "Australia/Darwin"}.
#' Veiw the "TZ" column of \href{http://en.wikipedia.org/wiki/Zone.tab}{the time zones table} for
#' the list of possible values.
#' 
#'@param metric_col
#' Required argument. Numeric or character vector.
#' Specifies numbers or names of the columns 
#' where metrics values are stored.
#' For example, \code{metric_col = c(2, 3, 4)}, or \code{metric_col = c("Value", "Avg")}
#' If \code{metric_name} argument is not given, then names of columns, in low case,
#' are used as names of metrics for saving into ATSD.
#' 
#'@param metric_name
#' Optional argument. Character vector.
#' Specifies names of metrics. The series pointed by \code{metric_col} argument
#' are saved in ATSD along with metric names, provided by the \code{metric_name}.
#' So the number and order of names in the \code{metric_name} should match to
#' columns in \code{metric_col}.
#' If \code{metric_name} argument is not provided, then names of columns, in low case,
#' are used as names of metrics for saving into ATSD.
#'
#'@param entity_col
#' Optional argument, should be provided if the entity argument is not given. 
#' Number or name of a column with entities. 
#' Several entities in the column are allowed.
#' For example, entity_col = 4, or entity_col = "server001".
#' 
#'@param entity
#' Optional character argument, should be provided if the entity_col argument is not given.
#' Name of the entity.
#' 
#'@param tags_col
#' Optional argument. Numeric or character vector.
#' Lists numbers or names of the columns containing values of tags.
#' So the name of a column is a tag name, and values in the column
#' are the tag values.
#' 
#'@param tags
#' Optional argument. Character vector. 
#' Lists tags and their values in "tag=value" format.
#' Each provided tag stick to each series. Witespace symbols are ignored.
#' 
#'@inheritParams query
#'
#'@section Time stamps format:
#'
#' The list of allowed time stamps types.
#' \cr
#' -- Numeric, in epoch milliseconds or epoch seconds. In that case \code{time_format = "ms"}
#' or \code{time_format = "sec"} should be used, and time zone argument \code{tz} is ignored.
#' \cr
#' -- Object of one of types "Date", "POSIXct", "POSIXlt", "chron" from the chron package 
#' or "timeDate" from the timeDate package.
#' In that case arguments \code{time_format} and \code{tz} are ignored.
#' \cr
#' -- String, for example, "2015-01-03 10:07:15". In that case \code{time_format}
#' argument should specify which format string is used for the time stamps.
#' For example, \code{time_format = "\%Y-\%m-\%d \%H:\%M:\%S"}.
#' Type \code{?strptime} to see list of format symbols.
#' This format string will be used to convert provided time stamps
#' to epoch milliseconds before store time stamps in ATSD.
#' So time zone, as written in \code{tz} argument, and standard 
#' origin "1970-01-01 00:00:00" are used for conversion. In fact conversion is done with use 
#' of command:
#' \code{as.POSIXct(time_stamp, format = time_format, origin="1970-01-01", tz = tz)}.
#' 
#' Note that time stamps will be stored in epoch milliseconds. So if you put some data into ATSD
#' and then get it back, the time stamps will refer to the same time but in GMT time zone.
#' For example, if you save time stamp \code{"2015-02-15 10:00:00"} with 
#' \code{tz = "Australia/Darwin"} in ATSD, and then fetch it back, you will get time stamp 
#' \code{"2015-02-15 00:30:00"} because Australia/Darwin
#' time zone has +09:30 shift relatively GMT zone.
#' 
#'@section Entity specification:
#' 
#' You can provide entity name in one of 'entity' or 'entity_col' arguments.
#' In the first case all series will have the same entity.
#' In the second case, if the column of the data frame,
#' specified by 'entity_col', contains several entities,
#' then that entities will be saved along with corresponding series.
#' 
#'@section Tags specification:
#'
#' The 'tags_col' argument points which columns of the data frame
#' keep tags of time series. The name of each column specified by tags_col argument is a tag name, 
#' and the values in the column are the tag values.
#' 
#' Before storing in ATSD the data frame will be splitted to several data frames,
#' each of them has unique entity and unique list of tags values.
#' This entity and tags are stored in ATSD along with time series from such data frame.
#' NA's and missing values in time series will be ignored.
#' 
#' In 'tags' argument you can specify tags which are the same for all rows (records)
#' of the data frame. So each series value saved in ATSD will have tags, provided in
#' the 'tags' argument.
#' 
#'@export

save_series <- function(dfr,
                        time_col = 1,
                        time_format = "%Y-%m-%d %H:%M:%S",
                        tz = "GMT",
                        metric_col,
                        metric_name = character(),
                        entity_col = numeric(),
                        entity = NA,
                        tags_col = numeric(),
                        tags = NA,
                        verbose = TRUE) {
  
  # check arguments and throw error if they are too incorrect
  col_classes <- lapply(dfr, class)
  check_save_series_arguments(names(dfr), col_classes, time_col, time_format, metric_col, 
                              metric_name, entity_col, entity, tags_col, tags, verbose)
  
  # get names of required columns from their numbers
  time_col <- number_to_name(names(dfr), time_col)
  metric_col <- number_to_name(names(dfr), metric_col)
  entity_col <- number_to_name(names(dfr), entity_col)
  tags_col <- number_to_name(names(dfr), tags_col)

  # rename metric_col with metric_name
  if (length(metric_name) > 0) {
    names(dfr)[which(names(dfr) %in% metric_col)] <- metric_name
    metric_col <- metric_name
  }
  
  # retain only required columns
  dfr <- select_columns(dfr, time_col, metric_col, entity_col, tags_col)
    
  # convert time stamps to milliseconds
  dfr[[time_col]] <- to_ms(dfr[[time_col]], col_classes[[time_col]], time_format, tz)
  
  #split data frame
  split_by <- c(entity_col, tags_col)
  split_by <- split_by[!is.na(split_by)]
  if (length(split_by > 0)) {
    splitted <- split(dfr, dfr[split_by])
  } else {
    splitted <- list(dfr)
  }
  #save each item of resulting list into ATSD
  #don't forget add to dfr tags from tags argument
  #and entity from entity argument
  #sapply(splitted, save_dfr)
  for (item_dfr in splitted) {
    save_dfr(item_dfr, time_col, metric_col, entity_col, entity, tags_col, tags, verbose)
  }
}
