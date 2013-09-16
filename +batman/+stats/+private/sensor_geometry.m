function [neighbours, layout] =  sensor_geometry(data)

tmpData = import(physioset.import.physioset, data);
select(pset.selector.sensor_class('Class', 'eeg'), tmpData);
tmpData = fieldtrip(tmpData, 'BadData', 'donothing');  %#ok<NASGU>
cfgN = [];
cfgN.method = 'distance';
cfgN.feedback = 'no';
[~, neighbours] = evalc('ft_prepare_neighbours(cfgN, tmpData);');
[~, layout] = evalc('ft_prepare_layout([], tmpData);');

end