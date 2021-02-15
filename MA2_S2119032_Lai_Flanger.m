%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         Code for part2,4 and beyond basic
%%%         Author:Nuolin Lai
%%%         Create Date:06/12/2020
%%%         Last modify date:10/12/2020
%%%         Flanger:
%%%               1.Basic Flanger
%%%               2.Circular buffer with Lagrange interpolation for N ~= 0
%%%               3.Circular shift with naive round for N == 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;

%define the parameter for Lagrange interpolation
N        = 2; % M must be even
Q        = 100;

%recall the Lagrange interpolation matrix
mtx      = MA2_S2119032_Lai_Linterp(N,Q,1);

%define the strength of the effect as g
g        = 0.7;

%define the delay time in seconds
t        = 0.005;

%coefficient of sine
a=1;

%import audio
[x,Fs]   = audioread('birchcanoe.wav');

%transfer to stereo audio
if size(x,2)==2
    x=0.5*x(:,1)+0.5*x(:,2);
end

%length of x;
L        = length(x);

%calculate the delay sample M
MO       = round(t*Fs/2);

%calculate the delay, keep every interpolation sample have N-1 neighbor
delay    = MO*2+N+1;

%frequency of LFO
fO       = 1;
 
%M vector
M        = (MO*(1+a*sin(2*pi*fO*(0:L-1)/Fs))).';

% row index
q   = 1:Q;

%introduce alpha vector based on Q
a_q      = (-Q/2+q-1)/Q;

%Nearest neighbor vector
NB       = 1-N/2:N/2;

%create zeros value vector
value    = zeros(N,1);

%zeros padding;
dlinebuf = zeros(delay,1);

%pre-allocate output vector of feedback operations
y_ff     = zeros(L,1);

if N~=0
    %Interpolation Method, Circular buffer：for loop to create y_ff vector
    for n = 1:L
        %calculate alpha
        alpha    = M(n)-floor(M(n))-1/2;
        %read the row from table
        [~,index] = sort(abs(a_q-alpha));
        coef      = mtx(index(1),:);
        %introduce weighted sum
        wsum=0;
        %for loop to create weighted sum
        for i = 1:N
            value(i)= dlinebuf(mod(mod(n-1,delay)+N/2+NB(i),delay)+1);
            wsum = wsum + value(i)*coef(i);
        end
        %read the weighted sum from the delay-line buffer corresponding to the
        %current delay-length and sum up with x(n)
        y_ff(n)   = wsum*g+x(n);
        %update delay line buffer
        dlinebuf(mod((n+delay-2),delay)+1) = x(n);
    end
else
    %naive round, Circular shift：for loop to create y_ff vector
    for n = 1:L
        y_ff(n)   = dlinebuf(floor(M(n))+1)*g+x(n);
        dlinebuf(delay) = x(n);
        dlinebuf    = circshift(dlinebuf,1);
    end
end

%play the sound
sound(y_ff,Fs)