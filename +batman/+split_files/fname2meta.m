function meta = fname2meta(fName)
% FNAME2META - Translate file names into several meta-tags
%
%
% See also: batman

import batman.block2condition;

regex = 'batman_(?<subject>\d+)_eeg_all.*_(?<sub_block>[^_]+)_(?<block_1_14>\d+)';

meta = regexp(fName, regex, 'names');

meta.subject = meta.subject;

warning('off', 'block2condition:InvalidBlockID');
[condID, condName] = block2condition(str2double(meta.subject), ...
    str2double(meta.block_1_14));
warning('on', 'block2condition:InvalidBlockID');

meta.cond_id   = condID;
meta.cond_name = condName;

end