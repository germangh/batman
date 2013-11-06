function data = calibrate_abp(data)

STD_PSYS  = 120;
STD_PDIAS = 80;
abp = data(1,:)';
ssf = abp(1:min(data.SamplingRate*10, numel(abp)));
abp = (STD_PSYS-STD_PDIAS)*(abp - mean(ssf))/range(ssf)+STD_PDIAS;

data(1,:) = abp';

end