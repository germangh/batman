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
import spt.bss.efica.efica;
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
opt.Var             = 99.75;

[~, opt]    = process_arguments(opt, varargin);

% High pass filter
if isnan(sr),
    filtObj = @(sr) filter.bpfilt('fp', [8/(sr/2) 1]);
else
    f0      = 8/(sr/2);
    filtObj = filter.bpfilt('fp', [f0 1]);
end

% PCA
pcaObj = pca(...
    'Var',          opt.Var/100, ...
    'MaxDimOut',    40, ... %40
    'Criterion',    'aic', ...
    'Filter',       filtObj);

% Component selection criterion

critObj = spt.criterion.psd_ratio.new( ...
    'Band1',            [25 100], ...
    'Band2',            [2 15], ...
    'Max',              @(r) median(r) + 2*mad(r), ...
    'MinCard',          2, ...
    'MaxCard',          6);

% Build an empty bss_regression object
dataSel = cascade(sensor_class('Class', {'EEG'}), good_data);
obj = bss_regr(...  
    'DataSelector',     dataSel, ...
    'Criterion',        critObj, ...
    'PCA',              pcaObj, ...
    'BSS',              efica, ...
    'Filter',           filtObj, ...
    'RegrFilter',       filter.mlag_regr('Order', 3));


obj = set_name(obj, 'bss_regression_spiky_noise');


end