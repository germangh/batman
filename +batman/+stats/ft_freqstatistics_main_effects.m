function [out, effect] = ft_freqstatistics_main_effects(varargin)
% ft_freqstatistics_main_effects - Main effects on resting state EEG power
%
% See: <a href="matlab:misc.md_help('batman.stats.ft_freqstatistics_main_effects')">misc.md_help(''batman.stats.ft_freqstatistics_main_effects'')</a>


import misc.process_arguments;
import misc.eta;
import batman.preproc.aggregate_physiosets;
import mperl.file.spec.catfile;

opt.Verbose         = true;
opt.SaveToFile      = ...
    '/data1/projects/batman/analysis/cluster_stats_main_effects.mat';
opt.Bands           = batman.eeg_bands;
[~, opt] = process_arguments(opt, varargin);

verboseLabel = '(ft_freqstatistics_main_effects) ';

% Aggregate conditions' data files
[data, condID, condNames] = aggregate_physiosets(varargin); %#ok<*ASGLU>

if opt.Verbose,
    fprintf([verboseLabel 'Computing statistics ...']);
    tinit = tic;
end

bandNames = keys(opt.Bands);
[filePath, fileName, fileExt] = fileparts(opt.SaveToFile);
effect    = {'L', 'P', 'T'};
out       = cell(1, numel(bandNames));

% This info is needed for ft_clusterplot, it will be attached to the cfg
% structure passed to ft_freqstatistics
[neighbours, layout] = sensor_geometry(data{1}{1});

count = 0;

for bandItr = 1:numel(bandNames)
    
    ftripStats  = cell(1, numel(effect));
    thisEffect = cellfun(@(x) [x '_' bandNames{bandItr}], effect, ...
        'UniformOutput', false);
    
    % Configuration for ft_freqanalysis
    cfgF = freqanalysis_cfg('foilim', opt.Bands(bandNames{bandItr}));
    
    cfgS = freqstatistics_cfg(...
        'frequency',  opt.Bands(bandNames{bandItr}), ...
        'layout',     layout, ...
        'neighbours', neighbours);
    
    for mainEffectItr = 1:numel(effect),
        
        mainFirst  = [mainEffectItr setdiff(1:numel(effect), mainEffectItr)];
        thisData    = permute(data, mainFirst);
        
        [fa1, uo1]  = freq_analysis(cfgF, thisData(1,:,:)); %#ok<*NASGU>
        [fa2, uo2]  = freq_analysis(cfgF, thisData(2,:,:));
        cfgS.design = [ ...
            ones(1, numel(uo1)) ones(1, numel(uo2)); ...
            uo1, uo2 ...
            ];
        
        [~, ftripStats{mainEffectItr}] = ...
            evalc('ft_freqstatistics(cfgS, fa1, fa2);');
        
        count = count + 1;
        if opt.Verbose,
            eta(tinit, numel(effect)*numel(bandNames), ...
                count, 'remaintime', true);
        end
        
    end
    
    freq_stats = [];
    freq_stats.ftrip_stats  = ftripStats;
    freq_stats.effect_id    = thisEffect;
    freq_stats.cond_id      = condID;
    freq_stats.cond_names   = condNames;
    freq_stats.layout       = layout;
    freq_stats.data         = data;
    
    out{bandItr} = freq_stats;
    if ~isempty(opt.SaveToFile),
        thisSaveFile = catfile(filePath, ...
            [fileName '_' bandNames{bandItr} fileExt]);
        save(thisSaveFile, 'freq_stats');
    end
    
end

end

function cfg = freqstatistics_cfg(varargin)

import misc.process_arguments;

% config for ft_freqstatistics
cfg.method     = 'montecarlo';
cfg.statistic  = 'depsamplesT';
cfg.numrandomization = 100;
cfg.correctm   = 'cluster';
cfg.frequency  = [8 12];
cfg.alpha      = 0.05;

cfg.design = []; % To be filled later!
cfg.ivar = 1;
cfg.uvar = 2;
cfg.avgoverfreq    = 'yes';
cfg.keepindividual = 'yes';
cfg.neighbours = [];
cfg.layout = [];

[~, cfg] = process_arguments(cfg, varargin);


end

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

function [neighbours, layout] =  sensor_geometry(data)

tmpData = import(physioset.import.physioset, data);
select(pset.selector.sensor_class('Class', 'eeg'), tmpData);
tmpData = fieldtrip(tmpData);  %#ok<NASGU>
cfgN = [];
cfgN.method = 'distance';
cfgN.feedback = 'no';
[~, neighbours] = evalc('ft_prepare_neighbours(cfgN, tmpData);');
[~, layout] = evalc('ft_prepare_layout([], tmpData);');

end

function [data, uo] = freq_analysis(cfg, fileArray)  %#ok<INUSL>

myImporter = physioset.import.physioset;
mySel      = pset.selector.sensor_class('Class', 'EEG');

nbFiles = sum(cellfun(@(x) numel(x), fileArray(:)));
fileList = cell(1, nbFiles);
count = 0;
for i = 1:numel(fileArray),
    for j = 1:numel(fileArray(i))
        fileList(count+1:count+numel(fileArray{i})) = fileArray{i};
        count = count + numel(fileArray{i});
    end
end

uo = nan(1, numel(fileList));
data = cell(size(fileList));
for fileItr = 1:numel(fileList)
    data{fileItr} = import(myImporter, fileList{fileItr});
    dataName = get_name(data{fileItr});
    tmp = regexp(dataName, '.+_0+(?<subj>\d+)_.+', 'names');
    uo(fileItr) = str2double(tmp.subj);
    select(mySel, data{fileItr});
    data{fileItr} = fieldtrip(data{fileItr}, 'BadData', 'donothing');
    
    [~, data{fileItr}] = evalc('ft_freqanalysis(cfg, data{fileItr});');
end

[~, data] = evalc('ft_freqgrandaverage(cfg, data{:});');

end