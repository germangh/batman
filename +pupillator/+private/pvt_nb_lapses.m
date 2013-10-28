function count = pvt_nb_lapses(data, pvtLapse)

import physioset.event.class_selector;

ev = get_event(data);

if isempty(ev),
    count = '';
    return;
end

ev = select(class_selector('Type', 'PVT'), ev);
if isempty(ev),
    count = '';
    return;
end

pvt = get(ev, 'Value');

count = numel(find(pvt > pvtLapse/1000));

end