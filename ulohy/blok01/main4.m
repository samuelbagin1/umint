%% uloha 4, GA


% x1 - bezne akcie (4%)
% x2 - preferovane akcie (7%)
% x3 - podnikove dlhopisy (11%)
% x4 - statne dlhopisy (6%)
% x5 - uspory v banke (5%)


% x1+x2+x3+x4+x5<=10000000
% x1+x2<=2500000
% -x4+x5<=0
% -0.5x1-0.5x2+0.5x3+0.5x4-0.5x5<=0
% x1,x2,x3,x4,x5 >=0

% F(x) = f(x)+pokuta - ak x z P tak f(x) ak nie tak pokuta

num_runs = 10;      
numgen = 200;       
lpop = 100;          % velkost pop
dim = 5;            % 5 premennych - pocet investicii
mr = 0.2;           
elite_count = 2;    
penalty_method = 3; % 1 - mrtva, 2 - stupnova, 3 - umerna


Space = [zeros(1,dim);      
         ones(1,dim)*10000000];  % 10mil
Amp = ones(1,dim)*10000;  
%Amp = [-10000, 10000, 10000, 10000, 10000];
% Nums = ones(elite_count,dim);



figure;
all_fittrend = zeros(num_runs, numgen);
best_solutions = zeros(num_runs, dim);
best_fitnesses = zeros(1, num_runs);


for run = 1:num_runs
    % inicializacia populacie
    Pop = genrpop(lpop, Space);
    Pop = change(Pop, 2, Space); % eliminacia duplicit

    fittrend = zeros(1, numgen);
    
    for gen = 1:numgen
        % vypocet fitness pre celu pop
        Fit = zeros(lpop, 1);
        for i = 1:lpop
            Fit(i) = pen(Pop(i,:), penalty_method);
        end
        
        % ulozenie naj fit
        fittrend(gen) = min(Fit);
        
        %%%%%%%%%%% GA %%%%%%%%%%%%%%
        % elitarny vyber
        Elite = selbest(Pop, Fit, elite_count);
        Diverse = seldiv(Pop, Fit, elite_count, 0);
        
        % rul vyber, 2 bodove kriz
        Parents = selsus(Pop, Fit, lpop - 2*elite_count);
        %Cross = crossov(Parents, 2, 0);
        Cross = around(Parents, 0, 2, Space);
        
        Cross = mutx(Cross, 0.4, Space);
        Cross = muta(Cross, 0.3, Amp, Space);
        Cross = shake(Cross, 0.3);
        
        %Pop = [Elite; Cross];
        Pop = [Elite; Diverse; Cross];
        Pop = change(Pop, 0, Space);

    end
    
    % ulozenie vysledkov
    all_fittrend(run, :) = fittrend;
    best_solutions(run, :) = Pop(1, :);
    best_fitnesses(run) = pen(Pop(1, :), penalty_method);
    
    % vykreslenie
    plot(-fittrend);
    hold on;
   

    fprintf('BEH %d: fitness = %.2f\n', run, -best_fitnesses(run));
end

% format grafu
title('GA invest');
xlabel('gen');
ylabel('fit');
grid on;

% najlepsie riesenie
[best_fit, best_run] = min(best_fitnesses);
best_solution = best_solutions(best_run, :);


fprintf('\nBEST RUN: %d\n', best_run);
fprintf('bezne akcie: %.2f €\n', best_solution(1));
fprintf('preferovane akcie: %.2f €\n', best_solution(2));
fprintf('podnikove dlhopisy: %.2f €\n', best_solution(3));
fprintf('statne dlhopisy: %.2f €\n', best_solution(4));
fprintf('uspory v banke: %.2f €\n', best_solution(5));


saveas(gcf, 'GA_uloha4.png');



%% funkcia na pokuty
function fitness = pen(x, penalty_method)
    % vypocet fitness - zisk z investicii
    base_fitness = -(x(1)*0.04 + x(2)*0.07 + x(3)*0.11 + x(4)*0.06 + x(5)*0.05);
    
    % podmienky
    c1 = x(1) + x(2) + x(3) + x(4) + x(5) - 10e6;      % sum investicii <= 10mil
    c2 = x(1) + x(2) - 2.5e6;                   % akcie <=2.5mil
    c3 = -x(4) + x(5);                  % dlhopisy >= uspory
    c4 = -0.5*x(1) - 0.5*x(2) + 0.5*x(3) + 0.5*x(4) - 0.5*x(5);    

    penalty = 0;
    
    % 1 - mrtva
    if penalty_method == 1
        if c1 > 0 || c2 > 0 || c3 > 0 || c4 > 0 || any(x < 0)
            penalty = 10e8; 
        end
    
    % 2 - stupnova
    elseif penalty_method == 2
        porusenia = 0;
        if c1 > 0
            porusenia = porusenia + 1;
        end
        if c2 > 0
            porusenia = porusenia + 1;
        end
        if c3 > 0
            porusenia = porusenia + 1;
        end
        if c4 > 0
            porusenia = porusenia + 1;
        end

        for i = 1:5   % condition 5
            if x(i) < 0
                porusenia = porusenia + 1;
            end
        end
        
        penalty = porusenia * 1e5;
    
    % 3 - umerna
    elseif penalty_method == 3
        if c1 > 0
            penalty = penalty + 1e3 * abs(c1);
        end
        if c2 > 0
            penalty = penalty + 1e3 * c2;
        end
        if c3 > 0
            penalty = penalty + 1e3 * c3;
        end
        if c4 > 0
            penalty = penalty + 1e3 * c4;
        end
        
       
        for i = 1:5   % condition 5
            if x(i) < 0
                penalty = penalty + 1e3 * abs(x(i));
            end
        end

   
    end
    
    % final fitness
    if penalty > 0
        fitness = penalty;  % F(x)
    else
        fitness = base_fitness;
    end
end