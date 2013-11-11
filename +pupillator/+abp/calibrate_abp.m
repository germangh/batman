function data = calibrate_abp(data)

STD_PSYS  = 120;
STD_PDIAS = 80;
abp = data(1,:);

% Discard first and last blocks, where weird stuff tends to happen
evArray = get_event(data);
firstSample = get_sample(evArray(2));
lastSample  = get_sample(evArray(end));
ssf = abp(1, firstSample:lastSample);

% Discard outliers in a very crude way
ssfMedian = median(ssf);
ssf99     = prctile(ssf, 99.5);
ssf1      = prctile(ssf, 0.5);
abp(abp < ssf1)  = ssf1;
abp(abp > ssf99) = ssf99;
ssf(ssf < ssf1)  = ssf1;
ssf(ssf > ssf99) = ssf99;

% A simple smoothing filter
myFilt = filter.ba(ones(1, 10)/10, 1, 'Verbose', false);
abp = filtfilt(myFilt, abp);

% Flat-out the first and last samples (we loose 3% of data)
firstSample = get_sample(evArray(1));
lastSample = get_sample(evArray(end)) + get(evArray(end), 'Duration');
abp(1:firstSample)  = ssfMedian;
abp(lastSample:end) = ssfMedian;

abp = (STD_PSYS-STD_PDIAS)*(abp - mean(ssf))/range(ssf)+STD_PDIAS;

data(1,:) = abp;

end