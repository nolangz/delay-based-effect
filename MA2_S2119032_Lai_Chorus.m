%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         code for part three and four
%%%         Author:Nuolin Lai
%%%         Create Date:06/12/2020
%%%         Last modify date:16/12/2020
%%%         Chorus:
%%%                1.Circular shift 
%%%                2.Naive round and Lagrange interpolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;

%define the parameter for Lagrange interpolation
N        = 10;%N should be even only
Q        = 100;

%recall the Lagrange interpolation matrix
mtx      = MA2_S2119032_Lai_Linterp(N,Q,1);

%import audio
[x,Fs]   = audioread('birchcanoe.wav');

%transfer to stereo audio
if size(x,2)==2
    x=0.5*x(:,1)+0.5*x(:,2);
end

%time for max delay in M1 and M2
t1       = 0.05;
t2       = 0.1;

%define the delay time in seconds
t        = max(t1,t2);

%calculate the delay
delay    = round(t*Fs/2)*2;

%effect depth for LFO 1
PO1      = round(t1*Fs);
%effect oscillation/swing range for LFO 1
D1       = round(t1/2*Fs);
%LFO frequency for LFO 1
f1       = 1;
%effect strength, set between -1 and 1, for LFO 1
g1       = 0.4;

%effect depth for LFO 2
PO2      = round(t2*Fs/2);
%effect oscillation/swing range for LFO 2
D2       = round(t2/5*Fs);
%LFO frequency for LFO 2
f2       = 2;
%effect strength, set between -1 and 1, for LFO 1
g2       = 0.4;

%length of x;
L        = length(x);

%LFO vector M1
M1        = (PO1*(1+D1/PO1*sin(2*pi*f1*(0:L-1)/Fs))).';

%LFO vector M2
M2        = (PO2*(1+D2/PO2*sin(2*pi*f2*(0:L-1)/Fs))).';

% row index
q   = 1:Q;

%introduce alpha vector based on Q
a_q      = (-Q/2+q-1)/Q;

%Nearest neighbor vector
NB       = 1-N/2:N/2;

%create zeros value vector
value1    = zeros(N,1);

%create zeros value vector
value2    = zeros(N,1);

%create delay buffer 1;
dlinebuf  = zeros(delay,1);

%pre-allocate output vector of feedback operations
y_ff      = zeros(L,1);

if N~=0
    %for loop to create y_fb vector
    for n = 1:L
        %calculate alpha
        alpha1    = M1(n)-floor(M1(n))-1/2;
        %read the row from table
        [~,index1] = sort(abs(a_q-alpha1));
        coef1      = mtx(index1(1),:);
        %introduce weighted sum to zero for each n
        wsum1=0;
        %for loop to create weighted sum
        for i = 1:N
            value1(i)= dlinebuf(floor(M1(n))+NB(i)+N/2);
            wsum1 = wsum1 + value1(i)*coef1(i);
        end
        %calculate alpha
        alpha2     = M2(n)-floor(M2(n))-1/2;
        %read the row from table
        [~,index2] = sort(abs(a_q-alpha2));
        coef2      = mtx(index2(1),:);
        %introduce weighted sum
        wsum2=0;
        %for loop to create weighted sum to zero for each n
        for i = 1:N
            value2(i)= dlinebuf(floor(M2(n))+NB(i)+N/2);
            wsum2 = wsum2 + value2(i)*coef2(i);
        end
        %read from the locationo in the delay-line buffer corresponding to the
        %current delay-length and sum up with x(n)
        y_ff(n)   =wsum1*g1+wsum2*g2+x(n);
        %update delay buffer1
        dlinebuf(delay) = x(n);
        dlinebuf    = circshift(dlinebuf,1);
    end
else
    for n=1:L
        y_ff(n)   =dlinebuf(floor(M1(n))+1)*g1+dlinebuf(floor(M1(n))+1)*g2+x(n);
        %update delay buffer1
        dlinebuf(delay) = x(n);
        dlinebuf    = circshift(dlinebuf,1);
    end
end
%play the sound
sound(y_ff,Fs)
