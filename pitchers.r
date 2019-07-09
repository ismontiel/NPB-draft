# Preliminary setup stuff
setwd("C:/Users/Israel/Google Drive/Research/Data/R Directory")
library(tidyverse)
library(readxl)
library(dplyr)
AllPitchers <- read_excel("All_P.xlsx")
head(AllPitchers)

# So unfortunately, I think that innings is a poor determinant of salary (at least this simple estimate) bc
# different types of pitchers are expected to put out differently. Games will have to do
summary(AllPitchers)    # Median games: 16 so let's do 10 lmao

#Variabels
AllPitchers <- AllPitchers %>% group_by(name) %>% mutate(gExp = cumsum(G))      # Cumulative games played through the years
AllPitchers$BBIP <- AllPitchers$BB / AllPitchers$IP
AllPitchers$HRIP <- AllPitchers$HR / AllPitchers$IP
AllPitchers$KIP <- AllPitchers$K / AllPitchers$IP
AllPitchers$expSQ <- AllPitchers$gExp^2

#DF Modifications
TenGamesP <- AllPitchers[!(AllPitchers$G < 10),]     # n = 1155
ThirtyGamesP <- AllPitchers[!(AllPitchers$G < 30),]  # n = 416

FirstThreeP <- TenGamesP[!(TenGamesP$year >= 2014),]
LastTwoP <- TenGamesP[!(TenGamesP$year < 2014),]
EvenYearsP <- TenGamesP %>% filter(year != 2011, year != 2013, year != 2015)

# Simple Pitcher Responsibility Model
summary(resp1 <- lm(log(salary) ~ G + W + L + S + SO + Hld+ BB + K + HR + gExp + expSQ, data = EvenYearsP))
    # HR, G, SO experience measures insignificant; R^2 ~ .266

# PRM per Inning Pitched
summary(respIP <- lm(log(salary) ~ G + S + SO + Hld + W + L + BBIP + KIP + HRIP + gExp + expSQ, data = EvenYearsP))
    # All IP vars less sig than total model, expereince & HR still not sig; SPRM prob

# WHIP the PRM
summary(respWHIP <- lm(log(salary) ~ G + W + L + WHIP + HRIP + gExp + expSQ, data = EvenYearsP))
    # WHIP insig; PRM better

# Partial pitcher responsibility model
summary(pResp <- lm(log(salary) ~ G + S + SO + Hld + W + L + BB + K + ERA + H + ER, data = EvenYearsP))
    # G now sig with only real sig pitching factor is BB
    # Wins sig @ 10% and have been consistently underperforming. What if remove?

# PPRM part II
summary(pResp2 <- lm(log(salary) ~ G + S + Hld + L + BB + K + ERA + H, data = EvenYearsP))
    # H become significant really just when ER is removed; L and ERA insig
summary(resp2 <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + ERA, data = EvenYearsP))
    # G sig @ 10%; no ERA
    # Could be good comparison moodel against pResp2 

# Testing clean combination model
summary(pComb <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + H, data = EvenYearsP))
    # W sig @ 10%, L insig

# Testing combination of competing models with diff data
summary(pComb <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + ERA + H, data = FirstThreeP))
    # Wins becomes more significant while making H insig. ERA still no. Remove?
pComb <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + H, data = FirstThreeP)    # Cleaning up ERA

# Testing the competing models separately
summary(pResp2 <- lm(log(salary) ~ G + S + Hld + L + BB + K + H, data = FirstThreeP))
    # L insig at all levels again. Remove? (ERA tested, insig)
summary(resp2 <- lm(log(salary) ~ G + S + Hld + W + L + BB + K, data = FirstThreeP))
    # All except ERA sig so removed

anova(pResp2, pComb)    # Combination model better than no W
anova(resp2, pComb)     # Combination model better than no H


# Team & League Controls
# Combination model
summary(combTeam <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + H + team1 + team2 + team3 + team4
                        + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = EvenYearsP))
    # W and K (???) insig. Several teams are too
summary(pResp2Team <- lm(log(salary) ~ G + S + Hld + BB + K + H + team1 + team2 + team3 + team4
                    + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = EvenYearsP))
    # Several teams are still insig, but everything else is still cool
summary(resp2Team <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + team1 + team2 + team3 + team4
                        + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = EvenYearsP))
    # All non-team vars are sig, but G is a little shaky

# Testing team with different dataset
summary(combTeam <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + H + team1 + team2 + team3 + team4
                       + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = FirstThreeP))
    # K still insig, and now teams are also looking less sig
summary(pResp2Team <- lm(log(salary) ~ G + S + Hld + BB + K + H + team1 + team2 + team3 + team4
                         + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = FirstThreeP))
    # Same, everything sig except teams
    # Gonna tentatively go with this model
summary(resp2Team <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + team1 + team2 + team3 + team4
                        + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = FirstThreeP))
    # All non-team vars are sig with G back at 1%. Teams look super shaky


# 
# # Testing with super sample
# summary(combTeam <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + H + team1 + team2 + team3 + team4
#                        + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = TenGamesP))
#     # K still insig
# summary(pResp2Team <- lm(log(salary) ~ G + S + Hld + BB + K + H + team1 + team2 + team3 + team4
#                          + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = TenGamesP))
#     # All non-team sig
# summary(resp2Team <- lm(log(salary) ~ G + S + Hld + W + L + BB + K + team1 + team2 + team3 + team4
#                         + team5 + team6 + team7 + team8 + team9 + team10 + team11, data = TenGamesP))
