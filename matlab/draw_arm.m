function h = draw_arm(ax, parts, theta, h)
% DRAW_ARM  Draws the arm (the real CAD parts) for the joint angles theta, in degrees.
%   h = draw_arm(ax, parts, theta)      first call, creates the patches
%   h = draw_arm(ax, parts, theta, h)   later calls, only moves them (faster)
% parts comes from load_arm_parts.
[~, ~, frames] = forward_kinematics(theta);

if nargin < 4 || isempty(h)
    h = gobjects(1, numel(parts));
    hold(ax, 'on');
    for k = 1:numel(parts)
        h(k) = patch(ax, 'Faces', parts(k).faces, 'Vertices', move(parts(k).vertices, frames(:, :, k)), ...
            'FaceColor', parts(k).color, 'EdgeColor', 'none', 'FaceLighting', 'gouraud', ...
            'AmbientStrength', 0.4);
    end
    axis(ax, 'equal');
    view(ax, 135, 20);
    camlight(ax, 'headlight');
    xlabel(ax, 'x (mm)'); ylabel(ax, 'y (mm)'); zlabel(ax, 'z (mm)');
    grid(ax, 'on');
else
    for k = 1:numel(parts)
        h(k).Vertices = move(parts(k).vertices, frames(:, :, k));
    end
end
end


function v = move(v, T)
v = (T(1:3, 1:3) * v' + T(1:3, 4))';
end
