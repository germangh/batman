function ftripStruct = ft_freqanalysis_aggregate(DIR)
% ft_freqanalysis_aggregate
% ====
%
% Aggregate .meegpipe results into a structure suitable for analysis with
% Fieldtrip's ft_freqanalysis
%
% ## Usage synopsis
%
% ````matlab
% rDir = '/data1/projects/batman/analysis/cleaning';
% subj = [1, 3:5, 10];
% [ftripStruct, cond] = ft_freqanalysis_aggregate(rDir, subj)
% ````
%
% Where
%
% `rDir` is the root directory where the .meegpipe results are stored.
%
% `subj` is a numeric array of subject IDs. Only these subjects will be
% considered in the aggregation.
%
% `ftripStruct` is a 2x2x2 cell array with Fieltrip structures that may be
% introduced into `ft_freqanalysis`.
%
% `cond` is a 2x2x2 cell array with condition IDs as described by 
% `batman.block2condition`.
%
% 
% See also: batman.block2condition




end