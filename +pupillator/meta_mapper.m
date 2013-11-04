function meta = meta_mapper(obj)

import misc.csvread;

prot = csvread([pupillator.root_path filesep 'protocol.csv']);

subjCol  = ismember(prot(1,:), 'Subject');
seqCol   = ismember(prot(1,:), 'Sequence');
cond1Col = ismember(prot(1,:), 'Condition1');
cond2Col = ismember(prot(1,:), 'Condition2');
measCol  = ismember(prot(1,:), 'Measurement');
sexCol   = ismember(prot(1,:), 'Sex');

dataName = get_name(obj);

regex = ['(?<subject>\d\d\d\d).+(?<tod>afternoon|morning).+' ...
    '(?<pos>sitting|supine)'];
meta = regexp(dataName, regex, 'names');

rowIdx = ...
    ismember(prot(:, subjCol), meta.subject) & ...
    ismember(prot(:, cond1Col), meta.tod) & ...
    ismember(prot(:, cond2Col), meta.pos);


meta.seq = prot{rowIdx, seqCol};

meta.meas_day = str2double(prot{rowIdx, measCol});
meta.sex     = prot{rowIdx, sexCol};

end