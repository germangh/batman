function data = calibrate_temp(data)

for i = 1:size(data, 1)
    % According to Wisse's e-mail on May 21st, 2013
    data(i,:) = 73.228-0.0572*data(i,:);
end

end