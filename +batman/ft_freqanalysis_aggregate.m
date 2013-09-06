function [ftripStruct, condID, condNames] = ...
    ft_freqanalysis_aggregate(rootDir, subjIDs)
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

import mperl.file.find.finddepth_regex_match;
import mperl.join;
import batman.*;
import meegpipe.node.*;

if nargin < 2,
    subjIDs = [];
end

if isempty(subjIDs),
    subjRegex = '';
else
    subjRegex = ['_0+(' join('|', subjIDs) ')_'];
end

regex = [subjRegex '.+_cleaning.pseth$'];
files = finddepth_regex_match(rootDir, regex);

[condID, condNames] = conditions();

data = cell(size(condNames));
data = cellfun(@(x) {}, data, 'UniformOutput', false);
mySel =  pset.selector.sensor_class('Class', 'EEG');
myNode = chan_interp.new('GenerateReport', false, 'Save', false, 'OGE', false);
set_verbose(myNode, false);
for fileItr = 1:numel(files)
    [~, name] = fileparts(files{fileItr});
    fprintf('Aggregating %s ...', name);
    regex = '_0+(?<subj>\d+)_.+_rs_(?<block>\d+)_';
    match = regexp(files{fileItr}, regex, 'names');
    thisBlock = str2double(match.block);
    thisSubj  = str2double(match.subj);
    thisCondID = block2condition(thisSubj, thisBlock);
    idx = ismember(condID, thisCondID);
    thisData = pset.load(files{fileItr});
    run(myNode, thisData);
    select(mySel, thisData);
    data{idx} = [data{idx} {thisData}];
    fprintf('[done]\n\n');
end

ftripStruct = cell(size(data));
for i = 1:numel(data)
    fprintf('Converting to fieldtrip condition %s datasets ...', ...
        condNames{i});
    this = data{i};
    if isempty(this), 
        fprintf('[no datasets: skipped]\n\n');
        continue; 
    end
    ftripStruct{i} = fieldtrip(this{:}, 'BadData', 'donothing');
    fprintf('[done]\n\n');
end

end