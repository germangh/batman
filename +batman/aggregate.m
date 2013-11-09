% AGGREGATE - Aggregate all features across subjects/conditions

ANALYSIS_DIR = '/data1/projects/batman/analysis';

batman.abp.aggregate;

batman.hrv.aggregate;

currDir = pwd;
cd(ANALYSIS_DIR);
system('./merge_batman_features.R');
cd(currDir);

% These are raw (non-averaged) PVT features. This means that there is a ste
% of such features for each subject/sub-block and thus these cannot be
% merged in a single table together with the ABP and HRV features (which
% are scalar).
batman.pvt.aggregate;

% There are also multiple temp features for each sub-block/subject and thus
% these also have to be in a their own table
batman.temp.aggregate;

