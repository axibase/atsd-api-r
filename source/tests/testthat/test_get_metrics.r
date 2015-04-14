library("atsd", quietly = TRUE, verbose = FALSE)

context("Test the get_metrics() function.")

test_that("get_metrics() works with http connection", {
  skip_on_cran()
  connection8 <- "/home/user001/8_connection.txt"
  capture.output(set_connection(file = connection8), file = 'NUL')
  capture.output(m <- get_metrics(limit = 10),
                 file = 'NUL')
  #expect_equal_to_reference(m, "get_metrics1.rds")
  expect_equal(nrow(m), 10)
})

# test_that("get_metrics() works with https connection with certificate checking", {
#   skip_on_cran()
#   connection2 <- "/home/user001/4_connection.txt"
#   capture.output(set_connection(file = connection4), file = 'NUL')
#   capture.output(m <- get_metrics(limit = 7, active="true"), file = 'NUL')
#   #expect_equal_to_reference(m, "get_metrics1.rds")
#   expect_equal(nrow(m), 7)
#   capture.output(m <- get_metrics(limit = 11, active = "true", tags = "table", 
#                                   expression = "tags.table != ''"), file = 'NUL')
#   expect_equal(nrow(m), 11)
#   capture.output(m <- get_metrics(expression = "name like 'nmon*' and tags.table like '*CPU*'"), 
#                  file = 'NUL')
#   expect_match(m$name[1], "nmon", ignore.case = TRUE)
#   expect_match(m$tags.table[1], "cpu", ignore.case = TRUE)
# })


test_that("get_metrics() works with https connection without certificate checking", {
  skip_on_cran()
  connection2 <- "/home/user001/2_connection.txt"
  capture.output(set_connection(file = connection2), file = 'NUL')
  capture.output(m <- get_metrics(limit = 7, active="true"), file = 'NUL')
  #expect_equal_to_reference(m, "get_metrics1.rds")
  expect_equal(nrow(m), 7)
  capture.output(m <- get_metrics(limit = 11, active = "true", tags = "table", 
                                  expression = "tags.table != ''"), file = 'NUL')
  expect_equal(nrow(m), 11)
  capture.output(m <- get_metrics(expression = "name like 'nmon*' and tags.table like '*CPU*'"), 
                 file = 'NUL')
  expect_match(m$name[1], "nmon", ignore.case = TRUE)
  expect_match(m$tags.table[1], "cpu", ignore.case = TRUE)
})





# ## test http
# 
# # good requests
# set_connection(file = connection8088)
# m0 <- get_metrics(tags = "*")
# m1 <- get_metrics(limit = 10, active="true")
# m2 <- get_metrics(limit = 10, active ="false")
# m3 <- get_metrics(active = "true", tags = "*")
# m4 <- get_metrics(active = "true", tags = "table", expression = "tags.table != ''")
# m5 <- get_metrics(active = "true", tags = "*", expression = "name like 'bc.a*' and tags.table != ''", limit = 10)
# m6 <- get_metrics(tags = "*", expression = "(name like 'cpu*' or tags.source = '') and tags.table like 'BC*'")
# m7 <- get_metrics(expression = "likeAll(name, list('cpu*,*use*'))")
# m8 <- get_metrics(expression = "name like 'b*'")
# m9 <- get_metrics(expression = "!(name like 'b*')")
# m10 <- get_metrics(expression = "name like 'nmon*' and tags.table like '*CPU*'")
# m11 <- get_metrics(expression = "name like 'nmon*' or tags.table like '*CPU*'")
# 
# # client error: (401) Unauthorized
# set_connection(user = "misha")
# m12 <- get_metrics(limit = 5)
# 
# # Could not resolve host: host_name
# set_connection(host = "host_name")
# m13 <- get_metrics(limit = 5)
# 
# # malformed expression
# # client error: (400) Bad Request
# set_connection(file = connection8088)
# m14 <- get_metrics(expression = "table like '*'")
# 
# ## test https
# set_connection(file = connection8443)
# m15 <- get_metrics(limit = 10, tags = "*")
# m16 <- get_metrics(limit = 10, active ="false")
# m17 <- get_metrics(active = "true", tags = "table", expression = "tags.table != ''")
# m18 <- get_metrics(active = "true", expression = "name like 'jvm*'", limit = 10)
# 
# # client error: (401) Unauthorized
# set_connection(user = "misha")
# m19 <- get_metrics(limit = 5)
# 
# # Could not resolve host: host_name
# set_connection(host = "host_name")
# m20 <- get_metrics(limit = 5)
# 
# # malformed expression
# # client error: (400) Bad Request
# set_connection(file = connection8443)
# m21 <- get_metrics(expression = "table like '*'")
