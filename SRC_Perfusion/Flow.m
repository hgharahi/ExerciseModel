classdef Flow
    
    properties
        Q
        dQdt
        t
        dt
        Qclamped
        dQclampeddt
    end
    
    methods
        
        function    FlowRate = Flow(X, Y, t_off, t_final)
            
            FlowRate.t = t_off:0.01:(t_final+0.01);
            FlowRate.Q = Y;
            FlowRate.dt=[diff(FlowRate.t)];
%             FlowRate.dQdt = TwoPointDeriv(FlowRate.Q,FlowRate.dt);
            
            FlowRate.Qclamped = FlowRate.Q(end).*[(1-...
                exp(10*(FlowRate.t-t_off))./(exp(10*(FlowRate.t-t_off))+1))];
            
            FlowRate.dQclampeddt = TwoPointDeriv(FlowRate.Qclamped,FlowRate.dt);

        end
        
    end
end

function dAdt = TwoPointDeriv(A,dt)

dAdt(1,:) = (A(2)-A(1))./dt(1);
for i = 2:(length(A)-1)
    dAdt(i,:) = (A(i+1)-A(i-1))./(2*dt(i));
end
dAdt(length(A),:) = (A(length(A))-A(length(A)-1))./dt(end);
end

