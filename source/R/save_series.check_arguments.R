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

check_save_series_arguments <- function(col_names,
                                        col_classes,
                                        time_col,
                                        time_format,
                                        metric_col,
                                        metric_name,
                                        entity_col,
                                        entity,
                                        tags_col,
                                        tags,
                                        verbose) {
  # check time_col
  check_type("time_col", time_col)
  if (length(time_col) != 1) {
    cat("\ntime_col argument should specify single column with timestamps.")
    stop("Wrong arguments.", call. = FALSE)
  }
  check_range("time_col", time_col, col_names)
  # check type of column
  #   if (! time_format %in% c("ms", "", "POSIXct", "POSIXlt", "chron", "timeDate")) {
  #     cat("\nCan't recognise time stamp format: ", time_format)
  #     cat("\nView function's help page to know which time stamp formats are valid.")
  #     stop("Wrong arguments.", call. = FALSE)
  #   }
  
  # check metric_col
  check_type("metric_col", metric_col)
  if (length(metric_col) == 0) {
    cat("metric_col argument should specify at least one column with values.")
    stop("Wrong arguments.", call. = FALSE)
  }
  check_range("metric_col", metric_col, col_names)
  # check type of column
  for (col_class in col_classes[metric_col]) {
    if (!col_class %in% c("integer", "double", "numeric")) {
      cat("\nValues of the metric should be numeric.")
      cat("\nOne of columns provided in metric_col argument is not numeric.")
      stop("Wrong arguments.", call. = FALSE)
    }
  }
  # check metric_name
  if (length(metric_name) > 0) {
    if (!(all(is.character(metric_name))) || length(metric_name) != length(metric_col)) {
      cat("\nMetric_name argument is not character or does not match to metric_col argument!")
      stop("Wrong arguments for save_series() function.", call. = FALSE)
    }
  }
  
  # check entity and entity_col
  check_type("entity_col", entity_col)
  if (!is.na(entity) && !(is.character(entity))) {
    cat("\nArgument 'entity' should be a string.")
    stop("Wrong arguments.", call. = FALSE)
  }
  if (is.na(entity)) {
    if (length(entity_col) == 0) {
      cat("Exactly one of 'entity' or 'entity_col' arguments should be provided.")
      print("hop")
      stop("Wrong arguments.", call. = FALSE)
    } else {
      check_range("entity_col", entity_col, col_names)
    }
  } else {
    if (length(entity_col != 0)) {
      cat("Exactly one of 'entity' or 'entity_col' arguments should be provided.")
      stop("Wrong arguments.", call. = FALSE)
    }
  }
  
  # check tags_col
  check_type("tags_col", tags_col)
  check_range("tags_col", tags_col, col_names)
  
  return(TRUE)
}

check_type <- function(arg_name, arg_value) {
  if (!(is.numeric(arg_value) || is.character(arg_value))) {
    cat("\nArgument ", arg_name, " should be numeric or character vector.")
    stop("Wrong arguments.", call. = FALSE)
  }
}

check_range <- function(arg_name, arg_value, col_names) {
  if(is.numeric(arg_value) && !all(arg_value %in% 1:length(col_names))) {
    cat("\nProvided data frame has ", length(col_names), " columns.")
    cat("\nArgument ", arg_name, " = ", arg_value, " is out of range.")
    stop("Wrong arguments.", call. = FALSE)
  }
  if(is.character(arg_value) && !all(arg_value %in% col_names)) {
    cat("\nData frame has no column with name provided in ", arg_name, " argument.")
    stop("Wrong arguments.", call. = FALSE)
  }
}

