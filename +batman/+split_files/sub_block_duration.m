function dur = sub_block_duration(sbType)
% SUB_BLOCK_DURATION - Duration of each sub-block type
%
% Durations are specified in seconds
%
% See also: batman.split_files

dur = mjava.hash;

dur('baseline') = 9*60;
dur('pvt')      = 7*60;
dur('rs')       = 5*60;
dur('arsq')     = 3.5*60;


if nargin > 0,
    dur = dur(sbType);
end

end