library("atsd", quietly = TRUE, verbose = FALSE)

context("Test the get_entities() function.")

test_that("get_entities() works with http connection", {
  skip_on_cran()
  connection8 <- "/home/user001/8_connection.txt"
  connection4 <- "/home/user001/4_connection.txt"
  connection2 <- "/home/user001/2_connection.txt"
  capture.output(set_connection(file = connection8), file = 'NUL')
  capture.output(e <- get_entities(limit = 2, expression = "name like 'nur*'"),
                 file = 'NUL')
  expect_equal_to_reference(e$name, "get_entities1.rds")
})




# connection8088 <- "/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/8088_connection.txt"
# connection8443 <- "/home/mikhail/axibase/scripts/reading_data/atsd-api-r/trunk/tests/8443_connection.txt"
# 
# ## test http
# 
# # good requests
# set_connection(file = connection8088)
# e1 <- get_entities(limit = 2, expression = "name like 'nur*'")
# e2 <- get_entities(limit = 2, expression = "name like 'nur*' and lower(tags.app) like '*hbase*'", tags = "app")
# e3 <- get_entities(expression = "name like '*nur*'")
