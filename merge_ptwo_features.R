#!/usr/bin/Rscript

drops <- c("filename")
pvt <- read.table('/data1/projects/ptwo/analysis/pvt/pvt_ptwo_features.csv',
                   header = TRUE, sep=",")
pvt <- pvt[,!(names(pvt) %in% drops)]

pd <- read.table('/data1/projects/ptwo/analysis/pd/pd_ptwo_features.csv',
                   header = TRUE, sep=",")

pd <- pd[,!(names(pd) %in% drops)]

mergeCols = c("subject", "block", "protocol", "block_number_1_11",
"block_number_1_33");

features <- merge(pvt, pd, by=mergeCols)

write.table(features, file="/data1/projects/ptwo/analysis/ptwo_features.csv", sep=",", row.names=FALSE)
