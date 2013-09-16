function [data, uo] = freq_analysis(cfg, fileArray, rerefMatrix)  %#ok<INUSL>

if nargin < 3, rerefMatrix = []; end

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
    
    if ~isempty(rerefMatrix),
        if isa(rerefMatrix, 'function_handle'),
            thisRerefMatrix = rerefMatrix(data{fileItr});
        else
            thisRerefMatrix = rerefMatrix;
        end
        set_verbose(data{fileItr}, false);
        data{fileItr} = copy(data{fileItr});
        reref(data{fileItr}, thisRerefMatrix);
    end    
    
    data{fileItr} = fieldtrip(data{fileItr}, 'BadData', 'donothing');
    
    [~, data{fileItr}] = evalc('ft_freqanalysis(cfg, data{fileItr});');
end

[~, data] = evalc('ft_freqgrandaverage(cfg, data{:});');


end