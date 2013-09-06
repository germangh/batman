function [condIDout, cond] = block2condition(subj, blockID)
% block2condition
% ===
%
% Map block numbers to conditions for all experimental subjects
%
% ## Usage synopsis
%
% ````matlab
% cond = batman.block2condition(6, 10)
% assert(strcmp(cond, 'light1_posture1_dpg0'));
% ````
% 
% See also: batman.ft_freqanalysis_aggregate

import misc.dlmread;
import mperl.file.spec.catfile;
import batman.*;
import mperl.join;

if nargin < 2 || numel(blockID) ~= 1,
    error('blockID must be a single block index');
end

if blockID > 9,
    blockID = blockID -2 ;
elseif blockID > 4,
    blockID = blockID - 1;
end

[condID, condNames] = conditions;

fName = catfile(root_path, 'data', 'protocol.csv');
[prot, condID2] = dlmread(fName, ',');

condID2 = condID2(3:end);
subjID = prot(:,1);
prot = prot(:, 3:end);

[~, rowIdx] = ismember(subj, subjID); 

if any(rowIdx < 1),
    warning('block2condition:InvalidSubjectID', ...
        'The following are not valid subject IDs: %s', ...
        join(', ', subj(rowIdx < 1)));
end

subj(rowIdx < 1)   = [];
rowIdx(rowIdx < 1) = [];

cond = cell(size(subj));
condIDout = cell(size(subj));

for i = 1:numel(subj)
   condIDout{i} = condID2{prot(rowIdx(1), :) == blockID};
   cond{i} = condNames{ismember(condID, condIDout{i})};
end




end