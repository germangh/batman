function stat = pvt_stat(data, maxPVT, minPVT, statFh)

import physioset.event.class_selector;

ev = get_event(data);
if isempty(ev),
    stat = '';
    return;
end

ev = select(class_selector('Type', 'PVT'), ev);
if isempty(ev),
    stat = '';
    return;
end

pvt = 1000*get(ev, 'Value');

stat = statFh(pvt(pvt > minPVT & pvt < maxPVT));


end