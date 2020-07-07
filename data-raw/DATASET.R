## code to prepare `pois_logistic` dataset

# library(rstan)
# library(abind)
# library(data.table)
# library(foreach)
source("data-raw/simulate.R")

N = 1000 # Number of individuals
n_i = 15 # Number of timepoints

# Covariates
X = array(NA, dim = c(N, n_i, 2))
x <- rbinom(N, 1, 0.5)

for(i in 1:n_i){
  X[,i,1] <- rep(1, N)
  X[,i,2] <- x
}

# Covariance
covariance = cbind(c(1,0.5), c(0.5,2))
D <- diag(sqrt(diag(covariance)))
invD = solve(D)
correlation = invD %*% covariance %*% invD

# Baseline specification
log_baseline_mu = -1
baseline_sigma = 0.3

# Coefficients
B_s = 0.5
B_l = c(2.5,0.5)

subsets <- 8

sim_dat <- simulate_jm(N, n_i,
                       covariance,
                       X, B_s, B_l,
                       log_baseline_mu,
                       baseline_sigma,
                       subsets)

acomb <- function(...) abind(..., along = 3)

mod <- stan_model(file = "data-raw/joint_poisson_logistic.stan")

sequence <- rep(1:subsets, each = 3)
vec_chain_id <- rep(1:3, subsets)

res <- foreach (j = 1:length(sequence), .packages = "rstan", .errorhandling = "pass", .verbose = TRUE) %do% {

  # Start sampling
  stan_res <- sampling(object = mod,
                       data = sim_dat[["sim_dat_grouped"]][["stan_dat"]][[sequence[j]]],
                       iter = 100,
                       warmup = 50,
                       thin = 1,
                       save_warmup = FALSE,
                       chains = 3,
                       pars = c("beta_s", "beta_l",
                                "baseline",
                                "baseline_sigma",
                                "log_baseline_mu",
                                "Rho_id",
                                "sigma_id"),
                       include = TRUE,
                       chain_id = vec_chain_id[j],
                       seed = 101,
                       refresh = 0)


}

results <- foreach (s = seq(1, subsets*3, by = 3),
                    .combine = "acomb",
                    .multicombine = TRUE,
                    .packages = "rstan",
                    .errorhandling = "pass",
                    .verbose = TRUE) %do% {

                      # Combine and save results
                      result <- sflist2stanfit(list(res[[s]], res[[s+1]], res[[s+2]]))

                      # Extract samples for individual parameters
                      r_beta_s = extract(result, pars='beta_s')$beta_s
                      r_beta_l = extract(result, pars='beta_l')$beta_l
                      r_baseline_mu = extract(result, pars = 'log_baseline_mu')$log_baseline_mu
                      r_baseline_sigma = extract(result, pars = 'baseline_sigma')$baseline_sigma
                      r_rho = extract(result, pars = 'Rho_id')$Rho_id
                      r_sigma = rstan::extract(result, pars = 'sigma_id')$sigma_id

                      # Combine all parameters
                      result_comb <- t(cbind(r_beta_s, r_beta_l,
                                             r_baseline_sigma, r_baseline_mu,
                                             r_rho[,2,1], r_sigma))
}

pois_logistic <- aperm(results, c(3,1,2))

usethis::use_data(pois_logistic, overwrite = TRUE)
