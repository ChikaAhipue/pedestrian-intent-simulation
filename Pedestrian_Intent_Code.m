clc; clear; close all;

% ----------------------------
% Hidden Intent
% ----------------------------
intents = ["CROSS", "STOP", "TURN"];
intent = intents(randi(3));

% ----------------------------
% Initial Conditions
% ----------------------------
x = -2 + 4*rand;          % random X (-2 to 2)
y = 4 + rand;             % sidewalk (4 to 5)

speed = 1 + 0.5*rand;     % 1 to 1.5
heading = -pi/2 + (rand-0.5)*0.2;  % mostly downward

dt = 0.1;

positions = [];
speeds = [];
headings = [];

% ----------------------------
% Figure Setup
% ----------------------------
figure; hold on;

% Sidewalk
rectangle('Position', [-5, 0, 10, 6], ...
    'FaceColor', [0.8 1 0.8], 'EdgeColor', 'none');

% Decision Zone
rectangle('Position', [-5, 0, 10, 1], ...
    'FaceColor', [1 1 0.8], 'EdgeColor', 'none');

% Road
rectangle('Position', [-5, -3, 10, 3], ...
    'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'none');

% Curb
plot([-5 5], [0 0], 'y', 'LineWidth', 3);

text(3, 4.5, 'Sidewalk');
text(3, -2, 'Road', 'Color', 'w');

xlim([-5 5]);
ylim([-3 6]);

title("Pedestrian Intent Simulation");
xlabel("X Position");
ylabel("Y Position");

dot = plot(x, y, 'ro', 'MarkerFaceColor', 'r');
path = plot(x, y, 'b-', 'LineWidth', 1.5);

% ----------------------------
% Simulation Loop
% ----------------------------
for t = 1:60

    % Add slight randomness
    speed = speed + (rand*0.04 - 0.02);
    speed = max(speed, 0);

    heading = heading + (rand-0.5)*0.05;

    % ----------------------------
    % Intent Behavior
    % ----------------------------
    if intent == "CROSS"
        % Move toward road
        heading = -pi/2 + (rand-0.5)*0.1;

    elseif intent == "STOP"
        % Distance to curb
        distance_to_curb = y;

        % Gradual slowing
        if distance_to_curb <= 1
            speed = speed - 0.1*(1 - distance_to_curb);
        end

        speed = max(speed, 0);

    elseif intent == "TURN"
        % Curve away
        heading = heading + 0.08;
    end

    % ----------------------------
    % Motion Update
    % ----------------------------
    vx = speed * cos(heading);
    vy = speed * sin(heading);

    x = x + vx * dt;
    y = y + vy * dt;

    % 🚨 HARD STOP before curb (FIXED)
    if intent == "STOP" && y <= 0.05
        y = 0.05;
        speed = 0;
    end

    % Store data
    positions = [positions; x y];
    speeds = [speeds speed];
    headings = [headings heading];

    % Animate
    set(dot, 'XData', x, 'YData', y);
    set(path, 'XData', positions(:,1), 'YData', positions(:,2));

    pause(0.05);
end

% ----------------------------
% Prediction Logic
% ----------------------------
if min(speeds) < 0.2
    predicted = "STOP";
elseif abs(headings(end) - headings(1)) > 0.5
    predicted = "TURN";
else
    predicted = "CROSS";
end

% ----------------------------
% Display Results
% ----------------------------
text(-4.5, 5.5, "True: " + intent, 'FontSize', 12);
text(-4.5, 5.0, "Predicted: " + predicted, 'FontSize', 12);

disp("True Intent: " + intent);
disp("Predicted Intent: " + predicted);