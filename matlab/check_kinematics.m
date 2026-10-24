% CHECK_KINEMATICS  Tests for forward and inverse kinematics.
%   1. forward_kinematics against the CAD file (SolidWorks pose)
%   2. forward_kinematics against the Simscape model (its own tip sensor)
%   3. inverse_kinematics -> forward_kinematics round trip for random poses
%   4. targets that must be refused
% The output is also saved to results/kinematics_check.txt
%
% MohammadMahdi Faraji, mmyasharfaraji@gmail.com

here = fileparts(mfilename('fullpath'));
log_file = fullfile(here, '..', 'results', 'kinematics_check.txt');
if isfile(log_file), delete(log_file); end
diary(log_file);
p = robot_params();
fprintf('Kinematics check, %s\n\n', datetime('today', 'Format', 'yyyy-MM-dd'));

% 1. In the CAD file the tool tip is at this point (from Assem1.xml, converted to the base frame)
cad_tip = [902.279 -56.160 1124.989];
T = forward_kinematics(p.cad_pose);
fprintf('1) SolidWorks pose %s\n', mat2str(p.cad_pose));
fprintf('   tip from CAD          [%.3f %.3f %.3f] mm\n', cad_tip);
fprintf('   forward_kinematics    [%.3f %.3f %.3f] mm   difference %.3f mm\n\n', T(1:3, 4), norm(T(1:3, 4)' - cad_tip));

% 2. Simscape model: put the joints at some angles and read the tip sensor
if license('test', 'SimMechanics')          % the license name of Simscape Multibody
    model = 'robot_arm';
    addpath(fullfile(here, '..', 'simulink'));
    load_system(model);
    set_param(model, 'SimMechanicsOpenEditorOnUpdate', 'off');
    poses = [p.home; p.cad_pose; 0 0 0 0; 90 30 -60 20; -120 120 -100 -45; 45 -10 40 -80; 170 160 -140 60; -60 75 -150 70];
    fprintf('2) Simscape model vs forward_kinematics\n');
    worst = 0;
    for k = 1:size(poses, 1)
        for i = 1:4
            set_param([model '/theta' num2str(i)], 'Value', num2str(poses(k, i)));
        end
        out = sim(model, 'StopTime', '1');
        tip = out.tip_mm(end, :);
        T = forward_kinematics(poses(k, :));
        err = norm(tip' - T(1:3, 4));
        worst = max(worst, err);
        fprintf('   theta = %-34s Simscape [%8.2f %8.2f %8.2f]  FK [%8.2f %8.2f %8.2f]  diff %.4f mm\n', ...
            mat2str(poses(k, :)), tip, T(1:3, 4), err);
    end
    fprintf('   largest difference: %.4f mm\n\n', worst);
    close_system(model, 0);
else
    fprintf('2) Simscape Multibody is not installed, skipped\n\n');
end

% 3. random joint angles -> FK -> IK -> FK again, the tip must come back to the same point
rng(1);
n = 20000;  solved = 0;  worst = 0;
for k = 1:n
    th = p.limits(:, 1)' + rand(1, 4) .* (p.limits(:, 2) - p.limits(:, 1))';
    T = forward_kinematics(th);
    phi = th(2) + th(3) + th(4);
    for elbow = {'up', 'down'}
        [th2, ok] = inverse_kinematics(T(1:3, 4)', phi, elbow{1});
        if ok
            T2 = forward_kinematics(th2);
            worst = max(worst, norm(T2(1:3, 4) - T(1:3, 4)));
            solved = solved + 1;
        end
    end
end
fprintf('3) IK round trip: %d random poses, %d IK solutions within the limits\n', n, solved);
fprintf('   largest position error: %.1e mm\n\n', worst);

% 4. targets that cannot be reached
fprintf('4) targets that must be refused\n');
tests = {[1500 0 500], 0; [3 2 600], 0; [700 0 -100], -90; [250 0 150], -90};
for k = 1:size(tests, 1)
    [~, ok, msg] = inverse_kinematics(tests{k, 1}, tests{k, 2});
    fprintf('   %-16s phi %4d: ok = %d (%s)\n', mat2str(tests{k, 1}), tests{k, 2}, ok, msg);
end
diary off;
