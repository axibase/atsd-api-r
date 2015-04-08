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

#' @keywords internal

to_ms <- function(timestamp, time_class, time_format, tz) {

  if ("numeric" %in% time_class || "integer" %in% time_class) {
    if (time_format == "ms") {
      return(format(timestamp, scientific = FALSE))
    }
    if (time_format == "sec") {
      return(format(timestamp * 1000, scientific = FALSE))
    }
    cat("\nSet time_format = \"ms\" if time stamps are in milliseconds")
    cat("\nor time_format = \"sec\" if time stamps are in seconds.")
    stop("Wrong arguments.", call. = FALSE)
  }
  
  # Works for both POSIXct and POSIXlt classes.
  if ("POSIXt" %in% time_class || "POSIXct" %in% time_class || "POSIXlt" %in% time_class) {
    # Returns number of epoch milliseconds - 
    # number of ms from 1970-01-01 00:00:00 GMT.
    # So if an user save timeztamp T with time zone = UCT + x,
    # when fetch it back he gets timestamp (T - x) UTC + 00.
    return(format(as.numeric(timestamp) * 1000, scientific = FALSE))
  }

  if ("Date" %in% time_class) {
    #origin <- as.Date("1970-01-01 00:00:00", "%Y-%m-%d %H:%M:%S")
    origin <- as.Date("1970-01-01")
    return(format(as.numeric(difftime(timestamp, origin, units = "secs")) * 1000, scientific = FALSE))
  }
  
  if ("chron" %in% time_class) {
    if (!requireNamespace("chron", quietly = TRUE)) {
      msg <- "It seems that time stamps are 'chrone' objects, so"
      msg <- '"chron" package should be installed. \n'
      msg <- paste0(msg, 'Please install it with: install.packages("chron")')
      stop(msg, call. = FALSE)
    }
    origin <- chron::as.chron("1970-01-01 00:00:00", "%Y-%m-%d %H:%M:%S")
    return(format(as.numeric(difftime(timestamp, origin, units = "secs")) * 1000, scientific = FALSE))
  }
  
  if ("timeDate" %in% time_class) {
    if (!requireNamespace("timeDate", quietly = TRUE)) {
      msg <- "It seems that time stamps are 'timeDate' objects, so"
      msg <- '"timeDate" package should be installed. \n'
      msg <- paste0(msg, 'Please install it with: install.packages("chron")')
      stop(msg, call. = FALSE)
    }
    origin <- timeDate::timeDate("1970-01-01 00:00:00", 
                                 format  = "%Y-%m-%d %H:%M:%S", FinCenter = "GMT")
    return(format(as.numeric(difftime(timestamp, origin, units = "secs")) * 1000, scientific = FALSE))
  }
  
  # Now we suppose, that format string is provided
  if (time_class == "character") {
    return(
      format(
        as.numeric(
          as.POSIXct(timestamp, tz = tz, format = time_format, origin = "1970-01-01 00:00:00")) * 1000,
        scientific = FALSE))
  }
  
  msg <- "Can not understand what time format is used."
  stop(msg, call. = FALSE)

}