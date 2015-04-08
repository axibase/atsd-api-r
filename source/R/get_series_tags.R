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

#' Get unique series tags for the metric.
#' 
#' @description
#' The function determines time series collected for a given metric.
#' For each time series it lists tags associated whith the series,
#' and last time the series was updated. 
#' The list of fetched time series is based on data stored on disk 
#' for the last 24 hours.
#' 
#' @inheritParams query
#' 
#' @return 
#'     A data frame. 
#'     Each row of the data frame corresponds to a time series,
#'     and contains the series unique tags, and last time the series was updated.
#'     For more information view the package vignette: 
#'     \code{browseVignettes(package = "atsd")}.
#' @examples \dontrun{
#' # get all time series and their tags collected by ATSD for the "disk_used_percent" metric
#' get_series_tags(metric = "disk_used_percent")
#' 
#' # get all time series and their tags for the "disk_used_percent" metric
#' # end "nurswgvml007" entity
#' get_series_tags(metric = "disk_used_percent", entity = "nurswgvml007")
#' }
#' @export

get_series_tags <- function(metric, entity = NA, verbose = TRUE){
  
  if (!check_connection()) {
    return(NA)
  }
  
  https_options <- set_https_options()
  if (is.na(entity)) {
    query_list <- list()
  } else {
    query_list <- list(entity = entity)
  }
  
  response <- tryCatch({
    httr::GET(paste0(get("url", envir = atsdEnv), "/api/v1/metrics/", metric, "/entity-and-tags"),
              httr::authenticate(get("user", envir = atsdEnv), 
                                 get("password", envir = atsdEnv)),
              query = query_list,
              config = https_options
              #list(
              #cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))), 
              #followlocation = TRUE, 
              #useragent = "R", 
              #ssl.verifypeer = FALSE
              #sslversion=3)
    )
  }, error = function(er) {
    message("Malformed http(s) request.")
    message(er$message)
    return(NULL)
  })
  
  if (is.null(response)) {
    return(NA)
  }
  
  if (! tryCatch({
    httr::stop_for_status(response)
  }, error = function(er) {
    message("Error occurs when processing the request to ATSD server:")
    message(er$message)
    return(FALSE)
  })) {
    return(NA)
  }
  
  if (verbose) {
    cat("Your request was successfully processed by server. Start parsing and converting to data frame.")
  }
  
  tags <- lapply(httr::content(response, "parsed"), make_flat)
  
  # Conversion of list of metrics to data frame.
  # The following one-liner is too slow, so we should do more work.
  # metrics <- (Reduce(merge_all, metrics))
  tags <- list_to_dfr(tags)
  if (verbose) {
    cat("\nConverting to data frame done.")
  }
  
  if ("lastInsertTime" %in% names(tags)) {
    tags$lastInsertTime <- as.POSIXlt(tags$lastInsertTime / 1000, origin = "1970-01-01 00:00:00", tz = "GMT")
  }
  return(tags)
}
