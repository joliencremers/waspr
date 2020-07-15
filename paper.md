---
affiliations:
- index: 1
  name: |
      Section of Biostatistics, Department of Public Health, University of
      Copenhagen
authors:
- affiliation: 1
  name: Jolien Cremers
  orcid: '0000-0002-0037-1747'
bibliography: 'paper.bib'
date: '7/7/2020'
output:
  md_document:
    pandoc_args: '--atx-headers'
    preserve_yaml: True
    variant: markdown
  pdf_document: default
tags:
- R
- Bayesian statistics
- Wasserstein barycenter
title: |
    waspr: an R package for computing Wasserstein barycenters of subset
    posteriors
---

# Summary

Wasserstein barycenters of subset posteriors (WASP) is a geometric
approach for combining subset posteriors and was introduced by
@Srivastava2015-hf as a method for scaleable Bayesian computation. The
idea behind using the Wasserstein barycenter is simple. Instead of
sampling from the posterior distribution using Markov Chain Monte Carlo
(MCMC), or other methods on the entire dataset, the data is split into
several subsets from which samples from the posterior are obtained. The
samples from the subset posteriors are then combined into one estimate
of the full posterior using the Wasserstein barycenter. This is
advantageous in case of big data, as MCMC algorithms often take a long
time to converge, especially in case of complex models and/or big
datasets. The WASP setup allows for parallel and distributed
computation, thereby increasing computational speed tremendously.

WASP is not the only scaleable Bayesian method. It is one of a set of
scaleable Bayesian methods that obtains subset posteriors using some
sampling algorithm and subsequently combines them into a single sample
from the full data posterior. Three other scaleable methods for subset
posteriors, averaging, Consensus Monte Carlo [@Scott2016-wu], and
semiparametric density product estimators [@Neiswanger2013-nk], were
implemented in the `R`-package `parallelMCMCcombine`. This package is
however not actively maintained and was removed from `CRAN` as it was
not maintained anymore. Moreover, @Srivastava2018-zw, shows that WASP
obtains better approximations of the full data posterior than other
methods for subset posteriors.

Wasserstein barycenters can be estimated using several techniques. The
`R`-package `Barycenter` implements the Sinkhorn algorithm developed by
@Cuturi2013-uh and @Cuturi2014-nk that can be used to estimate the
Wasserstein barycenter. More recently however, @Puccetti2017-zl
developed the swapping algorithm of which an iterated version can be
used to estimate the Wasserstein barycenter and which shows improvements
in computational speed over the methods developed in @Cuturi2014-nk
[@Puccetti2020-es].

The new `R`-package `waspr` implements the swapping algorithm to
estimate the Wasserstein barycenter of subset posteriors.

# Statement of Need

The purpose of `waspr` is to:

-Provide a fast method to approximate the Wasserstein barycenter of
subset posteriors and other empirical measures to `R`-users.

# Example Usage

To use `waspr` the user first needs to load the package as follows:

``` {.r}
library(waspr)
```

The user must provide a 3-dimensional array with posterior samples for
all parameters for each subset posterior (rows = subset posteriors,
columns = parameters, slices = samples). The amount of parameters and
samples must be equal for each subset posterior, but these posterior
samples may be obtained from any type of MCMC algorithm. `waspr`
provides an example array with posterior samples for 8 parameters for 8
subset posteriors, `pois_logistic`, that will be used to illustrate the
functionality of the package.

The main function `wasp()` runs the swapping algorithm developed by
@Puccetti2017-zl combines its output and computes the Wasserstein
barycenter. It has four arguments, `mcmc`, that specifies the
3-dimensional array with samples for each subset posterior, and optional
arguments `par.names`, that can be used to specify parameter names,
`iter` to specify the maximum number of iterations of the swapping
algorithm and `acc` to specify the accuracy of the swapping algorithm.

``` {.r}
out <- wasp(pois_logistic,
           iter = 10,
           acc = 0.001,
           par.names = c("beta_s", "alpha_l", "beta_l",
                         "baseline_sigma", "baseline_mu",
                         "correlation", "sigma_s", "sigma_l"))
```

`wasp()` prints the iteration number and cost function value of the
swapping algorithm. The `out` object is of class `wasp` and contains
several elements. To obtain the Wasserstein barycenter of the subset
posteriors a user can specify `out$barycenter`. This returns a matrix of
posterior samples (rows) for all parameters (columns) of the full data
posterior. A summary of the approximation of the full data posterior is
available through `summary(out)`.

``` {.r}
summary(out)
```

    ##                      mean       mode         sd      LB HPD     UB HPD
    ## beta_s          0.5527601  0.5518034 0.10988949  0.36598187  0.7896041
    ## alpha_l         2.6811079  2.6959176 0.19199304  2.30380675  3.0295802
    ## beta_l          0.7508520  0.7339988 0.21631011  0.37281283  1.1740767
    ## baseline_sigma  0.3563222  0.3811609 0.06859910  0.21910807  0.4870079
    ## baseline_mu    -0.8008872 -0.7516167 0.10867533 -1.01168299 -0.5944583
    ## correlation     0.1732170  0.1392670 0.07437737  0.02824474  0.3059979
    ## sigma_s         1.7225455  1.7535499 0.17920847  1.40126462  2.0610585
    ## sigma_l         1.2190297  1.2612822 0.07558163  1.06768047  1.3569757

# Acknowledgements

JC is supported for this work by a research grant from the Novo Nordisk
Foundation ("Harnessing The Power of Big Data to Address the Societal
Challenge of Aging." NNF17OC0027812)

# References {#references .unnumbered}
