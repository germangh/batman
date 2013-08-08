function obj = bss_regr_spiky_noise(sr, varargin)
% bss_regr_spiky_noise - Remove spiky noise sources, probably caused by MUX
%
%
% See also: batman

import meegpipe.node.bss_regr.bss_regr;
import misc.process_arguments;
import misc.isnatural;
import spt.pca.pca;
import spt.bss.jade.jade;
import spt.bss.multicombi.multicombi;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

if nargin < 1,
    sr = NaN;
end

if isempty(sr),
    error('The sampling rate needs to be provided!');
end

opt.mincard         = 0;
opt.maxcard         = 5;
opt.Var             = 99.5;

[~, opt]    = process_arguments(opt, varargin);

% High pass filter
if isnan(sr),
    filtObj = @(sr) filter.bpfilt('fp', [3/(sr/2) 1]);
else
    f0      = 3/(sr/2);
    filtObj = filter.bpfilt('fp', [f0 1]);
end

% PCA
pcaObj = pca(...
    'Var',          opt.Var/100, ...
    'MaxDimOut',    40, ... %40
    'Criterion',    'aic', ...
    'Filter',       filtObj);

% Component selection criterion

critObj = spt.criterion.tgini.new(...
    'Max',              @(r) median(r) + 0.5*(max(r)-median(r)), ...
    'MinCard',          2, ...
    'MaxCard',          6);

% Build an empty bss_regression object
dataSel = cascade(sensor_class('Class', {'EEG'}), good_data);
obj = bss_regr(...  
    'DataSelector',     dataSel, ...
    'Criterion',        critObj, ...
    'PCA',              pcaObj, ...
    'BSS',              jade('Filter', filtObj), ...
    'Filter',           filtObj);


obj = set_name(obj, 'bss_regression_spiky_noise');


end