
file_loc = './tdc_2020-02-13-070542/';

max_ENOB     = zeros(16,1);
max_ENOB_idx = zeros(16,1);

ENOB = zeros(16,32);

for kk=1:16
    file_name = sprintf('tdc_dcdl_%d.csv', kk-1);
    fid_adc_out=fopen(strcat(file_loc, file_name));
    var = textscan(fid_adc_out,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Delimiter',',');

    for i=1:32 
        adc_out(:,i)=var{i+1};
        %adc_out(:,i)= (adc_out(:,i) - mean(adc_out(:,i)))/rms(adc_out(:,i) - mean(adc_out(:,i)));
    end
    for ii=1:32,
        ENOB(kk,ii) = myenob(adc_out(:,ii), @our_hann, 0.1);
    end
    
    [max_ENOB(kk), max_ENOB_idx(kk)] = max(ENOB(kk,:));
end

figure(1)
plot(max_ENOB);

figure(2)
plot(max_ENOB_idx);