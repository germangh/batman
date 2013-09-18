function [condID, condName] = block2condition(subj, blockID)
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

% In /data/protocol the block IDs are encoded as 1..12, i.e. the two break
% blocks are not considered
if blockID > 9,
    blockID = blockID -2 ;
elseif blockID > 4,
    blockID = blockID - 1;
end

[condIDList, condNameList] = conditions;

[blockIDList, condIDMap, subjID] = protocol(subj);

if isempty(subjID),
    warning('block2condition:InvalidSubjectID', ...
        'Invalid subject ID: %d', subj);
    condID   = [];
    condName = [];
    return;
end

[isMember, loc] = ismember(['block' num2str(blockID)], blockIDList);

if ~isMember,
    warning('block2condition:InvalidBlockID', ...
        'Invalid block ID: %d', blockID);
    condID   = [];
    condName = [];
    return;
end

condID     = condIDMap(loc);
condName   = condNameList(ismember(condIDList, condID));

if isempty(condName),
    warning('block2condition:InvalidBlockID', ...
        'Block %d corresponds to invalid condition ID ''%s''', ...
        blockID, condID{1});
    condID   = [];
    condName = [];
    return;
end

condName = condName{1};
condID   = condID{1};

end