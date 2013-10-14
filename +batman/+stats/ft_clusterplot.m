function ft_clusterplot(alpha, varargin)

import mperl.file.spec.catfile;
import mperl.file.find.finddepth_regex_match;
import misc.dir;

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

file = dir(ROOT_DIR, 'cluster_stats_.+\.mat$');
file = cellfun(@(x) catfile(ROOT_DIR, x), file, 'UniformOutput', false);

for fileItr = 1:numel(file)    
   
    thisFile = file{fileItr};
    
    load(thisFile);
    
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
            tmp = regexp(effectID{i}, '_(?<band>[^_]+)$', 'names');
            thisBand = tmp.band;
           
            tmp = regexp(thisFile, ['_' thisBand '(?<fileid>.*)\.mat'], ...
                'names');
           
            fileID = tmp.fileid;
          
            imgFileName = catfile(ROOT_DIR, [effectID{i} fileID]);
            print('-dpng', imgFileName);
            close;
            fprintf('[done]\n\n');
        else
            fprintf('[no significant clusters found]\n\n');
        end
        
    end
    
    clear ftrip_stats;
end