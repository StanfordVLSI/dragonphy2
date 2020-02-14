clear all
close all

load('./Enob_w_PR.mat');
Enob_w_PR = Enob;
%load('./Enob_data_tree.mat');
%Enob_data_tree = Enob;
%load('./Enob_data_tree_setuphold.mat');
%Enob_data_tree_setuphold = Enob;

Fin=314.159265358979e6;
Fsample=1e9;

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

k=1;
tin_var = textscan(fid_tin(k),'%f','Headerlines',102);
adder_out_var = textscan(fid_adder_out(k),'%f','Headerlines',104);
tin_raw = tin_var{1};
adder_out_raw = adder_out_var{1};

L1=length(tin_raw);
L2=length(adder_out_raw);
L=floor(min(L1,L2)/2)*2;

ADC_offset =22;
%ADC_offset =49;
ADC_OUT = zeros(L,32);

for k=2:32
tin_var = textscan(fid_tin(k),'%f','Headerlines',102);
adder_out_var = textscan(fid_adder_out(k),'%f','Headerlines',104);
tin_raw = tin_var{1};
adder_out_raw = adder_out_var{1};
tin=tin_raw(1:L);
adder_out=adder_out_raw(1:L);
tin_sign = sign(tin);
ADC_OUT(:,k)= (adder_out-ADC_offset).*circshift(tin_sign,0);
[Enob(k), Ydb, Noisedb, SNDR, SFDR] = extractENOB(ADC_OUT(:,k),Fin,Fsample);
end

figure(1)
plot(Enob_w_PR(2:end-3),'r','LineWidth',2);grid on; hold on;xlabel('dcdl code');ylabel('ENOB')
plot(Enob(2:end-3),'b','LineWidth',2);grid on;




