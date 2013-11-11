#!/usr/bin/Rscript

hrv <- read.table('hrv_features.csv', header = TRUE, sep=",")
drops <- c("filename")
hrv <- hrv[,!(names(hrv) %in% drops)]

pvt <- read.table('pvt_features.csv', header = TRUE, sep=",")
pvt <- pvt[,!(names(pvt) %in% drops)]

pd <- read.table('pd_features.csv', header = TRUE, sep=",")
pd <- pd[,!(names(pd) %in% drops)]

abp <- read.table('abp_features.csv', header = TRUE, sep = ",")
abp <- abp[,!(names(abp) %in% drops)]

temp <- read.table('temp_features.csv', header = TRUE, sep = ",")
temp <- temp[,!(names(temp) %in% drops)]
temp <- temp[,!(names(temp) %in% c("selector"))]

mergeCols1 = c("subject", "condition1", "condition2", "meas", "block")
mergeCols2 = c(mergeCols1, "block_number_1_7", "block_number_1_21");

features <- merge(pvt, pd, by=mergeCols2)
features <- merge(features, hrv, by=mergeCols2)
features <- merge(features, abp, by=mergeCols2)
features <- merge(features, temp, by=mergeCols2)

write.table(features, file="pupillator_features.csv", sep=",", row.names=FALSE)
