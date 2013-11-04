#!/usr/bin/Rscript

hrv <- read.table('hrv_features.csv', header = TRUE, sep=",")
names(hrv)[names(hrv) == 'eventset'] <- 'block'
drops <- c("filename")
hrv <- hrv[,!(names(hrv) %in% drops)]

pvt <- read.table('pvt_features.csv', header = TRUE, sep=",")
pvt <- pvt[,!(names(pvt) %in% drops)]

pd <- read.table('pd_features.csv', header = TRUE, sep=",")
pd <- pd[,!(names(pd) %in% drops)]

mergeCols1 = c("subject", "condition1", "condition2", "meas", "block")
mergeCols2 = c(mergeCols1, "block_number_1_7", "block_number_1_21");

features <- merge(pvt, pd, by=mergeCols2)
features <- merge(features, hrv, by=mergeCols1)

write.table(features, file="pupillator_features.csv", sep=",", row.names=FALSE)
