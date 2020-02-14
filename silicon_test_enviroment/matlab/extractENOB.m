
%% Extract ENOB from output of the ADC with ideal DAC %%

function [Enob, YdB, NoisedB, SNDR, SFDR] = extractENOB(input,Fin,Fs)

%% input should be single row %%
if (size(input,1)~=1)
    input = input';
end

Nsamples = length(input);
%% Nsamples should be even %%
if (mod(Nsamples,2) ==1)        % mod() == 1 --> Nsample is odd.
    Nsamples = Nsamples(1:end-1);  % ????
end
%% remove DC offset %%%
% DC offset is not part of the signal nor the noise
input = input-mean(input);

%% extract sinusoidal and noise component%%
% ywindow = hann(Nsamples)';
% ywindow = blackman(Nsamples)';
% ywindow = boxcar(Nsamples)';
% ywindow = gaussianwin(Nsamples);  %% guassian window function
ywindow = ones(1,Nsamples);

ysignal = Nsamples/sum(ywindow)*sinusx(input.*ywindow,Fin/Fs,Nsamples);
%%ysignal = sinusx(input,Fin/Fs,Nsamples);
ynoise = input-ysignal;

%% Signal power
% Psignal = norm(fft(ysignal.*ywindow));
Psignal = sum(abs(fft(ysignal.*ywindow)).^2);
%% Noise power
% Pnoise = norm(fft(ynoise.*ywindow));
Pnoise = sum(abs(fft(ynoise.*ywindow)).^2);

%% Power calculation explanation %%%%%%%
% If signal is complex.
% power = sum(abs(signal).^2);
% also
% power = norm(signal).^2;
%  
% two expressions are exactly same
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Calculate SNDR, and ENOB
SNDR = 10*log10(Psignal/Pnoise);   %% dB translation about POWER
Enob = (SNDR - 1.76)/6.02;          

YdB = 20*log10(abs(fft(input.*ywindow)));

%% Calculate SFDR (spurious free dynamic range)
% No gaurantee
NoisedB= 20*log10(abs(fft(ynoise.*ywindow)));
SFDR=max(YdB)-max(NoisedB);


