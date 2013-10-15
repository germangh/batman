function hFig = plot_before(data, xCal, yCal)

import meegpipe.node.globals;

visible = globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end
captions = labels(sensors(data));

hFig = [];
time = get_sampling_time(data);
for i = 1:size(data,1)
    hFig = [hFig;figure('Visible', visibleStr)]; %#ok<AGROW>
    
    if isempty(regexp(captions{i}, 'diameter', 'once')),
        ts = data(i,:);
    else
        ts = data(i, :)*(xCal*yCal)^(-0.5);
    end
    
    scatter(time/60, ts, 'k.');
end



end