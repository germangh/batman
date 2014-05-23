#!/usr/bin/Rscript

# HRV features
hrv <- read.table('/data1/projects/batman/analysis/hrv/hrv_features.csv', header=TRUE, sep=",")

# ABP features
abp <- read.table('/data1/projects/batman/analysis/abp/abp_features.csv', header=TRUE, sep=",")

mergeCols = c("filename", "subject", "sub_block", "block_1_14", "cond_id", "cond_name")

features <- merge(hrv, abp, by=mergeCols)

write.table(features, file="/data1/projects/batman/analysis/batman_features.csv", sep=",", row.names=FALSE)
