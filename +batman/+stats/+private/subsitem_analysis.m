function [data, cfg] = subsitem_analysis(cfg, data, signs, subs, itr, rerefMatrix)

import batman.stats.private.*;

data = data(subs(itr,1),subs(itr,2));
data = single_subject_freq_analysis(cfg, data{1}, rerefMatrix);   %#ok<NASGU>
[~, data] = evalc('ft_freqgrandaverage(cfg, data{:});');
data.powspctrm  = signs(itr)*data.powspctrm;

end