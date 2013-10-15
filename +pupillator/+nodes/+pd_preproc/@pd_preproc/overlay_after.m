function captions = overlay_after(data, h, ev, xCal, yCal)

captions = labels(sensors(data));

time = get_sampling_time(data)/60;


for i = 1:numel(h),    
    hAxes = findobj(h(i), 'Type', 'axes');
    hold(hAxes, 'on');
    if isempty(regexp(captions{i}, 'diameter', 'once')),
        ts = data(i,:);
    else
        ts = data(i, :)*(xCal*yCal)^(-0.5);
    end
    plot(hAxes, time, ts, 'r', 'LineWidth', 1.5);
    for j = 1:numel(ev)
       sampl = get_sample(ev(j));
       evTime = get_sampling_time(data, sampl)/60;       
       stem(hAxes, evTime, ts(sampl), 'go');
    end
    ylabel(captions{i});
    xlabel('Time (min)');
    hold(hAxes, 'off');
end





end