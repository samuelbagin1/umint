% Crossroad solver by Jaromir Skirkanic & Adrian Falb
% March 2022 - April 2024

function [cars, incoming, leaving] = crossroad_solver(cars, incoming, leaving, lights, intensity, ...
    car_ranges, traffic_cycle, traffic_spike_ranges, use_maps, incom_mtx_array, want_vis)

%% Stats

% incoming car min and max values
car_com_min = car_ranges(1);
car_com_max_mm = car_ranges(2);

% driver reaction for a car to leave having green light
driver_reaction_min = car_ranges(3);
driver_reaction_max_mm = car_ranges(4);

% traffic intensity
% directions: [A (right-red), B (bottom-green), C (top-blue)]
intens_check = zeros(1, 7);
intens_check(1) = intensity(1);
intens_check(2) = intensity(1);
intens_check(3) = intensity(1);
intens_check(4) = intensity(2);
intens_check(5) = intensity(2);
intens_check(6) = intensity(3);
intens_check(7) = intensity(3);

% traffic lights
light_size = 14;
light_count = [3 2 2];

% car counter positioning
dir_move = 16;
A1_cnt = [715 216-dir_move];
A2_cnt = [715 283-dir_move];
A3_cnt = [715 356-dir_move];
B1_cnt = [374+dir_move 568];
B2_cnt = [455+dir_move 568];
C1_cnt = [374+dir_move 0];
C2_cnt = [294+dir_move 0];
num_pos = [A1_cnt; A2_cnt; A3_cnt; B1_cnt; B2_cnt; C1_cnt; C2_cnt];

% car graphics proportions - A1-3 - RED, B1-2 - GREEN, C1-2 - BLUE
car_size_hor = [30 20];
car_size_ver = [20 30];
car_corner = [520, 220; 465, 420; 385, 150];
car_dist = [45 68 78];
cars_displayed = [4 3 3];
color_intens = [16 32 64];

%% Traffic algorithm

% Car incoming time reduction
if (use_maps)
    arr_high = [10, 10];
    arr_more = [6, 6];
    arr_less = [3, 3];
else
    arr_high = [9, 10];
    arr_more = [6, 7];
    arr_less = [3, 4];
end
% cyc_rate = traffic_cycle(2) / traffic_cycle(1);
switch traffic_cycle(3)
    case 2
        if (traffic_cycle(2) > traffic_cycle(1) * 0.2)
            if (traffic_cycle(2) < (traffic_cycle(1) * 0.4))
                incoming(1:3) = incoming(1:3) - randi(arr_more);
            elseif (traffic_cycle(2) < (traffic_cycle(1) * 0.6))
                incoming(4:5) = incoming(4:5) - randi(arr_less);
            elseif (traffic_cycle(2) < (traffic_cycle(1) * 0.8))
                incoming(6:7) = incoming(6:7) - randi(arr_less);
            end
        end
    case 3
        if (traffic_cycle(2) > traffic_cycle(1) * traffic_spike_ranges(1))  
            if (traffic_cycle(2) < (traffic_cycle(1) * traffic_spike_ranges(2)))
                incoming(6:7) = incoming(6:7) - randi(arr_more);
            end
        end
    case 4
        if (traffic_cycle(2) > traffic_cycle(1) * traffic_spike_ranges(1))  
            if (traffic_cycle(2) < (traffic_cycle(1) * traffic_spike_ranges(2)))
                incoming(4:5) = incoming(4:5) - randi(arr_more);
            end
        end
    case 5
        if (traffic_cycle(2) > traffic_cycle(1) * traffic_spike_ranges(1))
            if (traffic_cycle(2) < (traffic_cycle(1) * traffic_spike_ranges(2)))
                incoming(1) = incoming(1) - randi(arr_less);
                incoming(2) = incoming(2) - randi(arr_more);
                incoming(3) = incoming(3) - randi(arr_less);
            end
        end
    case 6
        if (traffic_cycle(2) > 35) && (traffic_cycle(2) < 105)
            incoming(6) = incoming(6) - randi(arr_less);
            incoming(7) = incoming(7) - randi(arr_high);
        elseif (traffic_cycle(2) > 190) && (traffic_cycle(2) < 250)
            incoming(4:5) = incoming(4:5) - randi(arr_more);
        elseif (traffic_cycle(2) > 300) && (traffic_cycle(2) < 390)
            incoming(1) = incoming(1) - randi(arr_less);
            incoming(2) = incoming(2) - randi(arr_more);
            incoming(3) = incoming(3) - randi(arr_less);
        end
end

% cars arriving check
if ~(use_maps)
    % incoming one step lower
    incoming = incoming - 1;
    for carcheck = 1:1:length(cars)
        % if car is incoming
        if (incoming(carcheck) < 1)
            % a car arrives
            cars(carcheck) = cars(carcheck) + 1;
            % incoming is reset
            incoming(carcheck) = (randi(car_com_max_mm) + car_com_min) * intens_check(carcheck);
        end
    end
else
    cars = cars + incom_mtx_array;
end

% leaving reactions reset check and if green with a car, try to leave
for leavecheck = 1:1:length(lights)
    if (lights(leavecheck) && cars(leavecheck))
        % green light and car is present
        leaving(leavecheck) = leaving(leavecheck) - 1;
        % if leaving, car -1 and leaving reacion is reset for next driver
        if (leaving(leavecheck) < 1)
            cars(leavecheck) = cars(leavecheck) - 1;
            if (use_maps)
                leaving(leavecheck) = 3;
            else
                leaving(leavecheck) = randi(2)+2;
            end
        end
    else
        % red light
        % driver reaction reset
        if (use_maps)
            leaving(leavecheck) = 10;
        else
            leaving(leavecheck) = randi(driver_reaction_max_mm) + driver_reaction_min;
        end
    end
end

%% Graphics

if (want_vis)
    clf;
    crossroad_image = imread('crossroad.jpg');

    % traffic lights animation
    % A1
    if (lights(1))
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [605 56 light_size], 'Color', 'g');
    else
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [572 56 light_size], 'Color', 'r');
    end
    % A2
    if (lights(2))
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [605 98 light_size], 'Color', 'g');
    else
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [572 98 light_size], 'Color', 'r');
    end
    % A3
    if (lights(3))
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [605 140 light_size], 'Color', 'g');
    else
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [572 140 light_size], 'Color', 'r');
    end
    % B1
    if (lights(4))
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [572 494 light_size], 'Color', 'g');
    else
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [572 461 light_size], 'Color', 'r');
    end
    % B2
    if (lights(5))
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [614 494 light_size], 'Color', 'g');
    else
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [614 461 light_size], 'Color', 'r');
    end
    % C1
    if (lights(6))
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [220 107 light_size], 'Color', 'g');
    else
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [220 140 light_size], 'Color', 'r');
    end
    % C2
    if (lights(7))
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [178 107 light_size], 'Color', 'g');
    else
        crossroad_image = insertShape(crossroad_image, 'FilledCircle', [178 140 light_size], 'Color', 'r');
    end

    % car graphics
    % A
    for cars_a = 1:1:light_count(1)
        for cars_pos = 1:1:cars_displayed(1)
            if (cars(cars_a) >= cars_pos)
                crossroad_image = insertShape(crossroad_image, 'FilledRectangle', [car_corner(1, 1)+(cars_pos-1)*car_dist(1) car_corner(1, 2)+(cars_a-1)*car_dist(2) car_size_hor], 'Color', [(cars_a+1)*color_intens(3) ((cars_a+1+cars_pos)/2)*color_intens(1) cars_pos*color_intens(2)]);
            end
        end
    end
    % B
    for cars_b = 1:1:light_count(2)
        for cars_pos = 1:1:cars_displayed(2)
            if (cars(cars_b + light_count(1)) >= cars_pos)
                crossroad_image = insertShape(crossroad_image, 'FilledRectangle', [car_corner(2, 1)-(car_dist(3))+(cars_b-1)*car_dist(3) car_corner(2, 2)+(cars_pos-1)*car_dist(1) car_size_ver], 'Color', [(cars_b+2)*color_intens(2) ((cars_b+2+cars_pos)/2)*color_intens(3) cars_pos*color_intens(1)]);
            end
        end
    end
    % C
    for cars_c = 1:1:light_count(3)
        for cars_pos = 1:1:cars_displayed(3)
            if (cars(cars_c + light_count(1) + light_count(2)) >= cars_pos)
                crossroad_image = insertShape(crossroad_image, 'FilledRectangle', [car_corner(3, 1)-(cars_c-1)*car_dist(3) car_corner(3, 2)-(cars_pos-1)*car_dist(1) car_size_ver], 'Color', [(cars_c+2)*color_intens(1) ((cars_c+2+cars_pos)/2)*color_intens(2) cars_pos*color_intens(3)]);
            end
        end
    end

    font = 'Times New Roman Bold';
    font_size_2 = 28;
    font_size_3 = 22;

    % car counter graphics
    crossroad_image = insertText(crossroad_image, num_pos, cars, ...
        'Font', font, 'FontSize', font_size_3, 'TextColor', 'black', 'BoxOpacity', 0);

    % lanes/directions graphics
    % directions
    crossroad_image = insertText(crossroad_image, [655 40], 'A1', ...
        'Font', font, 'FontSize', font_size_2, 'TextColor', 'black', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [655 78], 'A2', ...
        'Font', font, 'FontSize', font_size_2, 'TextColor', 'black', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [655 116], 'A3', ...
        'Font', font, 'FontSize', font_size_2, 'TextColor', 'black', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [547 538], 'B1', ...
        'Font', font, 'FontSize', font_size_2, 'TextColor', 'black', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [590 538], 'B2', ...
        'Font', font, 'FontSize', font_size_2, 'TextColor', 'black', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [198 17], 'C1', ...
        'Font', font, 'FontSize', font_size_2, 'TextColor', 'black', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [155 17], 'C2', ...
        'Font', font, 'FontSize', font_size_2, 'TextColor', 'black', 'BoxOpacity', 0);
    % lanes
    crossroad_image = insertText(crossroad_image, [num_pos(1, 1)-30 num_pos(1, 2)+10], 'A1', ...
        'Font', font, 'FontSize', font_size_3, 'TextColor', 'red', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [num_pos(2, 1)-30 num_pos(2, 2)+12], 'A2', ...
        'Font', font, 'FontSize', font_size_3, 'TextColor', 'red', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [num_pos(3, 1)-30 num_pos(3, 2)+8], 'A3', ...
        'Font', font, 'FontSize', font_size_3, 'TextColor', 'red', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [num_pos(4, 1)-15 num_pos(4, 2)-30], 'B1', ...
        'Font', font, 'FontSize', font_size_3, 'TextColor', 'green', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [num_pos(5, 1)-15 num_pos(5, 2)-30], 'B2', ...
        'Font', font, 'FontSize', font_size_3, 'TextColor', 'green', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [num_pos(6, 1)-15 num_pos(6, 2)+27], 'C1', ...
        'Font', font, 'FontSize', font_size_3, 'TextColor', 'blue', 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [num_pos(7, 1)-15 num_pos(7, 2)+27], 'C2', ...
        'Font', font, 'FontSize', font_size_3, 'TextColor', 'blue', 'BoxOpacity', 0);

    % simulation cycle graphics
    crossroad_image = insertText(crossroad_image, [10 568], [num2str(traffic_cycle(2)), ' / ', num2str(traffic_cycle(1))], 'BoxOpacity', 0);
    crossroad_image = insertText(crossroad_image, [10 546], 'Step Count:', 'BoxOpacity', 0);

    % creating image
    imshow(crossroad_image);
    drawnow;
end

end

