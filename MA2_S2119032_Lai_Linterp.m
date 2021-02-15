%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         code for part 4
%%%         Author:Nuolin Lai
%%%         Create Date:09/12/2020
%%%         Last modify date:10/12/2020
%%%         Lagrange interpolation fuction to create a Q row and N colume
%%%         matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mtx = MA2_S2119032_Lai_Linterp(N,Q,fmode)

%assert if N is an even number
if mod(N,2)~=0
    fprintf('please enter an even integer N.....');
    assert(mod(N,2)==0);
end
%calculate the interpolation matrix
if fmode==1
    %define zeros matrix with Q row and N colume
    mtx = zeros(Q,N);
    % row index
    q   = 1:Q;
    % colume index
    n   = 1:N;
    % values vector of alpha
    a_q = (-Q/2+q-1)/Q;
    % coefficient of the N Lagrange polynomials
    p   = -(N-1)/2:1:(N-1)/2;
    % for loop to create matrix
    for j = n
        for i = q
        %expression of matrix
        mtx(i,j) = prod(a_q(i)-p(p~=p(j)))/prod(-p(p~=p(j))+p(j));
        end
    end
%do the same thing as above
elseif fmode==2
    mtx = zeros(Q,N);
    q   = 1:Q;
    n   = 1:N;
    %slightly change the range of alpha
    a_q = linspace(-(N-1)/2,(N-1)/2,Q);
    p   = -(N-1)/2:1:(N-1)/2;
    for j = n
        for i = q
        mtx(i,j) = prod(a_q(i)-p(p~=p(j)))/prod(-p(p~=p(j))+p(j));
        end
    end
    %plot the matrix
    plot(a_q,mtx,'LineWidth',1.5);
    legend(num2str((-(N-1)/2:(N-1)/2)'))
    xlabel('alpha');
    title('Lagrange Interpolation')
end