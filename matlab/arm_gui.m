function fig = arm_gui()
% ARM_GUI  Window for moving the arm.
%   The sliders set the joint angles (forward kinematics). The panel on the right takes
%   a target point and finds the joint angles for it (inverse kinematics).
%   "Run Simulink model" starts simulink/robot_arm.slx, and from then on the Simscape
%   model follows every move made in this window.
%
%   MohammadMahdi Faraji, mmyasharfaraji@gmail.com
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', 'simulink'));
p = robot_params();
parts = load_arm_parts();
model = 'robot_arm';
model_loaded_here = false;
theta = p.home;
busy = false;                   % true while the arm is moving, the sliders wait

% ---------------- window
fig = uifigure('Name', '4-DOF robot arm  (MohammadMahdi Faraji)', 'Position', [40 40 1400 790], ...
    'CloseRequestFcn', @(~, ~) close_window());
main = uigridlayout(fig, [2 2]);
main.ColumnWidth = {'1x', 540};
main.RowHeight = {40, '1x'};

% title bar with my name and email
top = uigridlayout(main, [1 2], 'BackgroundColor', [0.13 0.24 0.40], 'Padding', [16 6 16 6]);
top.Layout.Row = 1;  top.Layout.Column = [1 2];
uilabel(top, 'Text', '4-DOF robot arm: forward and inverse kinematics', ...
    'FontSize', 18, 'FontWeight', 'bold', 'FontColor', [1 1 1]);
uilabel(top, 'Text', 'MohammadMahdi Faraji   |   mmyasharfaraji@gmail.com', ...
    'FontSize', 15, 'FontColor', [1 1 1], 'HorizontalAlignment', 'right');

% left: the 3D view, with the buttons under it
left = uigridlayout(main, [2 1], 'Padding', [20 0 0 0]);     % room on the left for the z label
left.Layout.Row = 2;  left.Layout.Column = 1;
left.RowHeight = {'1x', 34};
ax = uiaxes(left);
patch(ax, [-1200 1200 1200 -1200], [-1200 -1200 1200 1200], [0 0 0 0], [0.94 0.94 0.94], ...
    'EdgeColor', 'none', 'FaceLighting', 'none');                   % floor
h = draw_arm(ax, parts, theta);
xlim(ax, [-1200 1200]); ylim(ax, [-1200 1200]); zlim(ax, [0 1700]);
trail = plot3(ax, nan, nan, nan, 'r-', 'LineWidth', 1.5);
target_mark = plot3(ax, nan, nan, nan, 'kx', 'MarkerSize', 14, 'LineWidth', 2);

side = uigridlayout(main, [4 1], 'RowSpacing', 8);
side.Layout.Row = 2;  side.Layout.Column = 2;
side.RowHeight = {205, 72, 176, '1x'};

% joint sliders
jp = uipanel(side, 'Title', 'Joint angles (deg)');
jg = uigridlayout(jp, [4 3]);
jg.ColumnWidth = {30, '1x', 70};
sliders = matlab.ui.control.Slider.empty;
fields = matlab.ui.control.NumericEditField.empty;
ticks = {-180:90:180, 0:45:180, [-150 -100 -50 0 75], [-145 -100 -50 0 75]};
for i = 1:4
    uilabel(jg, 'Text', sprintf('%c%d', 952, i), 'FontSize', 14);
    sliders(i) = uislider(jg, 'Limits', p.limits(i, :), 'Value', theta(i), ...
        'MajorTicks', ticks{i}, 'MinorTicks', [], ...
        'ValueChangingFcn', @(s, e) set_joint(i, e.Value, s), ...
        'ValueChangedFcn', @(s, ~) set_joint(i, s.Value, s));
    fields(i) = uieditfield(jg, 'numeric', 'Limits', p.limits(i, :), 'Value', theta(i), ...
        'ValueDisplayFormat', '%.1f', 'ValueChangedFcn', @(s, ~) set_joint(i, s.Value, s));
end

% where the tool tip is
tp = uipanel(side, 'Title', 'Tool tip (base frame)');
tg = uigridlayout(tp, [1 1]);
tip_label = uilabel(tg, 'FontName', 'Consolas', 'FontSize', 12);

% inverse kinematics
kp = uipanel(side, 'Title', 'Go to a point (inverse kinematics)');
kg = uigridlayout(kp, [4 6], 'RowSpacing', 8);
kg.ColumnWidth = {50, '1x', 50, '1x', 50, '1x'};
kg.RowHeight = {22, 22, 26, '1x'};
uilabel(kg, 'Text', 'x (mm)');  ex = uieditfield(kg, 'numeric', 'Value', 700);
uilabel(kg, 'Text', 'y (mm)');  ey = uieditfield(kg, 'numeric', 'Value', 300);
uilabel(kg, 'Text', 'z (mm)');  ez = uieditfield(kg, 'numeric', 'Value', 400);
uilabel(kg, 'Text', sprintf('%c (deg)', 966));  ephi = uieditfield(kg, 'numeric', 'Value', -90);
uilabel(kg, 'Text', 'elbow');   elbow_box = uidropdown(kg, 'Items', {'up', 'down'});
uilabel(kg, 'Text', 'path');    path_box = uidropdown(kg, 'Items', {'joint space', 'straight line'});
move_btn = uibutton(kg, 'Text', 'Move', 'ButtonPushedFcn', @(~, ~) move_to_target());
move_btn.Layout.Row = 3;  move_btn.Layout.Column = [1 6];
status = uilabel(kg, 'Text', 'Move the sliders, or type a point and press Move.', 'WordWrap', 'on');
status.Layout.Row = 4;  status.Layout.Column = [1 6];

% what this project is, step by step, and how to use the window
info = uitabgroup(side);
about_tab = uitab(info, 'Title', 'About this project');
help_tab = uitab(info, 'Title', 'How to use');
uitextarea(uigridlayout(about_tab, [1 1], 'Padding', [0 0 0 0]), 'Editable', 'off', 'Value', {
    'From a 3D drawing to a moving arm, with a check at every step:'
    ['1. SolidWorks: I drew the five parts and joined them in an assembly. The shape and ' ...
     'the dimensions come from searching online, changed while drawing.']
    '2. Simscape Multibody Link exported the assembly (an XML file and STEP files).'
    '3. DH table: read from the joint axes in that export, four numbers per joint.'
    '4. Forward kinematics: joint angles to tool tip (the sliders).'
    ['5. Inverse kinematics: target point to joint angles, solved with geometry (Go to a point). ' ...
     'Targets the arm cannot reach safely are refused, with the reason.']
    ['6. Simscape: smimport built a Simulink model from the same export. ' ...
     '"Run Simulink model" starts it, and it follows this window.']
    '7. Checks: the CAD file, the Simscape sensor and the math agree within 0.01 mm.'
    ['The arm in the plot is drawn with the real CAD parts. It started as a course project and ' ...
     'was rebuilt so that every number comes from the CAD file.']
    });
uitextarea(uigridlayout(help_tab, [1 1], 'Padding', [0 0 0 0]), 'Editable', 'off', 'Value', {
    [sprintf('%c', 966) ' = angle of the tool from the horizontal: 0 is level, -90 is pointing down.']
    'Joint space: every joint turns evenly, and the tip moves on a curve.'
    'Straight line: inverse kinematics at 60 points of the line, so the tip moves straight.'
    'Elbow up or down: the two ways the arm can reach the same point.'
    'Red line: the path of the tip. Drag the 3D view to turn it.'
    });

% buttons under the 3D view
bg = uigridlayout(left, [1 4], 'Padding', [0 0 0 0]);
bg.Layout.Row = 2;
bg.ColumnWidth = {110, 170, 110, '1x'};
uibutton(bg, 'Text', 'Home', 'ButtonPushedFcn', @(~, ~) go_home());
sim_btn = uibutton(bg, 'state', 'Text', 'Run Simulink model', ...
    'ValueChangedFcn', @(s, ~) simulink_on_off(s.Value));
uibutton(bg, 'Text', 'Clear path', 'ButtonPushedFcn', @(~, ~) clear_trail());

show();


    % ---------------- callbacks and helpers (they share the variables above)

    function set_joint(j, value, source)
        % joint j was moved with its slider or typed in its field
        if busy, return; end
        theta(j) = value;
        show(source);
    end

    function show(source)
        % draw the arm, write the tip position, update sliders and the Simulink model
        if nargin < 1, source = []; end
        h = draw_arm(ax, parts, theta, h);
        T = forward_kinematics(theta);
        phi = mod(sum(theta(2:4)) + 180, 360) - 180;
        if theta(3) < 0, elbow = 'up'; else, elbow = 'down'; end
        [pose_ok, pose_msg] = check_pose(theta);
        if pose_ok
            note = '';
            tip_label.FontColor = [0 0 0];
        else
            note = ['not allowed: ' pose_msg];
            tip_label.FontColor = [0.75 0 0];
        end
        tip_label.Text = sprintf('x = %7.1f  y = %7.1f  z = %7.1f mm    %c = %6.1f deg  elbow %s\n%s', ...
            T(1:3, 4), 966, phi, elbow, note);
        for k = 1:4
            if ~isequal(sliders(k), source), sliders(k).Value = theta(k); end
            if ~isequal(fields(k), source), fields(k).Value = theta(k); end
        end
        if model_running()
            for k = 1:4
                set_param([model '/theta' num2str(k)], 'Value', num2str(theta(k), 8));
            end
        end
    end

    function move_to_target()
        if busy, return; end
        target = [ex.Value ey.Value ez.Value];
        set(target_mark, 'XData', target(1), 'YData', target(2), 'ZData', target(3));
        if strcmp(path_box.Value, 'straight line')
            [path, ok, msg] = plan_line(theta, target, ephi.Value);
        else
            [goal, ok, msg] = inverse_kinematics(target, ephi.Value, elbow_box.Value);
            if ok, path = joint_path(theta, goal); end
        end
        if ~ok
            status.Text = ['Cannot move there: ' msg '.'];
            status.FontColor = [0.75 0 0];
            return
        end
        animate(path);
        status.Text = sprintf('Done. Joint angles: %.1f, %.1f, %.1f, %.1f deg', theta);
        if strcmp(path_box.Value, 'straight line')
            status.Text = [status.Text ' (on a straight line the elbow stays as it was)'];
        end
        status.FontColor = [0 0.45 0];
    end

    function go_home()
        if busy, return; end
        animate(joint_path(theta, p.home));
    end

    function path = joint_path(from, to)
        % every joint turns at the same time, starting and stopping smoothly
        s = (1 - cos(pi * linspace(0, 1, 50)')) / 2;
        path = from + s .* (to - from);
    end

    function animate(path)
        busy = true;
        for k = 1:size(path, 1)
            if ~isvalid(fig), return; end
            theta = path(k, :);
            show();
            T = forward_kinematics(theta);
            trail.XData(end + 1) = T(1, 4);
            trail.YData(end + 1) = T(2, 4);
            trail.ZData(end + 1) = T(3, 4);
            drawnow limitrate;
            pause(0.02);
        end
        busy = false;
    end

    function clear_trail()
        set(trail, 'XData', nan, 'YData', nan, 'ZData', nan);
        set(target_mark, 'XData', nan, 'YData', nan, 'ZData', nan);
    end

    function simulink_on_off(on)
        if on
            sim_btn.Text = 'Stop Simulink model';
            status.Text = 'Starting the Simscape model. Mechanics Explorer opens in its own window.';
            status.FontColor = [0 0 0];
            drawnow;
            if ~bdIsLoaded(model)
                load_system(model);
                model_loaded_here = true;
            end
            for k = 1:4
                set_param([model '/theta' num2str(k)], 'Value', num2str(theta(k), 8));
            end
            % run without end, at the speed of the clock on the wall
            set_param(model, 'StopTime', 'inf', 'EnablePacing', 'on', 'PacingRate', '1');
            set_param(model, 'SimulationCommand', 'start');
        else
            stop_model();
            sim_btn.Text = 'Run Simulink model';
        end
    end

    function running = model_running()
        running = bdIsLoaded(model) && any(strcmp(get_param(model, 'SimulationStatus'), {'running', 'paused'}));
    end

    function stop_model()
        % 'stop' only asks Simulink to stop, so wait until it has really stopped
        if ~model_running(), return; end
        set_param(model, 'SimulationCommand', 'stop');
        t = tic;
        while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped') && toc(t) < 20
            pause(0.1);
        end
    end

    function close_window()
        stop_model();
        % the model was only changed by this window (angles, stop time), so it is not saved
        if model_loaded_here && bdIsLoaded(model), close_system(model, 0); end
        delete(fig);
    end
end
