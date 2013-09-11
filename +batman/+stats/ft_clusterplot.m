function ft_clusterplot(alpha, varargin)

import mperl.file.spec.catfile;

ROOT_DIR= '/data1/projects/batman/analysis';

if nargin < 1 || isempty(alpha), alpha = 0.05; end

if isempty(varargin),
    varargin = keys(batman.eeg_bands);
end

if numel(varargin) > 1,
    for i = 1:numel(varargin)
        batman.stats.ft_clusterplot(alpha, varargin{i});
    end
    return;
end

file = { ...
    catfile(ROOT_DIR, ['cluster_stats_main_effects_' varargin{1} '.mat']), ...
    catfile(ROOT_DIR, ['cluster_stats_interaction_effects_' varargin{1} '.mat']) ...
    };

for fileItr = 1:numel(file)
    
    if ~exist(file{fileItr}, 'file'),
        continue;
    end
    
    load(file{fileItr});
    
    cfg = [];
    cfg.layout = freq_stats.layout;
    cfg.alpha  = alpha;
    
    ftripStats = freq_stats.ftrip_stats; %#ok<NASGU>
    effectID = freq_stats.effect_id;
    
    for i = 1:numel(effectID) 
        try
            fprintf('(ft_clusterplot) Plotting %s ...', effectID{i});
            res = evalc('ft_clusterplot(cfg, ftripStats{i});');
        catch ME
            if isempty(strfind(ME.message, 'no clusters')),
                rethrow(ME);
            else
                fprintf('[no significant clusters found]\n\n');
                continue;
            end
        end
        if isempty(strfind(res, 'no significant')),
            print('-dpng', catfile(ROOT_DIR, effectID{i}));
            close;
            fprintf('[done]\n\n');
        else
            fprintf('[no significant clusters found]\n\n');
        end
        
    end
    
    clear ftrip_stats;
end