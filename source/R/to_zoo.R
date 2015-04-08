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
#' Build zoo object from data frame.
#' 
#' @description
#' The function builds a zoo object from given data frame. 
#' The \code{timestamp} argument provides
#' a column of the data frame which is used as index for the zoo object.
#' The \code{value} argument gives series to be saved in the zoo object.
#' If several columns are listed in \code{value} argument the multivariate
#' zoo object will be builded.
#' Information from other columns is ignored.
#' To use this function the 'zoo' package should be installed.
#' To install the 'zoo' package type:
#' \code{install.packages("zoo")}.
#' 
#' @param dfr 
#' The data frame with columns for time stamps and for values.
#' 
#' @param timestamp
#' Name or number of a column with time stamps. By default, \code{timestamp = "Timestamp"}.
#' 
#' @param value
#' Vector of names or numbers of columns with series values. 
#' By default, \code{value = "Value"}.
#' 
#' @export
to_zoo <- function(dfr, timestamp = "Timestamp", value = "Value") {
  if (!requireNamespace("zoo", quietly = TRUE)) {
    msg <- '"zoo"package needed for this function to work. \n'
    msg <- paste0(msg, 'Please install it with: install.packages("zoo")')
    stop(msg, call. = FALSE)
  }
  if (
       ( 
         (is.character(timestamp) && (timestamp %in% names(dfr))) 
         ||
         (is.numeric(timestamp)   && (1 <= timestamp) && (timestamp <= length(dfr)))
       ) 
       &&
       (
         (is.character(value) && (value %in% names(dfr)))
         ||
         (is.numeric(value)   && (value %in% 1:length(dfr)))
       )
     ) {
    return(zoo::zoo(dfr[,value], dfr[,timestamp]))
  } else {
    cat("Can not convert given data frame to zoo object.")
    cat("\nThe data frame does not have one of", timestamp, " or ", value, "columns.")
    stop("Wrong arguments for to_zoo function.", call. = FALSE)
  }
}    
