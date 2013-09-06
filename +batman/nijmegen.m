% Nijmegen stuff...

import batman.*;

DIR = '/data1/projects/batman/analysis/cleaning';
SUBJ = [];

[ftripStr, condID, condName] = ft_freqanalysis_aggregate(DIR, SUBJ);

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.foi    = 8:12;
cfg.taper  = 'hanning';

for i = 1:numel(ftripStr)
   
    ftripStr{i} = ft_freqanalysis(cfg, ftripStr{i});
    
end

save nijmegen ftripStr;