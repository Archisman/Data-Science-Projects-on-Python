library(LaplacesDemon)

data(demonsnacks)
N <- nrow(demonsnacks)
y <- log(demonsnacks$Calories)
X <- cbind(1, as.matrix(log(demonsnacks[,c(1,4,10)]+1)))
J <- ncol(X)

for (j in 2:J) {X[,j] <- CenterScale(X[,j])}

mon.names <- "LP"
parm.names <- as.parm.names(list(beta=rep(0,J), sigma=0))

pos.beta <- grep("beta", parm.names)

pos.sigma <- grep("sigma", parm.names)

PGF <- function(Data) {
  beta <- rnorm(Data$J)
  sigma <- runif(1)
  return(c(beta, sigma))
  }

MyData <- list(J=J, PGF=PGF, X=X, mon.names=mon.names,parm.names=parm.names, pos.beta=pos.beta, pos.sigma=pos.sigma, y=y)


Model <- function(parm, Data)
  {
      ### Parameters
      beta <- parm[Data$pos.beta]
      sigma <- interval(parm[Data$pos.sigma], 1e-100, Inf)
      parm[Data$pos.sigma] <- sigma
      #Log-Prior
      beta.prior <- dnormv(beta, 0, 1000, log=TRUE)
      sigma.prior <- dhalfcauchy(sigma, 25, log=TRUE)
      ### Log-Likelihood
      mu <- tcrossprod(beta, Data$X)
      LL <- sum(dnorm(Data$y, mu, sigma, log=TRUE))
      ### Log-Posterior
      LP <- LL + sum(beta.prior) + sigma.prior
      Modelout <- list(LP=LP, Dev=-2*LL, Monitor=LP,
      yhat=rnorm(length(mu), mu, sigma), parm=parm)
      return(Modelout)
}

LP <- LL + sum(beta.prior) + sigma.prior
Modelout <- list(LP=LP, Dev=-2*LL, Monitor=LP,
                 yhat=rnorm(length(mu), mu, sigma), parm=parm)
return(Modelout)

beta <- parm[Data$pos.beta]
             sigma <- interval(parm[Data$pos.sigma], 1e-100, Inf)
             parm[Data$pos.sigma] <- sigma
             
             beta.prior <- dnormv(beta, 0, 1000, log=TRUE)
             sigma.prior <- dhalfcauchy(sigma, 25, log=TRUE)
             
          
             mu <- tcrossprod(Data$X, t(beta))
             LL <- sum(dnorm(Data$y, mu, sigma, log=TRUE))
                       LP <- LL + sum(beta.prior) + sigma.prior