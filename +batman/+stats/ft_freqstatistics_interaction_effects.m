function [out, effect] = ft_freqstatistics_interaction_effects(varargin)
% ft_freqstatistics_interaction_effects - Interaction effects on resting state EEG power
%
% See: <a href="matlab:misc.md_help('batman.stats.ft_freqstatistics_interaction_effects')">misc.md_help(''batman.stats.ft_freqstatistics_interaction_effects'')</a>


import misc.process_arguments;
import misc.eta;
import batman.preproc.aggregate_physiosets;
import mperl.file.spec.catfile;

opt.Verbose         = true;
opt.SaveToFile      = ...
    '/data1/projects/batman/analysis/cluster_stats_interaction_effects.mat';
opt.Bands           = batman.eeg_bands;
[~, opt] = process_arguments(opt, varargin);

verboseLabel = '(ft_freqstatistics_interaction_effects) ';

% Aggregate conditions' data files
[data, condID, condNames] = aggregate_physiosets(varargin); %#ok<*ASGLU>

if opt.Verbose,
    fprintf([verboseLabel 'Computing statistics ...']);
    tinit = tic;
end

count = 0;

% The indices and signs of the summation terms for each effect
subs  = cell(1, 2);
signs = cell(1, 2);
[subs{1}, signs{1}] = higher_interaction_effects();
nbSubs = numel(subs{1});
[subs{2}, signs{2}] = simple_interaction_effects();
nbSubs = nbSubs + numel(subs{2});

bandNames = keys(opt.Bands);
[filePath, fileName, fileExt] = fileparts(opt.SaveToFile);
effect    = {'PxT_L', 'LxT_P', 'LxP_T', 'LxP', 'PxL', 'TxL'};
out       = cell(1, numel(bandNames));

% This info is needed for ft_clusterplot, it will be attached to the cfg
% structure passed to ft_freqstatistics
[neighbours, layout] = sensor_geometry(data{1}{1});

for bandItr = 1:numel(bandNames)
    
    ftripStats  = cell(1, 6);
    thisEffect = cellfun(@(x) [x '_' bandNames{bandItr}], effect, ...
        'UniformOutput', false);
    effectCount = 0;
    
    % Configuration for ft_freqanalysis
    cfgF = freqanalysis_cfg('foilim', opt.Bands(bandNames{bandItr}));
    
    cfgS = freqstatistics_cfg(data, ...
        'frequency',  opt.Bands(bandNames{bandItr}), ...
        'layout',     layout, ...
        'neighbours', neighbours); %#ok<NASGU>
    
    for interEffectItr = 1:2
        
        effectCount = effectCount + 1;
        
        for parcVarItr = 1:3
            parcVarLast  = [setdiff(1:3, parcVarItr), parcVarItr];
            thisData     = permute(data, parcVarLast);
            parcData     = cell(1, 2);
            
            % The 2 levels of the variable we partialize against
            for parcValue = 1:2
                
                parcData{parcValue} = ...
                    subsitem_analysis(cfgF, thisData(:,:,parcValue), ...
                    signs{interEffectItr}, subs{interEffectItr}, 1);
                
                mat = parcData{parcValue}.powspctrm;
                count = count + 1;
                
                for subsItr = 2:size(subs{interEffectItr},1)
                    
                    thisParcData = subsitem_analysis(cfgF, ...
                        thisData(:,:,parcValue), ...
                        signs{interEffectItr}, subs{interEffectItr}, ...
                        subsItr);
                    
                    mat = mat + thisParcData.powspctrm;
                    count = count + 1;
                    if opt.Verbose,
                        eta(tinit, 3*2*2*nbSubs*numel(bandNames), ...
                            count, 'remaintime', true);
                    end
                    
                end
                
                parcData{parcValue}.powspctrm = mat;
            end
            
            [~, ftripStats{effectCount}] = ...
                evalc('ft_freqstatistics(cfgS, parcData{1}, parcData{2});');
            
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

function cfg = freqstatistics_cfg(data, varargin)

import misc.process_arguments;

% config for ft_freqstatistics
cfg.method     = 'montecarlo';
cfg.statistic  = 'depsamplesT';
cfg.numrandomization = 100;
cfg.correctm   = 'cluster';
cfg.frequency  = [8 12];
cfg.alpha      = 0.05;

nbSubj = numel(data{1});
cfg.design = [ ...
    ones(1, nbSubj) ones(1, nbSubj)*2; ...
    1:7 1:7 ...
    ];
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

function [subs, signs] = higher_interaction_effects()

subs = nan(4,2);
count = 0;
for i = 1:2
    for j = 1:2
        count = count + 1;
        subs(count,:) = [i j];
    end
end
signs = [1 -1 -1 1];

end

function [subs, signs] = simple_interaction_effects()

subs = nan(4,2);
count = 0;
for i = 1:2
    for j = 2:-1:1
        count = count + 1;
        subs(count,:) = [i j];
    end
end
signs = [-1 1 -1 1];

end

function [data, cfg] = subsitem_analysis(cfg, data, signs, subs, itr)

data = data(subs(itr,1),subs(itr,2));
data = single_subject_freqanalysis(cfg, data{1});   %#ok<NASGU>
[~, data] = evalc('ft_freqgrandaverage(cfg, data{:});');
data.powspctrm  = signs(itr)*data.powspctrm;

end

function data = single_subject_freqanalysis(cfg, fileList)  %#ok<INUSL>

myImporter = physioset.import.physioset;
mySel      = pset.selector.sensor_class('Class', 'EEG');

data = cell(size(fileList));
for subjItr = 1:numel(fileList)
    data{subjItr} = import(myImporter, fileList{subjItr});
    select(mySel, data{subjItr});
    data{subjItr} = fieldtrip(data{subjItr}, 'BadData', 'donothing');
    
    [~, data{subjItr}] = evalc('ft_freqanalysis(cfg, data{subjItr});');
end

end