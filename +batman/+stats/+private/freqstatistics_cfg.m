function cfg = freqstatistics_cfg(varargin)

import misc.process_arguments;

% config for ft_freqstatistics
cfg.method     = 'montecarlo';
cfg.statistic  = 'depsamplesT';
cfg.numrandomization = 100;
cfg.correctm     = 'cluster';
cfg.frequency    = [8 12];
cfg.alpha        = 0.05;
cfg.clusteralpha = 0.05;

cfg.design = []; % To be filled later!
cfg.ivar = 1;
cfg.uvar = 2;
cfg.avgoverfreq    = 'yes';
cfg.keepindividual = 'yes';
cfg.neighbours = [];
cfg.layout = [];

[~, cfg] = process_arguments(cfg, varargin);


end
