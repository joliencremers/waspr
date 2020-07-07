simulate_jm <- function(N, n_i,
                        covariance,
                        X, B_s, B_l,
                        log_baseline_mu,
                        baseline_sigma,
                        subsets){

  y_s = matrix(0, N, n_i) #matrix with event times (1 = event)
  y_l = matrix(NA, N, n_i) #matrix with dichotomous longitudinal outcome
  y_off = matrix(NA, N, n_i) #matrix with offset values

  offset = rep(NA, N) #helper vector for offset
  RR_t = rep(NA, n_i-1) #helper vector for baseline rates
  r_i = matrix(NA, N, 2)  #helper matrix for random intercept
  p = matrix(NA, N, n_i) #helper vector for individual probabilities

  #simulate raw baseline values (log level)
  log_baseline_raw = rnorm(n_i, 0, baseline_sigma)
  #simulate baseline values
  baseline = exp(rep(log_baseline_mu, n_i) + log_baseline_raw)
  #helper vector timepoints
  tau = seq(1, n_i, 1)

  #compute relative hazards
  for(t in 2:n_i){
    RR_t[t] <- baseline[t]/baseline[1]
  }

  RR_t[1] = 1

  LD <- matrix(0,nrow=n_i+1, ncol=n_i)
  LD[lower.tri(LD)]<-1


  # create subgroups for wasp
  groups <- split(1:N, sample(1:subsets, N, replace = TRUE))

  for(i in 1:N){

    r_i[i,] <- MASS::mvrnorm(1, mu =  c(0,0), Sigma = covariance)

    LS <- log(1-runif(1))
    GP <- as.vector(exp(X[i,1,-1]%*%B_s + r_i[i,1]) %*% RR_t)
    LSM <- -baseline[1] * as.vector(LD %*% GP)

    time = NA

    for(t in 1:n_i){

      time = ifelse(LSM[t]>=LS & LS>LSM[t+1], tau[t] + (LSM[t] - LS)/baseline[1]/GP[t], time)

      XB <- X[i,t,]%*%B_l + r_i[i,2]

      p[i,t] <- 1/(1 + exp(-XB))

      y_l[i,t] <- rbinom(1, size = 1, p = p[i,t])


    }

    offset[i] <- time - floor(time)

    y_s[i,floor(time)] <- 1

  }

  # format data
  data <- data.table(ID = rep(1:N, each = n_i),
                     time = rep(1:n_i, N),
                     status = as.vector(t(y_l)),
                     event = as.vector(t(y_s)),
                     intercept = as.vector(t(X[,,1])),
                     x = as.vector(t(X[,,2])),
                     offset = rep(offset, each = n_i))

  # compute lag and cumulative lag for event to remove individuals after event
  data[,event_lag:=c(NA, event[-.N]), by = ID]
  data[is.na(event_lag), event_lag:=0]
  data[,event_csum:=cumsum(event_lag), by = ID]
  data <- data[event_csum == 0]

  # correct offset
  data[event == 0, offset:=1]
  data[event != 0, offset:=offset]
  data[is.na(offset), offset:= 0]

  data <- data[, list(ID, time, status, event, intercept, x, offset)]

  # format data for stan
  data_stan <- list(N = nrow(data),
                    v_K = 1,
                    M_s = length(B_s),
                    M_l = length(B_l),
                    N_id = N,
                    Ti = n_i,
                    id = data$ID,
                    t = data$time,
                    event = data$event,
                    Y = data$status,
                    X_s = as.matrix(data$x),
                    X_l = cbind(data$intercept, data$x),
                    obs_t = data$offset)

  # set starting values
  start <- list(beta_s = rep(1, 1),
                beta_l = rep(1, 2),
                log_baseline = log(rep(2, n_i)),
                log_baseline_mu = 0,
                log_baseline_sigma = 1,
                sigma_id = rep(1, 2),
                z_id = matrix(1, nrow = 2, ncol = N))


  # Format groups

  sim_dat_grouped <- list()

  sim_dat_grouped[["stan_dat"]] <- rep(list(NULL), subsets)
  sim_dat_grouped[["start"]] <- rep(list(NULL), subsets)

  for(j in 1:subsets){

    # select subgroup

    data_group <- data[ID %in% groups[[j]], ]
    data_group[, ID_new := .GRP, by = ID]

    # format data for stan
    sim_dat_grouped[["stan_dat"]][[j]] <- list(N = nrow(data_group),
                                               v_K = 1,
                                               M_s = data_stan$M_s,
                                               M_l = data_stan$M_l,
                                               N_id = length(unique(data_group$ID_new)),
                                               Ti = data_stan$Ti,
                                               id = data_group$ID_new,
                                               t = data_group$time,
                                               event = data_group$event,
                                               Y = data_group$status,
                                               X_s = as.matrix(data_group$x),
                                               X_l = cbind(data_group$intercept, data_group$x),
                                               obs_t = data_group$offset)

    sim_dat_grouped[["start"]][[j]] <- start

  }




  return(list(data = data,
              groups = groups,
              sim_dat_grouped = sim_dat_grouped,
              stan_dat = data_stan,
              start = start,
              baseline = baseline))

}
