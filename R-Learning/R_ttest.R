#Repeat same Analysis Across Groups
library(dplyr)
library(broom)

set.seed(9)

# example dataset
dt = data.frame(species = c(rep("ARGAFF",6), rep("BATABY",6)),
                region = rep(c("EQ","OMZ"),6),
                N15 = rnorm(12,10,1))


dt_result = dt %>% group_by(species) %>% do(tidy(t.test(N15~region, data=.)))

dt_result