library("atsd", quietly = TRUE, verbose = FALSE)
cat("\n")

context("Test connection management.")

test_that("set_connection() correctly changes connection variables", {
  skip_on_cran()
  # set all variables from arguments
  capture.output(set_connection(user = "user01"), file = 'NUL')
  capture.output(set_connection(encryption = "tls1"), file = 'NUL')
  capture.output(set_connection(url = "http://host_name:port_number"), file = 'NUL')
  capture.output(set_connection(verify = "yes"), file = 'NUL')
  capture.output(set_connection(password = "qwerty"), file = 'NUL')
  connection_txt <- capture.output(show_connection())
  expected <- c("url = http://host_name:port_number", "user = user01",
                "password = qwerty", "verify = yes", "encryption = tls1")
  expect_equal(connection_txt, expected)
  
  
  # change some of variables
  capture.output(set_connection(verify = "no"), file = 'NUL')
  capture.output(set_connection(encryption = "ssl3"), file = 'NUL')
  connection_txt <- capture.output(show_connection())
  expected <- c("url = http://host_name:port_number", "user = user01",
                "password = qwerty", "verify = no", "encryption = ssl3")
  expect_equal(connection_txt, expected)
  
  
  # set connection from a file
  capture.output(set_connection(file = "/home/user001/fake_connection.txt"), file = 'NUL')
  connection_txt <- capture.output(show_connection())
  expected <- c("url = http://host_name:port_number", "user = atsd_user_name",
                "password = atsd_user_password", "verify = no", "encryption = ssl3")
  expect_equal(connection_txt, expected)
})

test_that("save_connection() correctly save connection variables to file", {
  skip_on_cran()
  # save current values of connection parameters into configuration file
  save_connection()
  
  # change user and url and check
  capture.output(set_connection(user = "masha"), file = 'NUL')
  capture.output(set_connection(url = ""), file = 'NUL')
  connection_txt <- capture.output(show_connection())
  expected <- c("url = ", "user = masha",
                "password = atsd_user_password", "verify = no", "encryption = ssl3")
  expect_equal(connection_txt, expected)
  
  # set connection from configuration file and check
  capture.output(set_connection(), file = 'NUL')
  connection_txt <- capture.output(show_connection())
  expected <- c("url = http://host_name:port_number", "user = atsd_user_name",
                "password = atsd_user_password", "verify = no", "encryption = ssl3")
  expect_equal(connection_txt, expected)
  
  # save parameters from arguments
  save_connection(user = "masha", url = "")
  # set connection from configuration file and check
  capture.output(set_connection(), file = 'NUL')
  connection_txt <- capture.output(show_connection())
  expected <- c("url = NA", "user = masha",
                "password = atsd_user_password", "verify = no", "encryption = ssl3")
  expect_equal(connection_txt, expected)
  
  # set connection from file, and save it in configuration file
  capture.output(set_connection(file = "/home/user001/8_connection.txt"), file = 'NUL')
  save_connection()
  
  # set all variables to empty strings and check
  capture.output(set_connection(url = "", user = "", password = "", 
                                verify = "", encryption = ""), file = 'NUL')
  connection_txt <- capture.output(show_connection())
  expected <- c("url = ", "user = ", "password = ", "verify = NA", "encryption = ")
  expect_equal(connection_txt, expected)
  
  # set connection from configuration file and check
  capture.output(set_connection(), file = 'NUL')
  connection_txt <- capture.output(show_connection())
  expect_match(connection_txt[1], "8088$")
  expect_equal(connection_txt[4], "verify = NA")
  
  # make configuration file clean
  capture.output(set_connection(file = "/home/user001/fake_connection.txt"), file = 'NUL')
  save_connection()
})

test_that("set_connection() throw error for wrong file argument", {
  skip_on_cran()
  # try set connection from non-existing file
  expect_error(
    suppressMessages(
      suppressWarnings(
        set_connection(file = "/home/user001/wrong_file_name.txt"))))
  # the connection variables should be the same
  connection_txt <- capture.output(show_connection())
  expect_equal(connection_txt[1], "url = http://host_name:port_number")
  expect_equal(connection_txt[2], "user = atsd_user_name")
  expect_equal(connection_txt[3], "password = atsd_user_password")
  expect_equal(connection_txt[4], "verify = no")
})

