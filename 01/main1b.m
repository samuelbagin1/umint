% Vykreslenie funkcie
[X, Y] = meshgrid(linspace(-800, 800, 100), linspace(-800, 800, 100));
Z = testfn3b([X(:), Y(:)]);
Z = reshape(Z, size(X));
figure;
contourf(X, Y, Z, 50);
hold on;
xlabel('x');
ylabel('y');
colorbar;

d = 10;               
step_count = 0;    

% pociatocna pozicia
current_pos = [-800 + 1600*rand(), -800 + 1600*rand()];
z_current = testfn3b(current_pos);
plot(current_pos(1), current_pos(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);

% sledovanie cesty a globalneho minima
path = current_pos;
global_min = z_current;
global_min_pos = current_pos;



% tu budu iba 4 skoky aby som zbytocne neprehladaval cely graf
while step_count < 3
    % vygenerovanie novych susedov
    neighbors = [
        current_pos - [d, 0];   % vlavo
        current_pos + [d, 0];   % vpravo
        current_pos - [0, d];   % dole
        current_pos + [0, d]    % hore
    ];
    
    % vyhodnotenie susedov
    z_neighbors = Inf(4, 1);
    for i = 1:4
        pos = neighbors(i, :);
        %ak v pohode tak sa vyhodnoti
        if all(pos >= -800 & pos <= 800)
            z_neighbors(i) = testfn3b(pos);
        end
    end
    
    % najlepsi sused
    [min_val, iX] = min([z_current; z_neighbors]);
    
    if iX == 1
        %ak som v minime tak skocime na noveho suseda
        step_count = step_count + 1;
        plot(current_pos(1), current_pos(2), 'm*', 'MarkerSize', 15, 'LineWidth', 2);
        
        %nove globalne minimum
        if z_current < global_min
            global_min = z_current;
            global_min_pos = current_pos;
        end
        
        % novy bod
        current_pos = [-800 + 1600*rand(), -800 + 1600*rand()];
        z_current = testfn3b(current_pos);
        plot(current_pos(1), current_pos(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        drawnow;

    else
        % presun na noveho suseda
        current_pos = neighbors(iX-1, :);
        z_current = min_val;
        path = [path; current_pos];
        
        plot(current_pos(1), current_pos(2), 'gx', 'MarkerSize', 10, 'LineWidth', 2);
        drawnow;
    end
end

fprintf('coord najedeneho glob min: %.2f %.2f\n', global_min_pos(1), global_min_pos(2));
%global min
plot(global_min_pos(1), global_min_pos(2), 'b*', 'MarkerSize', 15, 'LineWidth', 2);
saveas(gcf, 'GA_uloha1b.png');
hold off;
