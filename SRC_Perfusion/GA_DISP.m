function [state,options,optchanged] = GA_DISP(options,state,flag)

optchanged = false;

switch flag
    case 'iter'
        ibest = state.Best(end);
        ibest = find(state.Score == ibest,1,'last');
        bestx = state.Population(ibest,:);
        
        disp(['Best GA: ', num2str(bestx)]);
        
    otherwise
        disp(['intial or done =) ']);
        save LastPopulation.mat
end