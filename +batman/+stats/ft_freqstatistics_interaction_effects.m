function [out, effect] = ft_freqstatistics_interaction_effects(varargin)
% ft_freqstatistics_interaction_effects - Interaction effects on resting state EEG power
%
% See: <a href="matlab:misc.md_help('batman.stats.ft_freqstatistics_interaction_effects')">misc.md_help(''batman.stats.ft_freqstatistics_interaction_effects'')</a>


import misc.process_arguments;
import misc.eta;
import batman.preproc.aggregate_physiosets;
import mperl.file.spec.catfile;
import misc.split_arguments;
import misc.any2str;
import mperl.join;
import oge.qsub;
import batman.stats.private.*;

opt.Verbose         = true;
opt.SaveToFile      = ...
    '/data1/projects/batman/analysis/cluster_stats_interaction_effects.mat';
opt.Bands           = batman.eeg_bands;
% This is just the average re-referencing operator where x is the
% physioset object to be re-rerefenced
opt.RerefMatrix     = meegpipe.node.reref.avg_matrix;
opt.Regex           = '_meegpipe_.+_cleaning.pseth$';
opt.Subjects        = [1 2 3 4 7 9 10];
opt.UserName        = 'meegpipe';
opt.HashPipe        = '979af1';
opt.UseOGE          = true;
opt.Scale           = 'db';
[~, opt] = process_arguments(opt, varargin);

bandNames = keys(opt.Bands);

if numel(bandNames) > 1 && opt.UseOGE && oge.has_oge,
    % Run using the grid engine
    [~, varargin] = split_arguments('Bands', varargin);
    varargin = cellfun(@(x) any2str(x, Inf), varargin);
    varargin = join(',', varargin);
    for i = 1:numel(bandNames),
       jobName = ['ieff-' bandNames{i}];       
       cmd = sprintf([...
           'meegpipe.initialize;' ...
           'batman.stats.ft_freqstatistics_interaction_effects( ' ...
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

verboseLabel = '(ft_freqstatistics_interaction_effects) ';

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
    
    cfgS = freqstatistics_cfg(...
        'frequency',  opt.Bands(bandNames{bandItr}), ...
        'layout',     layout, ...
        'neighbours', neighbours); 
    
    nbSubj = numel(data{1});
    cfgS.design = [ ...
        ones(1, nbSubj) ones(1, nbSubj)*2; ...
        1:7 1:7 ...
        ];
    
    for interEffectItr = 1:2
        
        effectCount = effectCount + 1;
        
        for parcVarItr = 1:3
            parcVarLast  = [setdiff(1:3, parcVarItr), parcVarItr];
            thisData     = permute(data, parcVarLast);
            parcData     = cell(1, 2);
            
            % The 2 levels of the variable we partialize against
            for parcValue = 1:2
                
                warning('off', 'session:NewSession');
                parcData{parcValue} = ...
                    subsitem_analysis(cfgF, thisData(:,:,parcValue), ...
                    signs{interEffectItr}, subs{interEffectItr}, 1, ...
                    opt.RerefMatrix);
                warning('on', 'session:NewSession');
                
                mat = parcData{parcValue}.powspctrm;
                count = count + 1;
                
                for subsItr = 2:size(subs{interEffectItr},1)
                    
                    thisParcData = subsitem_analysis(cfgF, ...
                        thisData(:,:,parcValue), ...
                        subs{interEffectItr}, ...
                        subsItr, opt.RerefMatrix);
                    
                    newData = thisParcData.powspctrm;
                    
                    if ismember(lower(opt.Scale), {'db', 'logarithmic'}),
                        newData = 10*log10(newData);
                    end
                    
                    newData = signs{interEffectItr}(subsItr)*newData;
                    
                    mat = mat + newData;
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
        thisSaveFile = catfile(filePath, [fileName '_' bandNames{bandItr}]);
        
        if ismember(lower(opt.Scale), {'db', 'logarithmic'}),
            thisSaveFile = [thisSaveFile '_logarithmic'];
        end
        
        thisSaveFile = [thisSaveFile '_' datestr(now, 'yymmdd-HHMMSS')];
        save([thisSaveFile fileExt], 'freq_stats');
    end
    
end

end


