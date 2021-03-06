% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ego_tergm.R
\name{ego_tergm}
\alias{ego_tergm}
\title{Estimation of ego-Temporal Exponential Random Graph Model (ego-TERGM) using Expectation Maximization (EM).}
\usage{
ego_tergm(net = NULL, form = NULL, core_size = 1, min_size = 5,
  roles = 3, add_drop = TRUE, directed = TRUE,
  edge_covariates = FALSE, seed = 12345, R = 10, forking = FALSE,
  ncpus = 1, steps = 50, tol = 1e-06)
}
\arguments{
\item{net}{The longitudinally observed network that an ego-TERGM will be fit on.  Must be presented as a list of networks.  Any vertex attributes should be attached to networks.  Currently the function does not support comparisons of whole networks.}

\item{form}{The formula comprised of ERGM or TERGM terms used to distinguish between clusters assignments.  Specified as a vector of comma separated terms. No default.}

\item{core_size}{The order of alters to include. The default value of one implies only looking at an ego's alters and the connections among them.}

\item{min_size}{The minimum number of nodes an ego-network must achieve to be included.  Defaults to five.}

\item{roles}{The number of roles that should be fit.  Defaults to 3.}

\item{add_drop}{Do nodes drop out of the network or enter it? If so, specify as the default TRUE.}

\item{directed}{Should the longitudinal network be treated as directed? If so, specify as the default TRUE.}

\item{edge_covariates}{Are edge covariates included in the form term? IF so, specify as TRUE.  No default.  These should be stored as network attributes.}

\item{seed}{The seed set to replicate analysis for pseudorandom number generator.}

\item{R}{The number of bootstrap replications that should be used for the estimation of a bootstrapped MPLE estimated TERGM for model initialization.  Defaults to 10.}

\item{forking}{If parallelization via forking should be used (TRUE) or if no parallel processing should be used (FALSE).  Currently, sockets are not supported.}

\item{ncpus}{The number of CPUs that should should be used for estimation, defaults to 1.}

\item{steps}{The number of default EM steps that should be taken, defaults to 50.}

\item{tol}{The difference in parameter estimates between EM iterations to determine if the algorithm has converged.  Defaults to 1e-6.}
}
\value{
A list of model results and input values, including net (original networks), lambda (the probability of assignments), group.theta (the roles by terms cluster centroids),
        EE.BIC (the Salter-Townshend and Murphy BIC cross-sectional BIC), TS.BIC (the Campbell BIC penalizing for time-steps),
       role_assignments (a data frame of the most likely assignments), reduced_networks (A list of the networks with excluded egos),
       ego_nets (a list of ego-networks), and ego_nets_used (N x T matrix of logicals here TRUE refers to ego-networks kept).
}
\description{
This function estimates an ego-TERGM on a longitudinally observed network.  Currently the function does not support comparisons of whole networks.
}
\examples{
\donttest{
# Code from xergm.common and their preparation of the Knecht network
library(xergm.common)
set.seed(1)

data("knecht")

for (i in 1:length(friendship)) {
 rownames(friendship[[i]]) <- paste("Student.", 1:nrow(friendship[[i]]), sep="")
 colnames(friendship[[i]]) <- paste("Student.", 1:nrow(friendship[[i]]), sep="")
}
rownames(primary) <- rownames(friendship[[1]])
colnames(primary) <- colnames(friendship[[1]])
sex <- demographics$sex
names(sex) <- rownames(friendship[[1]])
# step 2: imputation of NAs and removal of absent nodes:
friendship <- xergm.common::handleMissings(friendship, na = 10, method = "remove")
friendship <- xergm.common::handleMissings(friendship, na = NA, method = "fillmode")
# step 3: add nodal covariates to the networks
for (i in 1:length(friendship)) {
  s <- xergm.common::adjust(sex, friendship[[i]])
  friendship[[i]] <- network::network(friendship[[i]])
  friendship[[i]] <- network::set.vertex.attribute(friendship[[i]], "sex", s)
  idegsqrt <- sqrt(sna::degree(friendship[[i]], cmode = "indegree"))
  friendship[[i]] <- network::set.vertex.attribute(friendship[[i]],
                                                   "idegsqrt", idegsqrt)
  odegsqrt <- sqrt(sna::degree(friendship[[i]], cmode = "outdegree"))
  friendship[[i]] <- network::set.vertex.attribute(friendship[[i]],
                                                   "odegsqrt", odegsqrt)
}
sapply(friendship, network::network.size)
net <- friendship
rm(list=setdiff(ls(), "net"))

ego_tergm_fit <- ego_tergm(net = net,
                          form = c("edges", "mutual", "triangle",
                                   "nodeicov('idegsqrt')", "nodeocov('odegsqrt')",
                                   "nodematch('sex')"),
                          core_size = 1,
                          min_size = 5,
                          roles = 3,
                          add_drop = TRUE,
                          directed = TRUE,
                          edge_covariates = FALSE,
                          seed = 12345,
                          R = 10,
                          forking = FALSE,
                          ncpus = 1,
                          steps = 50,
                          tol = 1e-06)
}
}
\references{
{
 Campbell, Benjamin W. (2018):
 Inferring Latent Roles in Longitudinal Networks.
 \emph{Political Analysis} 26(3): 292-311.  \url{https://doi.org/10.1017/pan.2018.20}

 Leifeld, Philip, Skyler J. Cranmer and Bruce A. Desmarais (2017):
 Temporal Exponential Random Graph Models with btergm: Estimation and Bootstrap Confidence Intervals.
  \emph{Journal of Statistical Software} 83(6): 1-36. \url{http://dx.doi.org/10.18637/jss.v083.i06}
}
}
\keyword{ego-TERGM}
