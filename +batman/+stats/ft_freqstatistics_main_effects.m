function [out, effect] = ft_freqstatistics_main_effects(varargin)
% ft_freqstatistics_main_effects - Main effects on resting state EEG power
%
% See: <a href="matlab:misc.md_help('batman.stats.ft_freqstatistics_main_effects')">misc.md_help(''batman.stats.ft_freqstatistics_main_effects'')</a>
%
% See also: batman.preproc.aggregate_physiosets


import misc.process_arguments;
import misc.eta;
import batman.preproc.aggregate_physiosets;
import mperl.file.spec.catfile;
import mperl.join;
import meegpipe.node.*;
import oge.qsub;
import misc.split_arguments;
import misc.any2str;
import batman.stats.private.*;

opt.Verbose         = true;
opt.SaveToFile      = ...
    '/data1/projects/batman/analysis/cluster_stats_main_effects.mat';
opt.Bands           = batman.eeg_bands;
opt.Scale           = 'db'; % Anything else means: use Fieltrip default scale
% This is just the average re-referencing operator where x is the
% physioset object to be re-rerefenced
opt.RerefMatrix     = meegpipe.node.reref.avg_matrix;
opt.Regex           = '_meegpipe_.+_cleaning.pseth$';
opt.Subjects        = [1 2 3 4 7 9 10];
opt.UserName        = 'meegpipe';
opt.HashPipe        = '979af1';
opt.UseOGE          = true;
[~, opt] = process_arguments(opt, varargin);

bandNames = keys(opt.Bands);

if numel(bandNames) > 1 && opt.UseOGE && oge.has_oge,
    % Run using the grid engine
    [~, varargin] = split_arguments('Bands', varargin);
    varargin = cellfun(@(x) any2str(x, Inf), varargin);
    varargin = join(',', varargin);
    for i = 1:numel(bandNames),
       jobName = ['meff-' bandNames{i}];       
       cmd = sprintf([...
           'meegpipe.initialize;' ...
           'batman.stats.ft_freqstatistics_main_effects( ' ...
           '''Bands'', mjava.hash(''%s'', %s)' ...
           ], bandNames{i}, any2str(opt.Bands(bandNames{i})));
       
       if ~isempty(varargin)
           cmd = [cmd ',' varargin]; %#ok<*AGROW>
       end
       cmd = [cmd ');']; 
       qsub(cmd, 'Name', jobName, 'Queue', 'short.q');
    end
    return;
end

verboseLabel = '(ft_freqstatistics_main_effects) ';

if isempty(opt.Subjects),
    subjRegex = '';
else
    subjRegex = ['_0+(' join('|', opt.Subjects) ')_'];
end

regex = sprintf('%s_%s_.+%s.+_cleaning.pseth$', ...
    opt.HashPipe, opt.UserName, subjRegex);

% Aggregate conditions' data files
[data, condID, condNames] = aggregate_physiosets(regex, ...
    'Verbose', opt.Verbose);

if opt.Verbose,
    fprintf([verboseLabel 'Computing statistics ...']);
    tinit = tic;
    clear +misc/eta;
end

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
        
        warning('off', 'session:NewSession');
        [fa1, uo1]  = freq_analysis(cfgF, thisData(1,:,:), opt.RerefMatrix); %#ok<*ASGLU>
        
        count = count + 1;
        if opt.Verbose,
            eta(tinit, numel(effect)*numel(bandNames)*2, ...
                count, 'remaintime', true);
        end

        [fa2, uo2]  = freq_analysis(cfgF, thisData(2,:,:), opt.RerefMatrix);
        warning('on', 'session:NewSession');
        
        if opt.Verbose,
            eta(tinit, numel(effect)*numel(bandNames)*2, ...
                count, 'remaintime', true);
        end
        
        cfgS.design = [ ...
            ones(1, numel(uo1)) 2*ones(1, numel(uo2)); ...
            uo1, uo2 ...
            ];
        
        if ismember(lower(opt.Scale), {'db', 'logarithmic'}),     
            fa1.powspctrm = 10*log10(fa1.powspctrm);          
            fa2.powspctrm = 10*log10(fa2.powspctrm);         
        end
        
        [~, ftripStats{mainEffectItr}] = ...
            evalc('ft_freqstatistics(cfgS, fa1, fa2);');
        
        count = count + 1;
        
        
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
        thisSaveFile = catfile(filePath, [fileName '_' bandNames{bandItr}]);
        
        if ismember(lower(opt.Scale), {'db', 'logarithmic'}),
            thisSaveFile = [thisSaveFile '_logarithmic'];
        end
        
        thisSaveFile = [thisSaveFile '_' datestr(now, 'yymmdd-HHMMSS')];
        save([thisSaveFile fileExt], 'freq_stats');
    end
    
    if opt.Verbose,
        fprintf([verboseLabel 'Finished on %s'], datestr(now));
    end
    
end

clear +misc/eta;

end


