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

number_to_name <- function(col_names, col_numbers) {
  if (is.numeric(col_numbers)) {
    return(col_names[col_numbers])
  } else {
    return(col_numbers)
  }
}

select_columns <- function(dfr, time_col, metric_col, entity_col, tags_col) {
  cols <- c(time_col, metric_col, entity_col, tags_col)
  return(dfr[cols[!is.na(cols)]])
}