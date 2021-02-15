%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         code for beyond basic
%%%         Author:Nuolin Lai
%%%         Create Date:09/12/2020
%%%         Last modify date:10/12/2020
%%%         randomsignal:
%%%                1.Bilinear transformation to create lowpass filter
%%%                2.Use the combination of sine and random signal with
%%%                lowpass filter to create random and smooth signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = randomsignal(L,fs,f0)

t = (0:L-1)/fs;

%initialize random number generator
%rng default 

%create random signal based on sine
x = sin(2*pi*f0*t) + 10*randn(size(2*pi*f0*t));

%low pass parameter
fc=f0/5;
Q=0.7;

%calculate coefficient of double second order filter for lowpass filter
K=tan(pi*fc/fs);
u=K^2*Q+K+Q;

b0 = (K^2*Q)/u;
b1 =(2*K^2*Q)/u;
b2 =(K^2*Q)/u;
a1 =(2*Q*(K^2-1))/u;
a2 =(K^2*Q-K+Q)/u;
a = [  1, a1, a2];
b = [ b0, b1, b2];

%process x by low pass filter 
y=filter(b,a,x);
end