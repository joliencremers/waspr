#' waspr: an R package for computing Wasserstein barycenters of subset
#' posteriors
#'
#' This package contains functions to compute Wasserstein barycenters of subset
#' posteriors using the swapping algorithm developed by Puccetti, Rüschendorf
#' and Vanduffel (2020). A user can either provide an object containing mcmc
#' samples for all subset posteriors or provide a stan model, data and desired
#' amount of subsets. If the user provides a stan model and data the function
#' \code{stan_wasp} will analyze the data subsets in parallel using
#' \code{rstan}.
#'
#' @section Functions:
#'
#'   The main functions of the package are:
#'
#'   \code{\link{wasp}}, which runs the swapping algorithm developed by
#'   Puccetti, Rüschendorf and Vanduffel (2020), combines the output from the
#'   swapping algorithm and computes the wasserstein barycenter. It returns an
#'   S3 object of type \code{wasp}, which can be further analyzed through
#'   associated functions.
#'
#'   \code{\link{combine}}, which
#'
#' @source Puccetti, G., Rüschendorf, L. & Vanduffel, S. (2020). On the
#'   computation of Wasserstein barycenters, Journal of Multivariate Analysis,
#'   176.
#'
#' @useDynLib waspr, .registration = TRUE
#'
#' @importFrom Rcpp evalCpp
#'
#' @docType package
#' @name waspr

NULL
