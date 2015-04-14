context("Test the save_series() function.")

test_that("save_series() works with http connection", {
  skip_on_cran()

  connection8 <- "/home/user001/8_connection.txt"
  connection4 <- "/home/user001/4_connection.txt"
  connection2 <- "/home/user001/2_connection.txt"
  capture.output(set_connection(file = connection8), file = 'NUL')
  dfr <- read.csv("/home/user001/series_data.csv")
  capture.output(save_series(dfr, time_col = 2, time_format = "ms", 
                             metric_col = c(3, 4, 5),
                             entity_col = 1, entity = NA, tags_col = c(6, 7), 
                             tags = "r_test_tag3=value3", verbose = FALSE),
                 file = 'NUL')
  capture.output(q <- query(metric = "r_test_dup",
                            selection_interval = "1-Day",
                            end_time = "date('2015-03-14')"),
                 file = 'NUL')
  expect_equal(nrow(q), 16)
  expect_equal(q$Value[1], 1.2)
  expect_equal(q$metric[1], "r_test_dup")
  expect_equal(q$entity[1], "r_test_e1")
  expect_equal(q$r_test_t_one[1], "one")
  expect_equal(q$r_test_t_two[1], 1)
  expect_equal(q$r_test_tag3[1], "value3")
  unlink("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/source/tests/testthat/NUL")
})



# 
# 
# 
# dfr <- read.csv("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/series_data.csv", stringsAsFactors = FALSE)
# 
# # TRUE until time_format not checked
# check_save_series_arguments(dfr, time_col = 2, time_format = "numeric", metric_col = c(3, 4, 5),
#                             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "tag3=value3", verbose = TRUE)
# 
# # TRUE until time_format not checked
# check_save_series_arguments(dfr, time_col = "time", time_format = "numeric", metric_col = c(3, 4, 5),
#                             entity_col = 1, entity = NA, tags_col = c("t_two", "t_three"), tags = "tag3=value3", verbose = TRUE)
# 
# # TRUE until time_format not checked
# check_save_series_arguments(dfr, time_col = 2, time_format = "numeric", metric_col = c(3, 4, 5),
#                             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "tag3=value3", verbose = TRUE)
# 
# # Error time_col out of range
# check_save_series_arguments(dfr, time_col = 9, time_format = "numeric", metric_col = c(3, 4, 5),
#                             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "tag3=value3", verbose = TRUE)
# 
# # Error time_col out of range
# check_save_series_arguments(dfr, time_col = "timestamp", time_format = "numeric", metric_col = c(3, 4, 5),
#                             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "tag3=value3", verbose = TRUE)
# 
# 
# 
# 
# 
# 
# 
# dfr <- read.csv("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/series_data.csv", stringsAsFactors = FALSE)
# 
# 
# connection8088 <- "/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/8088_connection.txt"
# connection8443 <- "/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/8443_connection.txt"
# 
# set_connection(file = connection8443);
# 
# dfr <- read.csv("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/series_data.csv", stringsAsFactors = FALSE)
# save_series(dfr, time_col = 2, time_format = "ms", metric_col = c(3, 4, 5),
#                             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "r_test_tag3=value3", verbose = TRUE)
# 
# dfr <- read.csv("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/series_data_Date.csv", 
#                 colClasses = c("character" ,"Date", "numeric", "numeric", "numeric", "character", "integer", "integer"),
#                 stringsAsFactors = FALSE)
# save_series(dfr, time_col = 2, metric_col = c(3, 4, 5),
#             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "r_test_tag3=value3", verbose = TRUE)
# 
# dfr <- read.csv("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/series_data_POSIX.csv", 
#                 colClasses = c("character" ,"character", "numeric", "numeric", "numeric", "character", "integer", "integer"),
#                 stringsAsFactors = FALSE)
# dfr$time <- as.POSIXct(dfr$time, tz = "Europe/Moscow")
# save_series(dfr, time_col = 2, metric_col = c(3, 4, 5),
#             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "r_test_tag3=value3", verbose = TRUE)
# 
# require("chron")
# dfr <- read.csv("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/series_data_POSIX.csv", 
#                 colClasses = c("character" ,"character", "numeric", "numeric", "numeric", "character", "integer", "integer"),
#                 stringsAsFactors = FALSE)
# dfr$time <- as.chron(dfr$time)
# save_series(dfr, time_col = 2, metric_col = c(3, 4, 5),
#             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "r_test_tag3=value3", verbose = TRUE)
# detach("package:chron", unload = TRUE)
# 
# require("timeDate")
# dfr <- read.csv("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/series_data_POSIX.csv", 
#                 colClasses = c("character" ,"character", "numeric", "numeric", "numeric", "character", "integer", "integer"),
#                 stringsAsFactors = FALSE)
# dfr$time <- timeDate(dfr$time, format  = "%Y-%m-%d %H:%M:%S", FinCenter = "Asia/Irkutsk")
# save_series(dfr, time_col = 2, metric_col = c(3, 4, 5),
#             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "r_test_tag3=value3", verbose = TRUE)
# detach("package:timeDate", unload = TRUE)
# 
# dfr <- read.csv("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/series_data_format.csv", 
#                 colClasses = c("character" ,"character", "numeric", "numeric", "numeric", "character", "integer", "integer"),
#                 stringsAsFactors = FALSE)
# save_series(dfr, time_col = 2, time_format = "%Y/%m/%d %H:%M:%S", tz = "Europe/Riga", metric_col = c(3, 4, 5),
#             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "r_test_tag3=value3", verbose = TRUE)
# 
# 
# # Test time zone
# dfr <- read.csv("/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/test_time_zone.csv", 
#                 colClasses = c("character" ,"character", "numeric", "numeric", "numeric", "character", "integer", "integer"),
#                 stringsAsFactors = FALSE)
# res <- save_series(dfr, time_col = 2, time_format = "%Y/%m/%d %H:%M:%S", tz = "Australia/Darwin", metric_col = c(3, 4, 5),
#             entity_col = 1, entity = NA, tags_col = c(6, 7), tags = "r_test_tag3=value3", verbose = TRUE)
