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

#' Create an entity with specified tags or replace the tags of an existing entity.
#'
#' @description
#' This method creates a new entity and it's tags or replaces the tags of an existing entity.
#' If only a subset of tags is provided for an existing entity, the remaining tags will be deleted.
#' 
#' @param entity
#' Required argument, the name of new entity. To modify some of tags of existing entity
#' and do not change remaining tags use the \code{\link{update_entity}} function.
#'  
#' @param tag_names
#' Optional argument, a character vector of names of tags.
#'
#' @param tag_values
#' Optional argument, a character vector of values of tags. 
#' This vector should has the same length as the \code{tag_names} vector.
#' 
#' @param enabled
#' Optional boolean argument.
#' If \code{enabled = TRUE} the entity will be enabled,
#' if \code{enabled = FALSE} the entity will be disabled.
#' The default value is \code{enabled = TRUE}. 
#' 
#' @param verbose 
#' Optional boolean argument, \code{FALSE} by default. 
#' If \code{verbose = FALSE} then console output will be suppresed.
#' 
#' @return 
#' code{TRUE} if creation/replace was successfull, \code{FALSE} --- otherwise.
#' 
#' @export

create_entity <- function(entity, 
                          tag_names = character(0), 
                          tag_values = character(0), 
                          enabled = TRUE, 
                          verbose = FALSE) {
  
  if (length(tag_names) != length(tag_values) && verbose) {
    message("The tag_values vector should has the same length as tag_names vector.")
    return(FALSE)
  }
  if (!check_connection()) {
    return(FALSE)
  }
  
  the_url <- paste0(get("url", envir = atsdEnv), "/api/v1/entities/", entity)
  
  # build json string for request
  str <- "{"
  str <- paste0(str, '"enabled": "', tolower(as.character(enabled)), '"')
  if (length(tag_names) > 0) {
    str <- paste0(str, ', ')
  }
  if (length(tag_names) > 0) {
    str <- paste0(str, '"tags":{')
    for (i in 1:length(tag_names)) {
      str <- paste0(str, '"', tag_names[i], '": "', tag_values[i], '", ')
    }
    str <- paste0(substr(str, 1, nchar(str) - 2), '}')
  }
  str <- paste0(str, '}')
  
  r <- httr::PUT(url = the_url,
                 httr::authenticate(get("user", envir = atsdEnv), 
                                    get("password", envir = atsdEnv)),
                 body = str,
                 httr::verbose(data_out = verbose, data_in = verbose, info = verbose, ssl = verbose)
  )
  if (verbose) {
    if (r$status_code != 200) {
      message(content(r))
      return(FALSE)
    } else {
      message("Done.")
    }
  }
  return(TRUE)
}
