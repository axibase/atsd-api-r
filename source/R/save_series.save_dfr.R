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

save_dfr <- function(dfr, time_col, metric_col, entity_col, entity, tags_col, tags, verbose) {
  if (is.na(entity)) {
    entity <- as.character(dfr[[entity_col]][1])
  }
  
  if (is.na(entity) || entity == "") {
    return()
  }
  
  tags_list <- list()
  for (tag_name in tags_col) {
    tag_val <- as.character(dfr[[tag_name]][1])
    if (is.na(tag_val) || tag_val == "") {
      next
    }
    tags_list[[tag_name]] <- tag_val
  }
  if (!is.na(tags)) {
    for (tag in tags) {
      tag <- gsub("[[:space:]]", "", tag)
      delim <- gregexpr(pattern = "=", tag)[[1]][1]
      if (delim < 2) {
        cat("\nIncorrect value of tags argument.")
        cat("\nOne of tags has not form 'tag_name=tag_value'.")
        stop("Wrong arguments.", call. = FALSE)
      }
      tags_list[[substr(tag, 1, delim - 1)]] <- substr(tag, delim + 1, nchar(tag))
    }
  }
  
  the_url <- get("url", envir = atsdEnv)
  
  path <- paste0("api/v1/series/csv/", entity)
  
  # modify_url(url, scheme = NULL, hostname = NULL, port = NULL,
  #            path = NULL, query = NULL, params = NULL, fragment = NULL,
  #            username = NULL, password = NULL)
  if (length(tags_list) > 0) {
    the_url <- httr::modify_url(the_url, path = path, query = tags_list)
  } else {
    the_url <- httr::modify_url(the_url, path = path)
  }
  
  for (metric in metric_col) {
    df <- dfr[c(time_col, metric)]
    df <- na.omit(df)
    if (nrow(df) == 0) {
      next
    }
    t_con <- textConnection("Store data frame as csv text." ,"w")
    write.csv(df, t_con, row.names = FALSE)
    csv_as_text <- textConnectionValue(t_con)
    close(t_con)
    if (verbose) {
      httr::POST(url = the_url,
                 httr::authenticate(get("user", envir = atsdEnv), get("password", envir = atsdEnv)),
                 #httr::set_cookies(cookies = "1p5rtwkbfqzwygywzse9ypnlc"),
                 config = set_https_options(),
                 httr::content_type("text/csv"),
                 body = csv_as_text,
                 httr::verbose(data_out = verbose, data_in = verbose, info = verbose, ssl = verbose))
    } else {
      httr::POST(url = the_url,
                 httr::authenticate(get("user", envir = atsdEnv), get("password", envir = atsdEnv)),
                 #httr::set_cookies(cookies = "1p5rtwkbfqzwygywzse9ypnlc"),
                 config = set_https_options(),
                 httr::content_type("text/csv"),
                 body = csv_as_text)
    }
  }
}