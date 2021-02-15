%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         Code for part one and beyond basic
%%%         Author:Nuolin Lai
%%%         Create Date:06/12/2020
%%%         Last modify date:10/12/2020
%%%         Comb filter:
%%%                    1.feedforward comb filter
%%%                    2.feedback comb filter
%%%                    3.circular buffer for feedforward comb filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;

%define the strength of the effect as g
g        = 0.7;

%define the delay time in seconds
t        = 0.15;

%import audio
[x,Fs]   = audioread('birchcanoe.wav');

%transfer to stereo audio
if size(x,2)==2
    x=0.5*x(:,1)+0.5*x(:,2);
end

%Length of original x
L        = length(x);

%calculate the delay sample M
M        = round(t*Fs);

%pre-allocate delay-line buffer as dlinebuf;
dlinebuf = zeros(M,1);

%create output vector of feedforward and feedback operations
y_ff     = zeros(L,1);
y_fb     = zeros(L,1);

%Circular_buffer:for loop to create y_ff vector
for n = 1:L
    y_ff(n)   = dlinebuf(mod(n-1,M)+1)*g+x(n);
    %update buffer
    dlinebuf(mod((n+M-2),M)+1) = x(n);
end

% %Circularshift to create y_ff vector
% for n = 1:L
%     y_ff(n)   = dlinebuf(M)*g+x(n);
%     %update buffer
%     dlinebuf(M) = x(n);
%     dlinebuf    = circshift(dlinebuf,1);
% end

%pre-allocate delay-line buffer as dlinebuf
dlinebuf = zeros(M,1);

%for loop to create y_fb vector
for n = 1:L
    y_fb(n)   = -dlinebuf(M)*g+x(n);
    %update buffer
    dlinebuf(M) = y_fb(n);
    dlinebuf    = circshift(dlinebuf,1);
end

%sound(y_ff,Fs)
sound(y_ff,Fs)
