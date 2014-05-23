#!/usr/bin/Rscript

drops <- c("filename")
pvt <- read.table('/data1/projects/psvu/analysis/pvt/pvt_psvu_features.csv', 
                   header = TRUE, sep=",")
pvt <- pvt[,!(names(pvt) %in% drops)]

pd <- read.table('/data1/projects/psvu/analysis/pd/pd_psvu_features.csv', 
                   header = TRUE, sep=",")

pd <- pd[,!(names(pd) %in% drops)]

mergeCols = c("subject", "block", "session", "block_number_1_5", "block_number_1_15");

features <- merge(pvt, pd, by=mergeCols)

write.table(features, file="/data1/projects/psvu/analysis/psvu_features.csv", sep=",", row.names=FALSE)
