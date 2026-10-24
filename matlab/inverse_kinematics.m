function [theta, ok, msg] = inverse_kinematics(pos, phi, elbow)
% INVERSE_KINEMATICS  Joint angles that put the tool tip on a given point.
%   [theta, ok, msg] = inverse_kinematics([x y z], phi, elbow)
%   pos   : target of the tool tip in mm (base frame)
%   phi   : angle of the tool from the horizontal in degrees, phi = theta2 + theta3 + theta4
%           (0 = tool level, -90 = tool pointing down)
%   elbow : 'up' (default) or 'down'
%   theta : joint angles in degrees
%   ok    : false if the point is out of reach, needs a joint beyond its limit,
%           or would push the arm into the floor or its own base. msg says which.
%
%   MohammadMahdi Faraji, mmyasharfaraji@gmail.com
if nargin < 2, phi = 0; end
if nargin < 3, elbow = 'up'; end

p = robot_params();
a2 = p.a(2);  a3 = p.a(3);  a4 = p.a(4);
d1 = p.d(1);
side = p.d(4);          % the tool tip is 10 mm beside the plane of the arm
theta = nan(1, 4);
ok = false;
x = pos(1);  y = pos(2);  z = pos(3);

% 1) base angle. Seen from above, the tip is 'side' mm beside the arm,
%    so the arm has to point a little past the target.
r2 = x^2 + y^2 - side^2;
if r2 < 0
    msg = 'the target is too close to the base axis';
    return
end
r = sqrt(r2);                         % horizontal distance inside the arm plane
theta(1) = atan2d(y, x) + atan2d(side, r);

% 2) wrist point (joint 4): go back from the tip along the tool
rw = r - a4 * cosd(phi);
zw = z - d1 - a4 * sind(phi);

% 3) links 2 and 3 form a triangle with the wrist point (law of cosines)
c3 = (rw^2 + zw^2 - a2^2 - a3^2) / (2 * a2 * a3);
if abs(c3) > 1
    msg = 'the target is out of reach';
    return
end
s3 = sqrt(1 - c3^2);
if strcmp(elbow, 'up')
    s3 = -s3;
end
theta(3) = atan2d(s3, c3);
theta(2) = atan2d(zw, rw) - atan2d(a3 * s3, a2 + a3 * c3);
theta(4) = phi - theta(2) - theta(3);
theta = mod(theta + 180, 360) - 180;          % keep every angle in [-180, 180)

% 4) joint limits, floor and base
[ok, msg] = check_pose(theta);
end
