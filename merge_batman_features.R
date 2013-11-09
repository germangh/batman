#!/usr/bin/Rscript

# HRV features
hrv <- read.table('hrv_features.csv', header=TRUE, sep=",")

# ABP features
abp <- read.table('abp_features.csv', header=TRUE, sep=",")

mergeCols = c("filename", "subject", "sub_block", "block_1_14", "cond_id", "cond_name")

features <- merge(hrv, abp, by=mergeCols)

write.table(features, file="hrv_abp_features.csv", sep=",", row.names=FALSE)
