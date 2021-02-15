%evaluate the efficience of three intepolation method
clear all;
clc;
tic;
mtx1 = MA2_S2119032_Lai_Linterp_withoutloop1(100,100,1);
t1=toc;

tic

mtx2 = MA2_S2119032_Lai_Linterp_withoutloop2(100,100,1);
t2=toc;

tic

mtx3 = MA2_S2119032_Lai_Linterp(100,100,1);
t3=toc;
