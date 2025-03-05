% uloha 2, GA

num_runs = 10;

numgen = 500;
lpop = 100; % pocet retazcov generovanej populacie
dim = 10; % pocet premennych Schwefelovej funkcie
mr = 0.1; % mutation rate
elite_count = 2; % pocet elitarnych jedincov (sa zachovavaju)

% inicializacia populacie
Space = [ones(1,dim)*(-800); % dolna hranica
        ones(1,dim)*800]; % horna hranica
Amp = ones(1,dim)*50; % amplituda


% spustenie GA viackrat
best_solutions = zeros(num_runs, dim);  % najlepsie riesenie z kazdeho behu
best_fitnesses = zeros(1, num_runs);    % najlepsie fitness z kazdeho behu

figure;

for run=1:num_runs

    % inicializacia Pop pre aktualny beh
    Pop = genrpop(lpop, Space); % populacia
    fittrend = zeros(1, numgen); % pole pre ukladanie najlepsej fittness

    for gen=1:numgen
        Fit = testfn3b(Pop);
        fittrend(gen) = min(Fit);

        %%%%%%%%%%%%%%%% GA %%%%%%%%%%%%%%%%%%%%%%
    
        % elitarny vyber, zachovaju sa len ti najlepsi
        Elite = selbest(Pop, Fit, [elite_count]); 

        % ruletovy vyber + krizenie (2-bodove)
        Parents = selsus(Pop, Fit, lpop - elite_count); 
        Cross = crossov(Parents, 2, 0); 

        % mutacia
        %Cross = muta(Cross, mr, Amp, Space); % aditivna mutacia
        Cross = mutx(Cross, mr, Space); % obycajna mutacia
        %Cross = mutm(Cross, mr, Amp, Space); % multiplikativna mutacia

        % nova Populacia
        Pop = [Elite; Cross]; 
    end



    % ulozenie vysledkov aktualneho behu
    best_solutions(run, :) = Pop(1, :);
    best_fitnesses(run) = testfn3b(Pop(1, :));
    
    hold on;
    plot(fittrend, 'r');
    fprintf('Beh %d: fitness = %.2f\n', run, best_fitnesses(run));

    hold off;

end



title('viacero behov GA');
xlabel('generation');
ylabel('F(x)');
grid on;

% najlepsie riesenie
[overall_best_fit, best_run] = min(best_fitnesses);
fprintf('\n=== celkovo najlepsie riesenie - beh %d\n', best_run);
fprintf('coord: %s\n', mat2str(best_solutions(best_run, :), 3));
fprintf('F(x): %.2f\n', overall_best_fit);

% ulozenie grafu
saveas(gcf, 'porovnanie_behov_ga.png');
% ulozenie var do .mat
save('vysledky_ga.mat', 'best_solutions', 'best_fitnesses', 'all_fittrend');