function [data, cfg] = subsitem_analysis(cfg, data, subs, itr, rerefMatrix)

import batman.stats.private.*;

data = data(subs(itr,1),subs(itr,2));
data = single_subject_freq_analysis(cfg, data{1}, rerefMatrix);   %#ok<NASGU>
[~, data] = evalc('ft_freqgrandaverage(cfg, data{:});');
data.powspctrm  = data.powspctrm;

end