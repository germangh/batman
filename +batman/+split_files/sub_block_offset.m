function off = sub_block_offset(sbType)
% SUB_BLOCK_OFFSET - Offset from PVT onset for each sub-block type
%
% Offsets are specified in seconds
%
% See also: batman.split_files

off = mjava.hash;

off('baseline') = -9*60;
off('pvt')      = 0;
off('rs')       = 7*60;
off('arsq')     = 12*60;

if nargin > 0,
    off = off(sbType);
end


end