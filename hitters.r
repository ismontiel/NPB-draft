# Preliminary setup stuff
setwd("C:/Users/Israel/Google Drive/Research/Data/R Directory")
library(tidyverse)
library(readxl)
library(dplyr)
AllHitters <- read_excel("All_H.xlsx")
head(AllHitters)
summary(AllHitters)

#Variables
AllHitters <- AllHitters %>% group_by(name) %>% mutate(abExp = cumsum(AB))      # Cumulative ABs through the years
AllHitters <- AllHitters %>% mutate(RPG = R/G)
AllHitters <- AllHitters %>% mutate(HPG = H/G)
AllHitters <- AllHitters %>% mutate(KPG = K/G)
AllHitters <- AllHitters %>% mutate(SBPG = SB/G)
AllHitters <- AllHitters %>% mutate(BBPG = BB/G)
AllHitters$xBase <- AllHitters$dou + AllHitters$tri + AllHitters$HR
AllHitters$abExpSQ <- AllHitters$abExp^2

# DF modifications
FiftyAB <- AllHitters[!(AllHitters$AB<50),]
FirstThreeHH <- FiftyAB[!(FiftyAB$year >= 2014),]
LastTwoH <- FiftyAB[!(FiftyAB$year < 2014),]

EvenYearsH <- FiftyAB %>% filter(year != 2011, year != 2013, year != 2015)

###

# Basic, no team/year control models
summary(simp1 <- lm(log(salary) ~ AB + abExp + OBP, data = EvenYearsH))

# Basic with pretty much everything
summary(simpA <- lm(log(salary) ~ AB + OPS + R + H + HR + BB + xBase + RBI + SB + HBP + K + SF + avg, data = EvenYearsH))
    # Suprisingly, OPS and avg were insignificant. Unsurprisingly, so were SF, HBP
summary(simpB <- lm(log(salary) ~ AB + OPS + HR + SB + R + H + BB + RBI + K, data = EvenYearsH))
    # Because I couldn't let go of the OPS and SB
summary(trash1 <- lm(log(salary) ~ AB + OPS + SB + avg, data = EvenYearsH))
    # Everything significant in this model
summary(simp1 <- lm(log(salary) ~ AB + OPS + SB + RBI + avg, data = EvenYearsH))
    # But then you add RBI and everything goes to shit
anova(trash1, simp1)
    # anova says that the RBI model is better and I guess that makes sense since the hits are more valuable
summary(simpB <- lm(log(salary) ~ AB + OPS + HR + SB + R + H + BB + RBI + K + abExp, data = EvenYearsH))
    # "Experience really just strengthens the trimmed model with everything in it
summary(simpExp <- lm(log(salary) ~ AB + HR + R + H + BB + RBI + K + abExp, data = EvenYearsH))

summary(simpExpS <- lm(log(salary) ~ AB + HR + R + H + BB + RBI + K + abExp + abExpSQ, data = EvenYearsH))
    #The data do show significant diminishing returns to experience so we'll keep it, but very small
anova(simpExp, simpExpS)

###

# Replacing basic model with per-game stats
summary(simpPG <- lm(log(salary) ~ AB + HR + RPG + HPG + BBPG + RBI + KPG + abExp + abExpSQ + OPS, data = EvenYearsH))
    # Now, hits (pg) and AB are no longer significant, but OPS is
xBasePG <- EvenYearsH$xBase / EvenYearsH$G
summary(simpPG <- lm(log(salary) ~ SBPG + BBPG + RBI + KPG + abExp + abExpSQ + OPS, data = EvenYearsH))
    # Moving some shit around, I got this model which gives me pretty comparable output stats
    # I actually like this model a little more conceptually
    # Nope on xBase, HR, RPG

# Testing with FirstThreeHH
summary(simpExpS <- lm(log(salary) ~ AB + HR + R + H + BB + RBI + K + abExp + abExpSQ, data = FirstThreeH))
    # Hits and RBIs insignificant
summary(simpPG <- lm(log(salary) ~ SBPG + BBPG + RBI + KPG + abExp + abExpSQ + OPS, data = FirstThreeH))
    # KPG insignificant

# Testing with Last Two
summary(simpExpS <- lm(log(salary) ~ AB + HR + R + H + BB + RBI + K + abExp + abExpSQ, data = LastTwoH))
    # AB @ 5%, hits RBI and K insignificant
summary(simpPG <- lm(log(salary) ~ SBPG + BBPG + RBI + KPG + abExp + abExpSQ + OPS, data = LastTwoH))
    # KPG 5%, RBI OPS insignificant

###

# Only team controls
summary(reg2 <- lm(log(salary) ~ team1 + team2 + team3 + team4 + team5 + team6
                   + team7 + team8 + team9 + team10 + team11, data = AllHitters))

# With Team controls (Yomiuri is the default)
simpleTeam <- lm(log(salary) ~ AB + HR + R + H + BB + RBI + K + abExp + abExpSQ + team1 + team2 + team3 + team4
                 + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = EvenYearsH)
summary(simpleTeam)
    # Hits are shown not to be significant? Some teams (3,4,9) also aren't

perGameTeam <- lm(log(salary) ~ SBPG + BBPG + RBI + KPG + abExp + abExpSQ + OPS + team1 + team2 + team3 + team4
                 + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = EvenYearsH)
summary(perGameTeam)
    # Some teams shown insignificant (3,4), but everything else is pretty strong

# Testing with FirstThreeH
simpleTeam <- lm(log(salary) ~ AB + HR + R + H + BB + RBI + K + abExp + abExpSQ + team1 + team2 + team3 + team4
                 + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = FirstThreeH)
summary(simpleTeam)
    # Same significance as EvenYearsH
perGameTeam <- lm(log(salary) ~ SBPG + BBPG + RBI + KPG + abExp + abExpSQ + OPS + team1 + team2 + team3 + team4
                  + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = FirstThreeH)
summary(perGameTeam)
    # Now, KPG is not significant at all

# Okay, so I think it's fine to determine that the 'simple' model is not as good as the per-game model

# Testing with LastTwoH
perGameTeam <- lm(log(salary) ~ SBPG + BBPG + RBI + KPG + abExp + abExpSQ + OPS + team1 + team2 + team3 + team4
                  + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = LastTwoH)
summary(perGameTeam)
    # Now RBI and OPS along with some teams go down in significance

#Massaging the perGameModel, it seems like K totals turn the model to significance over KPG:
#Subsituting K for KPG:
perGameTeam <- lm(log(salary) ~ SBPG + BBPG + RBI + K + abExp + abExpSQ + OPS + team1 + team2 + team3 + team4
                  + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = EvenYearsH)
summary(perGameTeam)
    # All nonteam shit sig

# Testing with FirstThreeH
perGameTeam <- lm(log(salary) ~ SBPG + BBPG + RBI + K + abExp + abExpSQ + OPS + team1 + team2 + team3 + team4
                  + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = FirstThreeH)
summary(perGameTeam)
    # All nonteam shit sig

#Testing with LastTwoH
perGameTeam <- lm(log(salary) ~ SBPG + BBPG + RBI + K + abExp + abExpSQ + OPS + team1 + team2 + team3 + team4
                  + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = LastTwoH)
summary(perGameTeam)
    # Yikes, K and OPS STILL insig (RBI sig now)
    # Seems llike there LastTwoH really hates OPS in this model :thinking:



#   #   #   #   #
# Testing R Stuff #
#   #   #   #   #

# The following is to add a column counting the number of occurences of a player's name
# Will be used to determine experience
#Problem if a player switches teams midseason and I get a duplicate occurance for a year
lmao <- AllHitters
lmao <- lmao %>% group_by(name) %>% mutate(count = sequence(n()))

# Would it be better if instead of years exp, I use experience in terms of major leage ABs?
lmao <- lmao %>% group_by(name) %>% mutate(count = cumsum(AB))

#Testing if I can eliminate the above problem by grouping by name and year
test <- AllHitters
test <- test %>%group_by(year, name)
test <- lmao %>% mutate(count = sequence(n()))
# Nope lmao
summary(test)
rename(test, "exp" = "count")
