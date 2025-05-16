% crossroad scenario by Jaromir Skirkanic & Adrian Falb
% March 2022 - April 2024

function init_krizovatka(mode, fuzzy_choice, fuzzy_name, ...
    green_intervals, use_custom_intervals, want_vis)

%% Settings

% tic;

% use pre-made maps
use_maps = 1;

% default simulation length in steps
if (mode == 6)
    sim_length = 500;
else
    sim_length = 150;
end

% Scenario default intensities
intensity = ones(1, 3) * 2;

% traffic cycles
numcycles = sim_length;

% pause time for each cycle - use more in case of very fast CPU
sleep_time = 0.02;
% number of lanes
lanes = 7;

% traffic lights available settings
lights_set = zeros(3, lanes);
lights_set(1, :) = [1, 1, 1, 0, 0, 0, 0];
lights_set(2, :) = [0, 0, 0, 1, 1, 0, 1];
lights_set(3, :) = [0, 0, 0, 0, 1, 1, 1];

% final car count graph
car_count = zeros(numcycles, lanes + 2);
lights_count = zeros(numcycles, lanes);

%% Stats initialization

% cars in direction: A1, A2, A3, B1, B2, C1, C2
if (use_maps)
    load('scenarios.mat', 'init_cars');
    cars = init_cars(:, mode)';
else
    cars = zeros(1, lanes);
    for car_init_cyc = 1:1:lanes
        cars(car_init_cyc) = randi(3) - 1;
    end
end
load('scenarios.mat', 'incom_mtx');
incom_mtx_scene = incom_mtx(:, :, mode);

% incoming car in nr. of cycles (fast, no min): A1, A2, A3, B1, B2, C1, C2
car_com_min = 13;
car_com_max_mm = 5;
incoming = zeros(1, lanes);
for car_com_init = 1:1:length(incoming)
    incoming(car_com_init) = randi(car_com_max_mm);
end

% nr. of cycles for a car to leave having green light
driver_reaction_min = 8;
driver_reaction_max_mm = 4;
leaving = zeros(1, lanes);
for leaving_init = 1:1:length(leaving)
    leaving(leaving_init) = randi(driver_reaction_max_mm) + driver_reaction_min;
end

car_ranges = [car_com_min, car_com_max_mm, driver_reaction_min, driver_reaction_max_mm];

% generate random number for the duration of the peak
traffic_spike_ranges_start = ((0.3 - 0.2) * rand + 0.2);
traffic_spike_ranges_end = ((0.8 - 0.5) * rand + 0.5);
traffic_spike_ranges = [traffic_spike_ranges_start, traffic_spike_ranges_end];

% traffic lights initial setting
lights = zeros(1, lanes);

green_duration = 0;
set_lights = 0;

%% Traffic cycle

for cyc = 1:1:numcycles

    traffic_cycle = [numcycles, cyc, mode];  
    
    % crossroad function
    [cars, incoming, leaving] = crossroad_solver(cars, incoming, leaving, lights, intensity, ...
        car_ranges, traffic_cycle, traffic_spike_ranges, use_maps, incom_mtx_scene(cyc, :), want_vis);
    
    % cyclic switching of traffic lights
    if (~fuzzy_choice && ~use_custom_intervals)
        green_duration = 0;
    elseif (green_duration < 1)
        % next lights configuration
        setter = mod(set_lights, size(lights_set, 1)) + 1;
        lights = lights_set(setter, :);
        % custom array control
        if (use_custom_intervals)
            green_duration = green_intervals(setter);
        end
        % fuzzy control
        if (fuzzy_choice)
            cars_green = sum(lights .* cars);
            cars_red = sum(cars) - cars_green;
            cars_fuzin = [cars_green, cars_red];
            try
                green_duration = evalfis(readfis(fuzzy_name), cars_fuzin);
            catch
                green_duration = evalfis(cars_fuzin, readfis(fuzzy_name));
            end
        end
        if (green_duration < 1)
            disp('Trvanie zelenej nesmie byt nastavene na menej ako 1! (Prenstavene)');
            green_duration = 1;
        end
        set_lights = set_lights + 1;
    end
    green_duration = green_duration - 1;
    % warning('off'); disp(eval);
    
    % car counter
    car_count(cyc, 1) = cyc;
    for count_cyc = 1:1:length(cars)
        car_count(cyc, count_cyc + 1) = cars(count_cyc);
    end
    for count_cyc = 1:1:length(lights)
        lights_count(cyc, count_cyc) = lights(count_cyc);
    end
    car_count(cyc, 9) = sum(cars);

    % pausing
    if (want_vis)
        pause(sleep_time);
    end
end

%% Results

% toc;
disp(['Počet áut na konci: ', num2str(sum(cars))]);
disp(['Maximálny počet áut: ', num2str(max(car_count(:, 9)))]);

figure(2);
set(gcf, 'position', [100, 100, 1000, 800], 'color', [1 0.9 0.7]);
for graph_cyc = 1:1:size(lights_count, 2)
    % amount of cars in lane
    subplot(4, 4, (graph_cyc * 2) - 1);
    hold on;
    grid on;
    axis([1 car_count(end, 1) -2 max(car_count(:, graph_cyc + 1)) + 2]);
    % color separation
    color = get_graph_color(graph_cyc);
    set(gca, 'color', color);
    % description
    xlabel('Scenario step');
    ylabel('Cars');
    lane_name = namelane(graph_cyc);
    title(['Number of cars in lane ', lane_name]);
    plot(car_count(:, 1), car_count(:, graph_cyc + 1));
    hold off;
end
for graph_cyc = 1:1:size(lights_count, 2)
    % light setting
    subplot(4, 4, graph_cyc * 2);
    hold on;
    grid on;
    axis([1 car_count(end, 1) -1 2]);
    % color separation
    color = get_graph_color(graph_cyc);
    set(gca, 'color', color);
    % description
    xlabel('Scenario step');
    ylabel('Traffic light');
    lane_name = namelane(graph_cyc);
    title(['Traffic light setting in lane ', lane_name]);
    plot(car_count(:, 1), lights_count(:, graph_cyc));
    hold off;
end
subplot(4, 4, [15, 16])
hold on;
grid on;
axis([1 car_count(end, 1) -2 max(car_count(:, 9))+2]);
set(gca,'color',[1 0.9 0.25]);
xlabel('Scenario step');
ylabel('Cars');
title('Number of cars over time');
plot(car_count(:, 1), car_count(:, 9));
hold off;

function color = get_graph_color(lane)

switch (lane)
    case {1, 2, 3}
        % red
        color = [1 0.8 0.8];
    case {4, 5}
        % green
        color = [0.8 1 0.8];
    case {6, 7}
        % blue
        color = [0.8 0.8 1];
    otherwise
        % white
        color = [1 1 1];
end

end

function name = namelane(lane)

switch (lane)
    case(1)
        name = "A1";
    case(2)
        name = "A2";
    case(3)
        name = "A3";
    case(4)
        name = "B1";
    case(5)
        name = "B2";
    case(6)
        name = "C1";
    case(7)
        name = "C2";
    otherwise
        name = "Undefined";
end

end

end

