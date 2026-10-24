% LINE_DEMO  The tool tip draws a square on a table, with the tool pointing straight down.
% First the arm goes from home to the first corner with a joint space move (every joint
% turns evenly, the tip moves on a curve). Then every side of the square is a straight
% line, solved point by point with inverse kinematics (plan_line.m).
% Saves results/figures/line_demo_joints.png and media/line_demo.gif

here = fileparts(mfilename('fullpath'));
p = robot_params();
parts = load_arm_parts();

z = 300;          % height of the table top (mm)
phi = -90;        % tool pointing down
corners = [600 -200 z; 600 200 z; 850 200 z; 850 -200 z; 600 -200 z];

% joint space move to the first corner
[goal, ok, msg] = inverse_kinematics(corners(1, :), phi, 'up');
if ~ok, error('first corner: %s', msg); end
s = (1 - cos(pi * linspace(0, 1, 40)')) / 2;
path = p.home + s .* (goal - p.home);
side_start = size(path, 1);

% the four sides of the square
for k = 1:4
    [seg, ok, msg] = plan_line(path(end, :), corners(k + 1, :), phi, 40);
    if ~ok, error('side %d: %s', k, msg); end
    path = [path; seg(2:end, :)];
end

% how straight are the sides? distance of every tip point from its side of the square
tips = zeros(size(path, 1), 3);
for k = 1:size(path, 1)
    T = forward_kinematics(path(k, :));
    tips(k, :) = T(1:3, 4)';
end
worst = 0;
for k = 1:4
    idx = side_start + (k - 1) * 39 + (0:39);
    a = corners(k, :);  b = corners(k + 1, :);
    u = (b - a) / norm(b - a);
    d = tips(idx, :) - a;
    worst = max(worst, max(vecnorm(d - (d * u') * u, 2, 2)));
end
fprintf('%d poses, largest distance of the tip from the square: %.1e mm\n', size(path, 1), worst);

% ---- joint angles during the demo
fig = figure('Color', 'w', 'Position', [100 100 900 420], 'Visible', 'off');
plot(path, 'LineWidth', 1.5);
hold on;
xline(side_start + (0:3) * 39, ':', 'Color', [0.5 0.5 0.5]);
grid on;
xlabel('step');  ylabel('joint angle (deg)');
legend({'\theta_1', '\theta_2', '\theta_3', '\theta_4'}, 'Location', 'eastoutside');
title('Joint angles: move to the first corner, then the four sides of the square');
exportgraphics(fig, fullfile(here, '..', 'results', 'figures', 'line_demo_joints.png'), 'Resolution', 150);
close(fig);

% ---- animation
fig = figure('Color', 'w', 'Position', [100 100 520 440], 'Visible', 'off');
ax = axes(fig);
patch(ax, [-300 1100 1100 -300], [-600 -600 600 600], [0 0 0 0], [0.94 0.94 0.94], ...
    'EdgeColor', 'none', 'FaceLighting', 'none');
h = draw_arm(ax, parts, path(1, :));
plot3(ax, corners(:, 1), corners(:, 2), corners(:, 3), ':', 'Color', [0.4 0.4 0.4]);
trail = plot3(ax, nan, nan, nan, 'r-', 'LineWidth', 2);
xlim(ax, [-300 1100]); ylim(ax, [-600 600]); zlim(ax, [0 1300]);
view(ax, 35, 25);
title(ax, 'Straight lines with inverse kinematics');

frames = {};
for k = 1:size(path, 1)
    h = draw_arm(ax, parts, path(k, :), h);
    if k >= side_start
        set(trail, 'XData', tips(side_start:k, 1), 'YData', tips(side_start:k, 2), 'ZData', tips(side_start:k, 3));
    end
    if mod(k, 2) == 1 || k == size(path, 1)
        f = getframe(fig);
        frames{end + 1} = f.cdata;
    end
end
close(fig);

% one colour table for all frames keeps the GIF small and without flicker
[~, map] = rgb2ind(cat(1, frames{1:10:end}), 128, 'nodither');
gif_file = fullfile(here, '..', 'media', 'line_demo.gif');
for k = 1:numel(frames)
    img = rgb2ind(frames{k}, map, 'nodither');
    if k == 1
        imwrite(img, map, gif_file, 'gif', 'LoopCount', inf, 'DelayTime', 0.06);
    else
        imwrite(img, map, gif_file, 'gif', 'WriteMode', 'append', 'DelayTime', 0.06);
    end
end
fprintf('saved %s (%d frames)\n', gif_file, numel(frames));
