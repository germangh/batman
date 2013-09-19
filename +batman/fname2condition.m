function trans = fname2condition(fName)
% fname2condition - File name to condition translation
%
%
% See also: batman

import batman.block2condition;

regex = 'batman_(?<subject>\d+)_.+_(?<block>\d+)_cleaning';

meta = regexp(fName, regex, 'names');

trans.subject = meta.subject;

warning('off', 'block2condition:InvalidBlockID');
[condID, condName] = block2condition(str2double(meta.subject), ...
    str2double(meta.block));
warning('on', 'block2condition:InvalidBlockID');

trans.cond_id = condID;
trans.cond_name =condName;

end