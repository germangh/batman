function data = single_subject_freq_analysis(cfg, fileList, rerefMatrix)  %#ok<INUSL>

if nargin < 3, rerefMatrix = []; end

myImporter = physioset.import.physioset;
mySel      = pset.selector.sensor_class('Class', 'EEG');

data = cell(size(fileList));
for subjItr = 1:numel(fileList)
    data{subjItr} = import(myImporter, fileList{subjItr});
    select(mySel, data{subjItr});
    
    if ~isempty(rerefMatrix),
        if isa(rerefMatrix, 'function_handle'),
            thisRerefMatrix = rerefMatrix(data{subjItr});
        else
            thisRerefMatrix = rerefMatrix;
        end
        set_verbose(data{subjItr}, false);
        
        data{subjItr} = copy(data{subjItr});
        reref(data{subjItr}, thisRerefMatrix);
    end    

    data{subjItr} = fieldtrip(data{subjItr}, 'BadData', 'donothing');
    
    [~, data{subjItr}] = evalc('ft_freqanalysis(cfg, data{subjItr});');
end

end