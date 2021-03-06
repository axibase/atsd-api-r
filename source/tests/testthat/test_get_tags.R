library("atsd", quietly = TRUE, verbose = FALSE)

context("Test the get_series_tags() function.")

test_that("get_entities() works with http connection", {
  skip_on_cran()
  connection8 <- "/home/user001/8_connection.txt"
  capture.output(set_connection(file = connection8), file = 'NUL')
  capture.output(st <- get_series_tags(metric = "disk_used_percent"),
                 file = 'NUL')
  expect_equal_to_reference(st$tags.file_system, "get_series_tags1.rds")
})

test_that("get_entities() works with https connection without certificate checking", {
  skip_on_cran()
  connection2 <- "/home/user001/2_connection.txt"
  capture.output(set_connection(file = connection2), file = 'NUL')
  capture.output(st <- get_series_tags(metric = "disk_used_percent"), file = 'NUL')
  expect_equal(all(c("entity", "lastInsertTime", "tags.mount_point", "tags.file_system") %in% names(st)), TRUE)
})

# 
# test_dir <- "/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/"
# connection8088 <- "/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/8088_connection.txt"
# connection8443 <- "/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/8443_connection.txt"
# 
# set_connection(file = connection8088)
# t1 <- get_tags(metric = "disk_used_percent")
# t2 <- get_tags(metric = "disk_used_percent", entity = "nurswgvml007")
# 
# set_connection(file = connection8443)
# t3 <- get_tags(metric = "jvm_memory_used")
# t4 <- get_tags(metric = "message_writes_per_second", entity = "atsd")
# t5 <- get_tags(metric = "metric_writes_per_second")
