clear all
close all

%load('./DNLmax_wo_PR.mat');
%DNLmax_wo_PR = DNLmax;
%load('./INLmax_wo_PR.mat');
%INLmax_wo_PR = INLmax;

fid_tin=zeros(32,1);
fid_adder_out=zeros(32,1);

fid_tin(1)=fopen('./dump_out/tin_1.txt');
fid_tin(2)=fopen('./dump_out/tin_2.txt');
fid_tin(3)=fopen('./dump_out/tin_3.txt');
fid_tin(4)=fopen('./dump_out/tin_4.txt');
fid_tin(5)=fopen('./dump_out/tin_5.txt');
fid_tin(6)=fopen('./dump_out/tin_6.txt');
fid_tin(7)=fopen('./dump_out/tin_7.txt');
fid_tin(8)=fopen('./dump_out/tin_8.txt');
fid_tin(9)=fopen('./dump_out/tin_9.txt');
fid_tin(10)=fopen('./dump_out/tin_10.txt');
fid_tin(11)=fopen('./dump_out/tin_11.txt');
fid_tin(12)=fopen('./dump_out/tin_12.txt');
fid_tin(13)=fopen('./dump_out/tin_13.txt');
fid_tin(14)=fopen('./dump_out/tin_14.txt');
fid_tin(15)=fopen('./dump_out/tin_15.txt');
fid_tin(16)=fopen('./dump_out/tin_16.txt');
fid_tin(17)=fopen('./dump_out/tin_17.txt');
fid_tin(18)=fopen('./dump_out/tin_18.txt');
fid_tin(19)=fopen('./dump_out/tin_19.txt');
fid_tin(20)=fopen('./dump_out/tin_20.txt');
fid_tin(21)=fopen('./dump_out/tin_21.txt');
fid_tin(22)=fopen('./dump_out/tin_22.txt');
fid_tin(23)=fopen('./dump_out/tin_23.txt');
fid_tin(24)=fopen('./dump_out/tin_24.txt');
fid_tin(25)=fopen('./dump_out/tin_25.txt');
fid_tin(26)=fopen('./dump_out/tin_26.txt');
fid_tin(27)=fopen('./dump_out/tin_27.txt');
fid_tin(28)=fopen('./dump_out/tin_28.txt');
fid_tin(29)=fopen('./dump_out/tin_29.txt');
fid_tin(30)=fopen('./dump_out/tin_30.txt');
fid_tin(31)=fopen('./dump_out/tin_31.txt');
fid_tin(32)=fopen('./dump_out/tin_0.txt');

fid_adder_out(1)=fopen('./dump_out/adder_out_1.txt');
fid_adder_out(2)=fopen('./dump_out/adder_out_2.txt');
fid_adder_out(3)=fopen('./dump_out/adder_out_3.txt');
fid_adder_out(4)=fopen('./dump_out/adder_out_4.txt');
fid_adder_out(5)=fopen('./dump_out/adder_out_5.txt');
fid_adder_out(6)=fopen('./dump_out/adder_out_6.txt');
fid_adder_out(7)=fopen('./dump_out/adder_out_7.txt');
fid_adder_out(8)=fopen('./dump_out/adder_out_8.txt');
fid_adder_out(9)=fopen('./dump_out/adder_out_9.txt');
fid_adder_out(10)=fopen('./dump_out/adder_out_10.txt');
fid_adder_out(11)=fopen('./dump_out/adder_out_11.txt');
fid_adder_out(12)=fopen('./dump_out/adder_out_12.txt');
fid_adder_out(13)=fopen('./dump_out/adder_out_13.txt');
fid_adder_out(14)=fopen('./dump_out/adder_out_14.txt');
fid_adder_out(15)=fopen('./dump_out/adder_out_15.txt');
fid_adder_out(16)=fopen('./dump_out/adder_out_16.txt');
fid_adder_out(17)=fopen('./dump_out/adder_out_17.txt');
fid_adder_out(18)=fopen('./dump_out/adder_out_18.txt');
fid_adder_out(19)=fopen('./dump_out/adder_out_19.txt');
fid_adder_out(20)=fopen('./dump_out/adder_out_20.txt');
fid_adder_out(21)=fopen('./dump_out/adder_out_21.txt');
fid_adder_out(22)=fopen('./dump_out/adder_out_22.txt');
fid_adder_out(23)=fopen('./dump_out/adder_out_23.txt');
fid_adder_out(24)=fopen('./dump_out/adder_out_24.txt');
fid_adder_out(25)=fopen('./dump_out/adder_out_25.txt');
fid_adder_out(26)=fopen('./dump_out/adder_out_26.txt');
fid_adder_out(27)=fopen('./dump_out/adder_out_27.txt');
fid_adder_out(28)=fopen('./dump_out/adder_out_28.txt');
fid_adder_out(29)=fopen('./dump_out/adder_out_29.txt');
fid_adder_out(30)=fopen('./dump_out/adder_out_30.txt');
fid_adder_out(31)=fopen('./dump_out/adder_out_31.txt');
fid_adder_out(32)=fopen('./dump_out/adder_out_0.txt');

%k=1
%tin_var = textscan(fid_tin(k),'%f','Headerlines',102);
%adder_out_var = textscan(fid_adder_out(k),'%f','Headerlines',104);
%tin_raw = tin_var{1};
%adder_out_raw = adder_out_var{1};


Asin=400e-12;
Navg=10;

for k=2:29

tin_var = textscan(fid_tin(k),'%f','Headerlines',102);
adder_out_var = textscan(fid_adder_out(k),'%f','Headerlines',104);
tin_raw = tin_var{1};
adder_out_raw = adder_out_var{1};

L1=length(tin_raw);
L2=length(adder_out_raw);
L=floor(min(L1,L2)/2)*2;

tin=tin_raw(1:L);
adder_out=adder_out_raw(1:L);

index=find(tin<Asin);
ADC_OUT_DC = adder_out(index);

L_DC = length(ADC_OUT_DC);
L_avg = L_DC/Navg;
for i=1:L_avg
ADC_OUT_DC_avg(i) = round(sum(ADC_OUT_DC(Navg*(i-1)+1:Navg*i))/Navg);
end

for m=2:L_avg-1
if (ADC_OUT_DC_avg(m)~= ADC_OUT_DC_avg(m-1) & ADC_OUT_DC_avg(m)~= ADC_OUT_DC_avg(m+1)) ADC_OUT_DC_avg(m)=ADC_OUT_DC_avg(m+1);
end
end

ADC_OUT_DC_avg_shift = [ADC_OUT_DC_avg(2:end) ADC_OUT_DC_avg(end)];
idx_transition = find(ADC_OUT_DC_avg ~= ADC_OUT_DC_avg_shift);
T_transition = [0 idx_transition]*1e-13;
code_width = diff(T_transition);

%% DNL
Nadc_target=8;
ideal_code_width = 1.000e-9/2^Nadc_target;
DNL = (code_width-ideal_code_width)/ideal_code_width;
DNLmax(k)=max(DNL);

TF_slope = (ADC_OUT_DC_avg(end)-ADC_OUT_DC_avg(1)+1)/L_avg;
TF_offset =ADC_OUT_DC_avg(1)-1/2;


%bestfit
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
[min_cost min_idx]=(min(cost(:)));
[idx_opt_slope idx_opt_offset] = ind2sub(size(cost),min_idx);

TF_BF=TF_slope*(1+range_TF_slope*(idx_opt_slope-ceil(N_TF_slope/2))/floor(N_TF_slope/2))*[1:1:L_avg]+TF_offset*(1+range_TF_slope*(idx_opt_offset-ceil(N_TF_offset/2))/floor(N_TF_offset/2));
TF_BF_stair=round(TF_BF);



%% INL
T_transition_ideal = zeros(max(TF_BF_stair),1);
T_transition_actual = zeros(max(TF_BF_stair),1);

for p=2:max(TF_BF_stair)
    if ismember(p,TF_BF_stair)
        idx = find(TF_BF_stair == p);
        T_transition_ideal(p) = idx(end);
    else
        T_transition_ideal(p) = T_transition_ideal(p-1);
    end

    if ismember(p,ADC_OUT_DC_avg)
        idx = find(ADC_OUT_DC_avg == p);
        T_transition_actual(p) = idx(end);
    else
        T_transition_actual(p) = T_transition_actual(p-1);
    end
end

T_transition_error=T_transition_actual-T_transition_ideal;
INL_hori=T_transition_error(min(TF_BF_stair):max(TF_BF_stair))/ideal_code_width*1e-13;

T_transition_error=T_transition_actual-T_transition_ideal;
INL_hori=T_transition_error(min(TF_BF_stair):max(TF_BF_stair))/ideal_code_width*1e-13;
INLmax(k)=max(abs(INL_hori));

end

figure(1)
plot(DNLmax(2:end),'r');grid on;xlabel('dcdl code');ylabel('DNL [LSB]');hold on;
%plot(DNLmax_wo_PR(2:end),'b');grid on;xlabel('dcdl code');ylabel('DNL [LSB]');hold on;

figure(2)
plot(INLmax(2:end),'r');grid on;xlabel('dcdl code');ylabel('INL_{bestfit} [LSB]');hold on;
%plot(INLmax_wo_PR(2:end),'b');grid on;xlabel('dcdl code');ylabel('INL_{bestfit} [LSB]');hold on;





