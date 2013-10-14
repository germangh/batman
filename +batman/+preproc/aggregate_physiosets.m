function [data, condID, condNames] = ...
    aggregate_physiosets(regex, varargin)
% aggregate_physiosets - Aggregate .pseth files by condition
%
% See: <a href="matlab:misc.md_help('batman.preproc.aggregate_physiosets')">misc.md_help(''batman.preproc.aggregate_physiosets'')</a>
%
% See also: batman

import mperl.file.find.finddepth_regex_match;
import batman.*;
import meegpipe.node.*;
import misc.eta;
import misc.process_arguments;
import mperl.file.spec.catfile;

opt.Verbose  = true;
opt.DataPath = '/data1/projects/batman/analysis/cleaning_130919-222516';

[~, opt] = process_arguments(opt, varargin);

verboseLabel = '(ft_freqanalysis_aggregate) ';

% false -> do not ignore the path when matching the regex
files = finddepth_regex_match(opt.DataPath, regex, false);

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
    warning('off', 'block2condition:InvalidBlockID');
    thisCondID = block2condition(thisSubj, thisBlock);   
    warning('on', 'block2condition:InvalidBlockID');
    
    if isempty(thisCondID), continue; end
    
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