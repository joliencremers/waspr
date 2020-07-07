context("warnings")

test_that("wasp function returns correct errors",{

  #if par.names has wrong length
  expect_error(wasp(pois_logistic, par.names = c("test")))

})
