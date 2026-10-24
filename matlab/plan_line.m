function [path, ok, msg] = plan_line(theta0, target, phi_end, n)
% PLAN_LINE  Joint angles that move the tool tip along a straight line.
%   [path, ok, msg] = plan_line(theta0, target, phi_end, n)
%   theta0  : start pose in degrees, the line starts where its tool tip is
%   target  : end point [x y z] in mm
%   phi_end : tool angle at the end point (deg), it changes evenly along the line
%   n       : number of points on the line (default 60)
%   path    : n x 4 joint angles, one row per point
% Every point of the line is solved with inverse_kinematics. The elbow stays on the
% side where it starts, otherwise the arm would flip over in the middle of the line.
%
% MohammadMahdi Faraji, mmyasharfaraji@gmail.com
if nargin < 4, n = 60; end

T0 = forward_kinematics(theta0);
p0 = T0(1:3, 4)';
phi0 = mod(sum(theta0(2:4)) + 180, 360) - 180;
dphi = mod(phi_end - phi0 + 180, 360) - 180;       % smallest turn, e.g. 170 to -170 is +20 deg
if theta0(3) < 0, elbow = 'up'; else, elbow = 'down'; end

s = linspace(0, 1, n);
path = zeros(n, 4);
ok = false;
for k = 1:n
    [th, good, msg] = inverse_kinematics(p0 + s(k) * (target - p0), phi0 + s(k) * dphi, elbow);
    if ~good
        msg = sprintf('point %d of %d on the line: %s', k, n, msg);
        return
    end
    path(k, :) = th;
end

% near a singular pose a tiny step of the tip needs a big step of a joint
jump = max(abs(diff(path)), [], 'all');
if jump > 15
    msg = sprintf('a joint would have to jump %.0f deg between two points (the line passes too close to a singular pose)', jump);
    return
end
ok = true;
msg = 'ok';
end
