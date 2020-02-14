function outx = sinusx(in,f,n)

%% Input condition
% in is the input sinusoidal waveform
% f is the actual frequency (Fin/Fs)
% n must be integer multiples of the period

%% Make ideal sine and cosine sequence
sinx=sin(2*pi*f*[1:n]);
cosx=cos(2*pi*f*[1:n]);
%% Matching the number of input sequence
in=in(1:n);
%% Make Fourier series coefficient
a0 = sum(in)/n;
a1=2*sinx.*in;
a=sum(a1)/n;
b1=2*cosx.*in;
b=sum(b1)/n;

%% Synthesis first order wave from fourier series with first term
outx= a0+a*sinx + b*cosx;


%% Fourier series
% fx=a0/2+sum_infinite(an*cos(n*x)+bn*sin(n*x))
% an = 2/period * integral_period(fx*cos(n*x) dx
% bn = 2/period * integral_period(fx*sin(n*x) dx
% a0 = DC_term = sum_period(fx)/period

