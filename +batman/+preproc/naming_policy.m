function name = naming_policy(data, ev, idx, label)
% naming_policy - Naming policy for the data file splits
%
% See also: batman

import physioset.event.class_selector;

% Check the beginning and end block contained in this recording. This is
% rather ad-hoc but I don't know how we could do this more general/robust
dataName = get_name(data);

regex = '.+_(?<firstBlock>\d+)-(?<lastBlock>\d+)$';
blockId = regexp(dataName, regex, 'names');


if isempty(blockId),
    firstBlock = 1;
    lastBlock = 14;
else
    firstBlock = str2double(blockId.firstBlock);
    lastBlock  = str2double(blockId.lastBlock);
    
end

blockIdx = firstBlock:lastBlock;

if idx > blockIdx,
    name = NaN;
    return;
end

blockIdx = blockIdx(idx);

if blockIdx > lastBlock || ismember(blockIdx, [5, 10])
    % This block should not be considered in this file
    % Break blocks should be handled as out-of-range blocks
    name = NaN;
    return;
end

% Check whether the RS period is not complete, in that case do not split
if size(data, 2) < get_sample(ev)+60*5*data.SamplingRate,
    warning('rs_naming_policy:IncompleteBlock', ...
        'Ignoring block %d in recording %s: RS epoch is not complete', ...
        blockIdx, get_name(data));
    name = NaN;
    return;
end

name = [label '_' num2str(blockIdx)]; 

end