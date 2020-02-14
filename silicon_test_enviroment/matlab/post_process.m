clear all;
close all;

%Fin=62.5e6
Fin=9.79611e9;
Fsample=1.25e9;
Fsample_ti=Fsample*16;




fid_adc_out=fopen('./tdc_dcdl_9.csv');
var = textscan(fid_adc_out,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','Delimiter',',');

phys_sample = [1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16];


for i=1:16 
	adc_out(:,i)=var{i+1};  
    adc_out(:,i)= (adc_out(:,i) - mean(adc_out(:,i)))/rms(adc_out(:,i) - mean(adc_out(:,i)));
    %adc_out(:,i)= (adc_out(:,i))/rms(adc_out(:,i));
end


adc_out_ti = zeros(16*length(var{1}),1);

freq = 4.096;

num_phase = 2048;
correlate_matrix = zeros(num_phase, 4);

phase_offset = zeros(4,1);

for i=1:4,
   for j=1:num_phase, 
        new_sin_val = sin(freq*2*pi*(0:1:1023)/1024 + (j-1)/num_phase*2*pi);
        correlate_matrix(j,i) = sum(sum(new_sin_val*adc_out(:,i:4:16)));
   end
   [max_val, phase_offset(i)] = max(correlate_matrix(:,i));
   phase_offset(i) = phase_offset(i)/num_phase*360;
end

phase_offset = phase_offset - phase_offset(1);
phase_offset = phase_offset.*(phase_offset >= 0) + (phase_offset < 0).*(360 + phase_offset);

for i=1:4,
    phase_offset_adj(i) = ((i-1)*90 - phase_offset(i))/360*200/0.65;
end


for i=1:16
    adc_out_ti(i:16:end) = adc_out(:,i);
end

L = floor(length(var{1})/2)*2;
L_ti=length(adc_out_ti);

figure(1)
[Enob1, Ydb1, Noisedb1, SNDR1, SFDR1] = extractENOB(adc_out_ti,Fin,Fsample_ti);
semilogx(linspace(0,Fsample_ti/2,L_ti/2)*1e-6, Ydb1(1:L_ti/2)-max(Ydb1),'k');hold on; grid on; xlabel('Frequency [MHz]'); ylabel('FFT [dB]'); axis([10 Fsample_ti/2/1e6 -100 0]);

Enob1
SNDR1
SFDR1

k=10


figure(2)
[Enob2, Ydb2, Noisedb2, SNDR2, SFDR2] = extractENOB(adc_out(:,k),Fin,Fsample);
%semilogx(linspace(0,Fsample/2,L/2)*1e-6, Ydb2(1:L/2)-max(Ydb2),'k');hold on; grid on; xlabel('Frequency [MHz]'); ylabel('FFT [dB]'); axis([10 Fsample/2/1e6 -100 0]);
plot(linspace(0,Fsample/2,L/2)*1e-6, Ydb2(1:L/2)-max(Ydb2),'k');hold on; grid on; xlabel('Frequency [MHz]'); ylabel('FFT [dB]'); axis([10 Fsample/2/1e6 -100 0]);
%k=14;
%hold on;
%[Enob2, Ydb2, Noisedb2, SNDR2, SFDR2] = extractENOB(adc_out(:,k),Fin,Fsample);
%semilogx(linspace(0,Fsample/2,L/2)*1e-6, Ydb2(1:L/2)-max(Ydb2),'k');hold on; grid on; xlabel('Frequency [MHz]'); ylabel('FFT [dB]'); axis([10 Fsample/2/1e6 -100 0]);
%plot(linspace(0,Fsample/2,L/2)*1e-6, Ydb2(1:L/2)-max(Ydb2),'r');hold on; grid on; xlabel('Frequency [MHz]'); ylabel('FFT [dB]'); axis([10 Fsample/2/1e6 -100 0]);


Enob2
SNDR2
SFDR2



ENOB = zeros(16,1);
NOISEDB = zeros(16,1);
SFDR    = zeros(16,1);
SNDR    = zeros(16,1);
for ii=1:16,
    disp(ii);
    ENOB(ii) = myenob(adc_out(:,ii), @our_hann, 0.03);
end 

myenob(adc_out_ti, @our_hann, 0.001)

figure(3);
plot(ENOB);
min(abs(adc_out))
%{

figure(3)
hist(Tpfd_out_signed,64);xlabel('code');ylabel('histogram');
figure(4)
hist(ADC_OUT,64);grid on;xlabel('code');ylabel('histogram');


amp_Tpfd_out_signed = max(Tpfd_out_signed)-min(Tpfd_out_signed)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TDC delaychain delay spread %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tstart = 132.725e-9+250e-12;
window_index = find (inv_out > Tstart  & inv_out < Tstart+1e-9);
inv_out_window = inv_out(window_index)-Tstart;
figure(5)
hist(inv_out_window,1e-9/64*[1:1:64]);grid on; axis([0 1e-9 0 12]);xlabel('delay phase');ylabel('histogram');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ADC_OUT_DC for ramp input %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Asin=400e-12;
Navg=10;

index=find(tin<Asin);
ADC_OUT_DC = adder_out(index);

L_DC = length(ADC_OUT_DC);
L_avg = L_DC/Navg;
for i=1:L_avg
ADC_OUT_DC_avg(i) = round(sum(ADC_OUT_DC(Navg*(i-1)+1:Navg*i))/Navg);
end



for k=2:L_avg-1
if (ADC_OUT_DC_avg(k)~= ADC_OUT_DC_avg(k-1) & ADC_OUT_DC_avg(k)~= ADC_OUT_DC_avg(k+1)) ADC_OUT_DC_avg(k)=ADC_OUT_DC_avg(k+1);
end
end

figure(6)
plot(ADC_OUT_DC_avg);grid on;hold on;xlabel('Tin[0.1ps]');ylabel('ADC_{OUT}');
ADC_OUT_DC_avg_shift = [ADC_OUT_DC_avg(2:end) ADC_OUT_DC_avg(end)]; 

idx_transition = find(ADC_OUT_DC_avg ~= ADC_OUT_DC_avg_shift);
T_transition = [0 idx_transition]*1e-13;
code_width = diff(T_transition);

Nadc_target=8;
ideal_code_width = 1.000e-9/2^Nadc_target;
DNL = (code_width-ideal_code_width)/ideal_code_width; 

%for i=1:L_avg
%ADC_OUT_DC_ideal(i)=ADC_OUT_DC_avg(1)+floor(i*0.1e-12/ideal_code_width);
%end
%plot(ADC_OUT_DC_ideal,'r')

figure(7);
plot(DNL);grid on;xlabel('code segment');ylabel('DNL [LSB]');


%% INL (end-to-end)
TF_slope = (ADC_OUT_DC_avg(end)-ADC_OUT_DC_avg(1)+1)/L_avg;
TF_offset =ADC_OUT_DC_avg(1)-1/2;
TF_end2end=TF_slope*[1:1:L_avg]+TF_offset;

figure(8)
subplot(2,1,1);plot(TF_end2end,'m-');grid on; hold on;ylabel('ADC_{OUT}');
subplot(2,1,1);plot(ADC_OUT_DC_avg);grid on; hold on;
INL_end2end=ADC_OUT_DC_avg-TF_end2end;
subplot(2,1,2);plot(INL_end2end);grid on;xlabel('Tin [0.1ps]'); ylabel('INL_{end2end} [code]');



%% INL (best-fit)
range_TF_slope=0.2;
range_TF_offset=0.2;

N_TF_slope = 101;
N_TF_offset = 101;
cost=zeros(N_TF_slope,N_TF_offset);

for i=1:N_TF_slope
	for j=1:N_TF_offset
		hypo=TF_slope*(1+range_TF_slope*(i-ceil(N_TF_slope/2))/floor(N_TF_slope/2))*[1:1:L_avg]+TF_offset*(1+range_TF_slope*(j-ceil(N_TF_offset/2))/floor(N_TF_offset/2));
		cost(i,j)= sum((hypo-ADC_OUT_DC_avg).^2);
	end
end

figure(9)
surf([1:1:N_TF_slope],[1:1:N_TF_offset],cost);xlabel('slope');ylabel('offset');

[min_cost min_idx]=(min(cost(:)));
[idx_opt_slope idx_opt_offset] = ind2sub(size(cost),min_idx)

TF_BF=TF_slope*(1+range_TF_slope*(idx_opt_slope-ceil(N_TF_slope/2))/floor(N_TF_slope/2))*[1:1:L_avg]+TF_offset*(1+range_TF_slope*(idx_opt_offset-ceil(N_TF_offset/2))/floor(N_TF_offset/2));
TF_BF_stair=round(TF_BF);

figure(10)
subplot(2,1,1);plot(TF_BF,'m-');grid on; hold on;
subplot(2,1,1);plot(ADC_OUT_DC_avg);grid on; hold on;
subplot(2,1,1);plot(TF_BF_stair,'r-');xlabel('Tin [0.1ps]');ylabel('ADC_{OUT}');

INL_BF=ADC_OUT_DC_avg-TF_BF;
subplot(2,1,2);plot(INL_BF);grid on;xlabel('Tin [0.1ps]'); ylabel('INL_{bestfit} [code]');

%% INL (best-fit) horizontal

T_transition_ideal = zeros(max(TF_BF_stair),1);
T_transition_actual = zeros(max(TF_BF_stair),1);

for k=2:max(TF_BF_stair)
	if ismember(k,TF_BF_stair)
		idx = find(TF_BF_stair == k);
		T_transition_ideal(k) = idx(end);
	else
		T_transition_ideal(k) = T_transition_ideal(k-1);
	end
	
	if ismember(k,ADC_OUT_DC_avg)
		idx = find(ADC_OUT_DC_avg == k);
		T_transition_actual(k) = idx(end);
	else
		T_transition_actual(k) = T_transition_actual(k-1);
	end
end

T_transition_error=T_transition_actual-T_transition_ideal;
INL_hori=T_transition_error(min(TF_BF_stair):max(TF_BF_stair))/ideal_code_width*1e-13;

figure(11);
plot([min(TF_BF_stair):1:max(TF_BF_stair)],INL_hori);grid on;xlabel('code');ylabel('INL_{bestfit} [LSB]');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TDC input pulse delay spead %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Dpfd_out=Dpfd_out-Dpfd_out(1);
%pfd_out_delay_spread = max(Dpfd_out)-min(Dpfd_out)
%figure(7)
%hist(Dpfd_out(2:end),100); grid on; axis([0 120e-12 0 120]);

%}

