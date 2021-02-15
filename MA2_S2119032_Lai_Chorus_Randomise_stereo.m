%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         code for part three, four and beyond basic
%%%         Author:Nuolin Lai
%%%         Create Date:06/12/2020
%%%         Last modify date:10/12/2020
%%%         Chorus:
%%%                1.Basic Chorus
%%%                2.Circular shift
%%%                3.Lagrange interpolation when N~=0,naive round when N==0
%%%                4.Randomised delay
%%%                5.Stereo chorus
%%%                6.vector processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;

%define the parameter for Lagrange interpolation
N        = 10; %N must be even
Q        = 100;

%recall the Lagrange interpolation matrix
mtx      = MA2_S2119032_Lai_Linterp(N,Q,1);

%import audio
[x,Fs]   = audioread('mozart.wav');

%define buffer time for LFO1~4 
%LFO1 2 is for left channel,LFO3 4 is for right channel
t1       = 0.05;
t2       = 0.1;
t3       = 0.02;
t4       = 0.15;
t=[t1,t2,t3,t4];

PO       = zeros(4,1);

%effect depth for LFO 1
for l = 1:4
    PO(l) = round(t(l)/2*Fs);
end

%effect oscillation/swing range for LFO 1 2 3 4
D1       = round(t1/2*Fs);
D2       = round(t2/3*Fs);
D3       = round(t3/4*Fs);
D4       = round(t4/2*Fs);
D        = [D1,D2,D3,D4];

%LFO frequency for LFO 1 2 3 4
f1       = 1;
f2       = 2;
f3       = 3;
f4       = 0.5;
f        = [f1,f2,f3,f4];

%effect strength, set between -1 and 1, for LFO 1 2 3 4
g1       = 0.7;
g2       = 0.4;
g3       = 0.6;
g4       = 0.4;
g        = [g1,g2,g3,g4];

%define the delay time in seconds
t        = max(t);

%calculate the delay
delay    = round(t*Fs/2)*2;

%length of x;
L        = length(x);

%initialize M vector
M        = zeros(L,4);

%initialize m vector  random signal
m        = zeros(4,L);

%create random swing signal based on sine
for l=1:4
    m(l,:)=randomsignal(L,Fs,f(l));
    %Normalise 
    m(l,:)=(D(l)/2)/max(abs(m(l,:)))*m(l,:);
    %final signal for M
    M(:,l)=((PO(l)-max(m(l,:)))+m(l,:))';
end

% row index
q   = 1:Q;

%introduce alpha vector based on Q
a_q      = (-Q/2+q-1)/Q;

%Nearest neighbor vector
NB       = 1-N/2:N/2;

%create delay buffer 1;
dlinebuf  = zeros(delay,1);

%pre-allocate output vector of feedback operations
y_L        = zeros(L,1);
y_R        = zeros(L,1);

%initialize vector for loop filling in 
alpha    = zeros(4,1);
coef     = zeros(4,N);
index    = zeros(4,Q);
value    = zeros(N,4);

if N ~= 0
    %for loop to create left channel output
    for n = 1:L
        %wsum return to zero for each n
        wsum     = zeros(4,1);
        for l = 1:4
            %calculate alpha
            alpha(l)       = M(n,l)-floor(M(n,l))-1/2;
            %read the row from table
            [~,index(l,:)] = sort(abs(a_q-alpha(l)));
            coef(l,:)      = mtx(index(l,1),:);
            %calculate wsum vector for each n
            for i = 1:N
                value(i,l) = dlinebuf(floor(M(n,l))+NB(i)+N/2);
                wsum(l)    = wsum(l) + value(i,l)*coef(l,i);
            end
        end
        %calculate Left and right channel seperately
        y_L(n)             = wsum(1)*g(1)+wsum(2)*g(2)+x(n);
        y_R(n)             = wsum(3)*g(3)+wsum(4)*g(4)+x(n);
        %update delay buffer1
        dlinebuf(delay)    = x(n);
        dlinebuf           = circshift(dlinebuf,1);
    end
else
    %circshift,naive round for dlinebuf index
    for n=1:L
        for l = 1:4
        y_L(n)   =dlinebuf(floor(M(n,1))+1)*g(1)+dlinebuf(floor(M(n,1))+1)*g(2)+x(n);
        y_R(n)   =dlinebuf(floor(M(n,2))+1)*g(3)+dlinebuf(floor(M(n,2))+1)*g(4)+x(n);
        end
    %update delay buffer
    dlinebuf(delay) = x(n);
    dlinebuf    = circshift(dlinebuf,1);
    end
end
%combine L R to one matrix
y(:,1)=y_L;
y(:,2)=y_R;
%play the sound
sound(y,Fs)
