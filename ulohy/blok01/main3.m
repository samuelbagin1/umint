%% uloha 3 - problem obchodneho cestujuceho
num_runs = 10;
numgen = 1000;
lpop = 50;          % velkost populacie
mr = 0.3;        
elite_count = 2;  % pocet elit jedincov
lstring = 20;      % pocet bodov

B = [0,0; 25,68; 12,75; 32,17; 51,64; 20,19; 52,87; 80,37; 35,82; 2,15;
     50,90; 13,50; 85,52; 97,27; 37,67; 20,82; 49,0; 62,14; 7,60; 100,100];

best_fitnesses = zeros(num_runs, 1);
best_paths = cell(num_runs, 1);


figure;
hold on;
title('evolucia');
xlabel('gen');
ylabel('length');
grid on;

for run = 1:num_runs
    % pop inic
    Pop = genrpop_perm(lpop, lstring);
    fittrend = zeros(1, numgen);
    
    for gen = 1:numgen
        % Vypocet fitness
        Fit = dist(Pop, B);
        [best_fit, idx] = min(Fit);
        fittrend(gen) = best_fit;
        
        % genetic operations
        newPop = Pop;
        
        % elitarny vyber 2 najlepsich jedincov
        [~, elite_idx] = mink(Fit, elite_count);
        newPop(1:elite_count, :) = Pop(elite_idx, :);
        
        % ruletovy vyber rodicov
        Parents = selsus(Pop, Fit, lpop - elite_count);

        % vynatie stredu aby len mid permutoval
        Mid = Parents(:, 2:lstring-1);
        [psize, pmid] = size(Mid);


        % docasna populacia na krizenie, mutovanie a invord pre stred
        % chromozonu
        tmp_Pop = zeros(psize, pmid); %rows, cols
        tmp_Pop = Mid;
        tmp_Pop = swappart(tmp_Pop, mr); % krizenie
        tmp_Pop = invord(tmp_Pop, mr); % inverzia
        tmp_Pop = swapgen(tmp_Pop, mr); % mutacia

        Parents(:, 2:lstring-1) = tmp_Pop;
        newPop(elite_count+1:end, :) = Parents;
        Pop = newPop;
    end
    
    % ulozenie vysledku behu
    best_fitnesses(run) = best_fit;
    best_paths{run} = Pop(idx,:);
   
    fprintf('\n LENGTH: %.2f, ROUTE:', best_fit);
    fprintf([repmat(' %2d ',1,numel(Pop(idx,:))) '\n'],Pop(idx,:));
    plot(fittrend, 'LineWidth', 1); % vykreslenie grafu
end
saveas(gcf, 'GA_uloha3.png');
hold off;

%% vypisanie vysledku
[~, best_run] = min(best_fitnesses);
best_path = best_paths{best_run};

% graf cesty
figure;
plot(B(:,1), B(:,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
hold on;
plot(B(best_path,1), B(best_path,2), 'r-', 'LineWidth', 1.5);
title(sprintf('optimal length: %.2f', best_fitnesses(best_run)));
xlabel('X');
ylabel('Y');
grid on;
saveas(gcf, 'cesta_uloha3.png');

%% functions
function Pop = genrpop_perm(pop_size, num_points) %vygenerovanie populacie - permutacii
    Pop = zeros(pop_size, num_points);
    for i = 1:pop_size
        middle = randperm(num_points-2) + 1; % 18 perm
        Pop(i,:) = [1, middle, num_points];
    end
end

function Fit = dist(Pop, B) % vypocet vzdialenosti
    [pop_size, path_len] = size(Pop);
    Fit = zeros(pop_size, 1);
    for i = 1:pop_size %iteracia cez riadky Pop
        total_dist = 0;
        for j = 1:(path_len-1) %iterujeme cez jednotlive prvky riadku Pop
            total_dist = total_dist + sqrt( (B(Pop(i,j+1),1)-B(Pop(i,j),1))^2 + (B(Pop(i,j+1),2)-B(Pop(i,j),2))^2 );
        end
        Fit(i) = total_dist;
    end
end

