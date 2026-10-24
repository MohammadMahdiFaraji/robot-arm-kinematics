function [ok, msg] = check_pose(theta)
% CHECK_POSE  Is this pose allowed? Joint limits, the floor and the base of the arm.
%   [ok, msg] = check_pose([t1 t2 t3 t4])     angles in degrees
% Only the joint points and the tool tip are checked, not the thickness of the links,
% so this is a first check and not a full collision test.
p = robot_params();
ok = false;

for i = 1:4
    if theta(i) < p.limits(i, 1) || theta(i) > p.limits(i, 2)
        msg = sprintf('joint %d would need %.1f deg (limit %g to %g)', i, theta(i), p.limits(i, 1), p.limits(i, 2));
        return
    end
end

[~, points] = forward_kinematics(theta);
r = hypot(points(1, :), points(2, :));      % distance from the base axis
h = points(3, :);                           % height above the floor

% the elbow, the wrist and the tip must stay above the floor
if any(h(3:5) < 0)
    msg = 'the arm would go below the floor';
    return
end

% the wrist and the tip must stay outside the base (two cylinders, see robot_params)
inside = false(1, 5);
for c = 1:size(p.base_size, 1)
    inside = inside | (r < p.base_size(c, 1) & h < p.base_size(c, 2));
end
if any(inside(4:5))
    msg = 'the tool would hit the base of the arm';
    return
end

ok = true;
msg = 'ok';
end
