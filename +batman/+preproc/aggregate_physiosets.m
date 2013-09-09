function [data, condID, condNames] = ...
    aggregate_physiosets(varargin)
% aggregate_physiosets
% ====
%
% Aggregates physiosets according to experimental conditions
%
% ## Usage synopsis
%
% ````matlab
% rDir = '/data1/projects/batman/analysis/cleaning';
% subj = [1, 3:5, 10];
% [physArray, condID, condNames] = ...
%       ft_aggregate('DataPath', rDir, 'Subjects', subj)
% ````
%
% Where
%
% `rDir` is the root directory where the .meegpipe results are stored.
%
% `subj` is a numeric array of subject IDs. Only these subjects will be
% considered in the aggregation.
%
% `physArray` is a 2x2x2 cell array. Each cell corresponds to a given 
% experimental condition and contains all physioset objects that are 
% associated with that condition.
%
% `cond` is a 2x2x2 cell array with condition IDs as described by 
% `batman.block2condition`.
%
% 
% See also: batman

import mperl.file.find.finddepth_regex_match;
import mperl.join;
import batman.*;
import meegpipe.node.*;
import misc.eta;
import misc.process_arguments;
import mperl.file.spec.catfile;

opt.Verbose  = true;
opt.Subjects = [];
opt.DataPath   = '/data1/projects/batman/analysis/cleaning';

[~, opt] = process_arguments(opt, varargin);

if isempty(opt.Subjects),
    subjRegex = '';
else
    subjRegex = ['_0+(' join('|', opt.Subjects) ')_'];
end

verboseLabel = '(ft_freqanalysis_aggregate) ';
regex = [subjRegex '.+_cleaning.pseth$'];
files = finddepth_regex_match(opt.DataPath, regex);

[condID, condNames] = conditions();

data = cell(size(condNames));
data = cellfun(@(x) {}, data, 'UniformOutput', false);

if opt.Verbose,
   fprintf([verboseLabel 'Aggregating %d files ...'], numel(files)); 
   tinit = tic;
end
for fileItr = 1:numel(files) 
    regex = '_0+(?<subj>\d+)_.+_rs_(?<block>\d+)_';
    match = regexp(files{fileItr}, regex, 'names');
    thisBlock = str2double(match.block);
    thisSubj  = str2double(match.subj);
    thisCondID = block2condition(thisSubj, thisBlock);
    idx = ismember(condID, thisCondID);
    data{idx} = [data{idx} files(fileItr)];
    if opt.Verbose,
        misc.eta(tinit, numel(files), fileItr, 'remaintime', true);
    end
end
if opt.Verbose, fprintf('\n\n'); end

if opt.Verbose,
   fprintf([verboseLabel 'Aggregation statistics:\n\n']);
   for i = 1:numel(data)
      fprintf('%20s : %d datasets\n', condNames{i}, numel(data{i})); 
   end
   fprintf('\n');
end

end