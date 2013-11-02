function name = block_naming_policy(data, ev, idx, subBlockType)
% BLOCK_NAMING_POLICY - Naming policy for the data file splits
%
%
% block_naming_policy(data, ev, idx, subBlockType)
%
% See also: batman.split_files

import physioset.event.class_selector;
import batman.split_files.sub_block_offset;
import batman.split_files.sub_block_duration;


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

blockIdx = setdiff(firstBlock:lastBlock, [5, 10]);

if idx > numel(blockIdx),
    warning('naming_policy:TooManyEvents', ...
        'Event with index %d exceeds the number of blocks (%d) in %s', ...
        idx, numel(blockIdx), get_name(data));
    name = NaN;
    return;
end

blockIdx = blockIdx(idx);

% Check whether the RS period is not complete, in that case do not split

first = get_sample(ev)+sub_block_offset(subBlockType)*data.SamplingRate;
last  = get_sample(ev)+sub_block_offset(subBlockType)*data.SamplingRate + ...
    sub_block_duration(subBlockType)*data.SamplingRate;

if size(data, 2) < last || first < 1,
    warning('block_naming_policy:IncompleteBlock', ...
        'Ignoring block %d (%s) in file %s: incomplete sub-block', ...
        blockIdx, subBlockType, get_name(data));
    name = NaN;
    return;
end

name = [subBlockType '_' num2str(blockIdx)]; 

end