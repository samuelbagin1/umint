% plot
x = linspace(-800, 800, 1000);
y = testfn3b(x');
figure;
plot(x, y);
hold on;
xlabel('x');
ylabel('y');

%start poz
x0 = -800 + 1600 * rand();
d = 10;
step_count = 0;

% inicializacia
x_current = x0;
y_current = testfn3b([x_current]);
plot(x_current, y_current, 'ro', 'MarkerSize', 10, 'LineWidth', 2); %zaciatocny point

% tracking
path_x = x_current;
path_y = y_current;

y_global_extrem = y_current;
x_global_extrem = x_current;

while step_count < 3
    %vytvorime suradnice susedov
    x_left = x_current - d;
    x_right = x_current + d;
    
    %checkneme si suradnice a vypocita sa hodnota
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if x_left <= -800
        y_left = inf;
    else
        y_left = testfn3b([x_left]);
    end
    
    if x_right >= 800
        y_right = inf;
    else
        y_right = testfn3b([x_right]);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % najdeme najmensiu hodnotu a index najmensej hodnoty
    [min_val, iX] = min([y_current, y_left, y_right]);
    
    % epsilon check
    if iX == 1 || abs(y_current - y_left) < 0.01 || abs(y_current - y_right) < 0.01
        %oznacim stary point
        plot(x_current, y_current, 'm*', 'MarkerSize', 15, 'LineWidth', 2);

        if y_current < y_global_extrem
            y_global_extrem = y_current;
            x_global_extrem = x_current;
        end

        if y_current == y_global_extrem
            step_count = step_count + 1;
        end

        x0 = -800 + 1600 * rand();
        x_current = x0;
        y_current = testfn3b([x_current]);
        
        %vykreslim novy point
        plot(x_current, y_current, 'ro', 'MarkerSize', 10, 'LineWidth', 2);

    else  % ak nie je to iste alebo je vacsi epsilon
        if iX == 2
            x_new = x_left;  % posunieme sa do lava alebo doprava
        else
            x_new = x_right;
        end
        y_new = min_val;
        
        %znazornime krok na grafe
        plot(x_new, y_new, 'gx', 'MarkerSize', 10, 'LineWidth', 2);
        drawnow; % updatnem
        
        %ulozime nove suradnice a hodnoty
        x_current = x_new;
        y_current = y_new;
    end
end

% glob extrem
plot(x_global_extrem, y_global_extrem, 'b*', 'MarkerSize', 15, 'LineWidth', 2);
fprintf('coord najedeneho glob min: %.2f %.2f\n', x_global_extrem, y_global_extrem);

saveas(gcf, 'GA_uloha1.png');

hold off;