#' Posterior summaries for the Wasserstein barycenter of subset posteriors
#'
#' \code{summary} gives a posterior summary (mean, mode, sd, HPD)
#'
#' @param object a wasp object.
#'
#' @details the method \link[waspr]{summary.wasp} has its own help page.
#'
#' @examples
#' library(waspr)
#'
#' @export
#'

summary <- function(object){

  UseMethod("summary", object)

}

#' Posterior summaries for the Wasserstein barycenter of subset posteriors
#'
#' Outputs and prints posterior summary statistics (mean, mode, sd, 95% Highest
#' Posterior Density interval)
#'
#' @param object a \code{wasp object} obtained from the function \code{wasp()}.
#'
#' @return Posterior summary statistics (mean, mode, sd, 95% HPD interval) for
#'   all the Wasserstein barycenter of subset posteriors of all parameters in
#'   the model.
#'
#' @method summary wasp
#'
#' @examples
#' library(waspr)
#' out <- wasp(pois_logistic,
#'             par.names = c("beta_s", "alpha_l", "beta_l",
#'                           "baseline_sigma", "baseline_mu",
#'                           "correlation", "sigma_s", "sigma_l"))
#' summary(out)
#'
#' @export
#'

summary.wasp <- function(object){

  mean = colMeans(object$barycenter)
  sd = apply(object$barycenter, 2, sd)
  mode = apply(object$barycenter, 2, mode_est)
  hpd = apply(object$barycenter, 2, hpd_est)

  out = cbind(mean, mode, sd, t(hpd))

  colnames(out) = c("mean", "mode", "sd", "LB hpd", "UB HPD")
  rownames(out) = colnames(object$barycenter)

  return(out)

}

#' Print posterior summaries for the Wasserstein barycenter of subset posteriors
#'
#' Prints selected output from a Bayesian circular mixed-effects model.
#'
#' @param object a \code{wasp} object obtained from the function \code{wasp()}.
#' @param ... further arguments passed to or from other methods.
#'
#' @return A print of posterior summaries for the Wasserstein barycenter of subset posteriors
#'
#' @method print wasp
#'
#' @examples
#' library(waspr)
#' out <- wasp(pois_logistic,
#'             par.names = c("beta_s", "alpha_l", "beta_l",
#'                           "baseline_sigma", "baseline_mu",
#'                           "correlation", "sigma_s", "sigma_l"))
#' print(out)
#'
#' @export
#'

print.wasp <- function(object, ...){

  cat("\n\n")

  cat("WASP \n\n")

  cat("Call: \n",
      paste(deparse(x$call), sep = "\n", collapse = "\n"),
      "\n\n", sep = "")

  cat("MCMC: \n", paste("subsets = ", x$subsets, "\n",
                        "parameters = ", x$parameters, "\n",
                        "samples = ", x$samples,
                        sep = ""),
      "\n\n", sep = "")

  cat("Posterior summary of the Wasserstein Barycenter: \n")
  print(summary(x))
  cat("\n\n")

}
