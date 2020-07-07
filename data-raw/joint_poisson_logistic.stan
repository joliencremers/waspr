data {
  // dimensions data
  int<lower=1> N; // Number of observations
  int<lower=1> N_id; // Number of respondents
  int<lower=1> Ti; // max timepoint (number of timepoint ids)
  int<lower=1> M_l; // Number of covariates
  int<lower=1> M_s; // Number of covariates
  
  // data matrix survival + multinomial
  int<lower=1, upper=N_id> id[N]; // sample id for each observation
  int<lower=1, upper=Ti> t[N]; // timepoint id for each observation
  int<lower=0, upper=1> event[N]; // 1: event, 0: censored at time t for sample s
  matrix[N, M_s] X_s; // explanatory variables (fixed effects)
  matrix[N, M_l] X_l; // explanatory variables (fixed effects)
  vector[N] obs_t; // observed end time for interval for timepoint for that obs
  int<lower=0, upper = 1> Y[N]; // states
  
}

transformed data {
  
  vector[N] log_obs_t;
  log_obs_t = log(obs_t);

}

parameters {
  
  vector[Ti] log_baseline_raw; // unstructured baseline hazard for each timepoint t
  real<lower = 0> baseline_sigma;
  real log_baseline_mu;
  
  vector[M_l] beta_l; // coefficients fixed effects
  vector[M_s] beta_s; // coefficients fixed effects
  
  matrix[2, N_id] z_id; // matrix of standardized random effects
  vector<lower = 0>[2] sigma_id; // sd of random effects
  cholesky_factor_corr[2] L_Rho_id; // correlation matrix of random effects
}

model {
  
  vector[N] log_hazard;
  vector[N] X_beta_l = X_l*beta_l; 
  vector[N] X_beta_s = X_s*beta_s;
  matrix[N_id, 2] v_id; // matrix of scaled random effects
  
  v_id = (diag_pre_multiply(sigma_id, L_Rho_id) * z_id)';
  
  log_hazard = log_baseline_mu + log_baseline_raw[t] + X_beta_s + v_id[id, 2] + log_obs_t;


  //priors
  beta_s ~ normal(0,10000);
  to_vector(beta_l) ~ normal(0, 10000);

  //hyper-prior
  baseline_sigma ~ normal(0,1);
  log_baseline_mu ~ normal(0,1);
  log_baseline_raw ~ normal(0,baseline_sigma);

  to_vector(z_id) ~ normal(0,1);
  sigma_id ~ exponential(0.5);
  L_Rho_id ~ lkj_corr_cholesky(2);
  
  //likelihood survival
  event ~ poisson_log(log_hazard);//multiple indexing
  
  //likelihood longitudinal
  Y ~ bernoulli_logit(X_beta_l + v_id[id, 1]);
}

generated quantities {
 
  matrix[2, 2] Rho_id;  //correlations random effects
  vector[Ti] baseline;
  
  Rho_id = L_Rho_id * L_Rho_id';
  baseline = exp(log_baseline_raw + log_baseline_mu);
  
}
