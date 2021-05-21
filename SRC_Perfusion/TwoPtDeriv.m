function dA = TwoPtDeriv(A,dt)

dA(1,:) = (A(2)-A(1))./dt;
for i = 2:(length(A)-1)
    dA(i,:) = (A(i+1)-A(i-1))./(2*dt);
end
dA(length(A),:) = (A(length(A))-A(length(A)-1))./dt;
end