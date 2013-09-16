function cfg = freqanalysis_cfg(varargin)

import misc.process_arguments;

cfg = [];
cfg.method         = 'mtmfft';
cfg.output         = 'pow';
cfg.taper          = 'hanning';
cfg.keeptrials     = 'no';
cfg.foilim         = [8 12];
cfg.keepindividual = 'yes';
cfg.avgoverfreq    = 'yes';
[~, cfg] = process_arguments(cfg, varargin);

end