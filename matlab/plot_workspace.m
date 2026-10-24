% PLOT_WORKSPACE  Where the tool tip can go, seen from the side in the plane of the arm.
%   grey : points the tip can reach with some tool angle
%          (60000 random joint angles inside the limits, forward kinematics)
%   blue : points where the tool can also point straight down (phi = -90),
%          for example to pick something from a table (a grid of targets, inverse kinematics)
% Poses that check_pose.m does not allow (under the floor, tool inside the base) are left out.
% The figure is saved to results/figures/workspace.png

here = fileparts(mfilename('fullpath'));
p = robot_params();

% 1) random joint angles -> tip
rng(2);
n = 60000;
th = p.limits(:, 1)' + rand(n, 4) .* (p.limits(:, 2) - p.limits(:, 1))';
tip = zeros(n, 3);
keep = true(n, 1);
for k = 1:n
    T = forward_kinematics(th(k, :));
    tip(k, :) = T(1:3, 4)';
    keep(k) = check_pose(th(k, :));
end
tip = tip(keep, :);
th = th(keep, :);
% distance in front of the base, along the direction the arm is turned to
% (negative = the arm has bent over the top and reaches behind the base)
reach = tip(:, 1) .* cosd(th(:, 1)) + tip(:, 2) .* sind(th(:, 1));

% 2) grid of targets in front of the base, can the tool point straight down there?
[gx, gz] = meshgrid(0:10:1200, 0:10:1700);
down = false(size(gx));
for k = 1:numel(gx)
    [~, ok_up] = inverse_kinematics([gx(k) 0 gz(k)], -90, 'up');
    [~, ok_down] = inverse_kinematics([gx(k) 0 gz(k)], -90, 'down');
    down(k) = ok_up || ok_down;
end
down_reach = sqrt(max(gx(down) .^ 2 - p.d(4) ^ 2, 0));    % same in-plane distance as above

% 3) figure
fig = figure('Color', 'w', 'Position', [100 100 820 620], 'Visible', 'off');
hold on;
scatter(reach, tip(:, 3), 2, [0.72 0.72 0.72], 'filled');
scatter(down_reach, gz(down), 4, [0.20 0.45 0.80], 'filled');
[~, home_points] = forward_kinematics(p.home);
home_reach = home_points(1, :) * cosd(p.home(1)) + home_points(2, :) * sind(p.home(1));
plot(home_reach, home_points(3, :), 'k-o', 'LineWidth', 2, 'MarkerFaceColor', 'k', 'MarkerSize', 5);
plot([-1300 1300], [0 0], 'k-', 'LineWidth', 1);
axis equal; grid on; box on;
xlim([-1300 1300]); ylim([-100 1750]);
xlabel('distance from the base axis, along the arm (mm)');
ylabel('height above the floor (mm)');
title('Workspace of the tool tip, side view');
legend({'reachable with some tool angle', 'reachable with the tool pointing down', 'arm at the home pose'}, ...
    'Location', 'southoutside', 'Orientation', 'horizontal');

out_dir = fullfile(here, '..', 'results', 'figures');
exportgraphics(fig, fullfile(out_dir, 'workspace.png'), 'Resolution', 150);
fprintf('largest reach in front of the base: %.0f mm, highest point: %.0f mm\n', max(reach), max(tip(:, 3)));
fprintf('with the tool pointing down: from %.0f to %.0f mm in front of the base\n', min(down_reach), max(down_reach));
close(fig);
