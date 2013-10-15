function [data, dataNew] = process(obj, data, varargin)

import pupillator.nodes.pd_preproc.pd_preproc;
import report.gallery.gallery;
import plot2svg.plot2svg;
import misc.unique_filename;
import mperl.file.spec.catfile;
import inkscape.svg2png;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

dataNew = [];

if verbose,
    
    [~, fname] = fileparts(data.DataFile);
    fprintf([verboseLabel 'Doing nothing on ''%s''...'], fname);

end

filtObj  = get_config(obj, 'Filter');
blockSel = get_config(obj, 'BlockSelector');
xCal     = get_config(obj, 'XCal');
yCal     = get_config(obj, 'YCal');

ev = get_event(data);
blockEvs = select(blockSel, ev);

if do_reporting(obj),
   % Generate a before/after pic for every channel
   h = pd_preproc.plot_before(data, xCal, yCal);
end


% Remove outliers with a median filter
for i = 1:size(data,1)
    select(data, [], data(i,:) > eps);
    try
        data(i,:) = medfilt1(data(i,:), 50);
    catch ME
        restore_selection(data);
        rethrow(ME);
    end        
    restore_selection(data);
end

% Interpolate block by block
firstSample = get_sample(blockEvs);

for i = 1:numel(firstSample)
    if i == numel(firstSample),
        lastSample = size(data,2);
    else
        lastSample = firstSample(i+1)-1;
    end
    
    select(data, [], firstSample(i):lastSample);    
    
    time = 1:size(data,2);
    
    try
        steadyT = time > 0.1*size(data,2) & time < 0.9*size(data,2);
        for j = 1:size(data,1)
            medVal  = median(data(j, steadyT & data(j,:) > eps));
            
            data2interp = isnan(data(j,:)) | data(j,:) <= eps;
            data2interp(steadyT & ...
                (data(j,:) <= 0.75*medVal | data(j,:) >= 1.25*medVal)) = ...
                true;
            
            if data2interp(1),
                nearFirst = find(~data2interp, 1, 'first');
                data(j, 1) = data(j, nearFirst);
                data2interp(1) = false;
            end
            if data2interp(end)
                nearLast = find(~data2interp, 1, 'last');
                data(j, end) = data(j, nearLast);
                data2interp(end) = false;
            end             
            
            data(j, data2interp) = interp1(time(~data2interp), ...
                data(j, ~data2interp), time(data2interp), 'nearest');            
            
        end
    catch ME
        restore_selection(data);
        rethrow(ME);
    end
 
    restore_selection(data);
end

% Discard first 10 and last 10 seconds to minimize borde effects
time = get_sampling_time(data);
N = numel(find(time<10));
data(:, 1:N) = repmat(data(:, N), 1, N);
data(:, end-N+1:end) = repmat(data(:, end-N+1), 1, N);

data = filtfilt(filtObj, data);

% Discard first 10 and last 10 seconds
time = get_sampling_time(data);
N = numel(find(time<10));
data(:, 1:N) = repmat(data(:, N), 1, N);
data(:, end-N+1:end) = repmat(data(:, end-N+1), 1, N);

if do_reporting(obj),
   % Generate a before/after pic for every channel
   captions = pd_preproc.overlay_after(data, h, blockEvs, xCal, yCal);
   
   rep = get_report(obj);
   myGallery = gallery;
   for i = 1:numel(captions),
       thisName = regexprep(captions{i}, '[^\w]+', '_');
       fileName = catfile(get_rootpath(rep), [thisName '.svg']);
       fileName = unique_filename(fileName);
       
       evalc('plot2svg(fileName, h(i));');
       
       thisCaption = [...
           captions{i} ': ' ...
           'Before (black) and after (red) pre-processing. The vertical ' ...
           'green lines denote block boundaries'];
       
       myGallery = add_figure(myGallery, fileName, thisCaption);
       svg2png(fileName);
       close(h(i));
   end
   
   print_title(rep, 'Data processing report', get_level(rep)+1);
   fprintf(rep, myGallery);   
end

% convert pupil diameter to mm
mySel = pset.selector.sensor_label('diameter');
select(mySel, data);
for i = 1:size(data,1)
   data(i,:) = data(i,:)*(xCal*yCal)^(-0.5); 
end


if verbose, fprintf('[done]\n\n'); end



end