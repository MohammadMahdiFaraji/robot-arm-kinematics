function fig = arm_gui()
% ARM_GUI  Window for moving the arm.
%   The sliders set the joint angles (forward kinematics). The panel on the right takes
%   a target point and finds the joint angles for it (inverse kinematics).
%   Buttons under the 3D view:
%     Home        back to the home pose, from any state (also in the middle of a move)
%     Reset view  the 3D view as it was when the window opened (after zooming or turning it)
%     Start       goes on with the move that Stop interrupted
%     Stop        the arm stops where it is, also in the middle of a move
%   The switch "Simscape model" runs simulink/robot_arm.slx, and from then on the model
%   follows every move made in this window.
%
%   MohammadMahdi Faraji, mmyasharfaraji@gmail.com
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', 'simulink'));
p = robot_params();
parts = load_arm_parts();
model = 'robot_arm';
model_loaded_here = false;
model_settings = {};            % stop time and pacing of the model before this window changed them
sim_starting = false;
theta = p.home;

% How the moves work: every command that moves the arm (Move, Home, Start) takes a new
% number in move_id. The loop that animates a move ends as soon as move_id is not its own
% number any more, so Stop, Home, a new Move or a slider can always take over.
move_id = 0;
moving = false;
current = [];                   % the move that is running now
stopped = [];                   % the move that Stop interrupted, Start goes on with it

black = [0 0 0];  green = [0 0.45 0];  red = [0.75 0 0];  orange = [0.75 0.40 0];

% ---------------- window (smaller on small screens)
scr = get(groot, 'ScreenSize');
fig = uifigure('Name', '4-DOF robot arm  (MohammadMahdi Faraji)', ...
    'Position', [40 40 min(1400, scr(3) - 80) min(790, scr(4) - 74)], ...
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
lamp = findobj(ax, 'Type', 'light');                                % made by draw_arm
trail = plot3(ax, nan, nan, nan, 'r-', 'LineWidth', 1.5);
target_mark = plot3(ax, nan, nan, nan, 'kx', 'MarkerSize', 14, 'LineWidth', 2);
reset_view();

side = uigridlayout(main, [5 1], 'RowSpacing', 8, 'Padding', [0 0 0 0]);
side.Layout.Row = 2;  side.Layout.Column = 2;
side.RowHeight = {205, 72, 168, 26, '1x'};

% joint sliders
jp = uipanel(side, 'Title', 'Joint angles (deg)');
jg = uigridlayout(jp, [4 3]);
jg.ColumnWidth = {30, '1x', 70};
sliders = matlab.ui.control.Slider.empty;
fields = matlab.ui.control.NumericEditField.empty;
ticks = {-180:90:180, 0:45:180, [-150 -100 -50 0 75], [-145 -100 -50 0 75]};
for i = 1:4
    uilabel(jg, 'Text', sprintf('θ%d', i), 'FontSize', 14);
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
uilabel(kg, 'Text', 'φ (deg)');  ephi = uieditfield(kg, 'numeric', 'Value', -90);
uilabel(kg, 'Text', 'elbow');   elbow_box = uidropdown(kg, 'Items', {'up', 'down'}, ...
    'Tooltip', 'Only for joint space moves. On a straight line the elbow stays as it is.');
uilabel(kg, 'Text', 'path');    path_box = uidropdown(kg, 'Items', {'joint space', 'straight line'}, ...
    'ValueChangedFcn', @(s, ~) set(elbow_box, 'Enable', strcmp(s.Value, 'joint space')));
move_btn = uibutton(kg, 'Text', 'Move', 'ButtonPushedFcn', @(~, ~) move_to_target());
move_btn.Layout.Row = 3;  move_btn.Layout.Column = [1 6];
status = uilabel(kg, 'Text', 'Move the sliders, or type a point and press Move.', 'WordWrap', 'on');
status.Layout.Row = 4;  status.Layout.Column = [1 6];

% Simscape model on / off
sg = uigridlayout(side, [1 3], 'Padding', [8 0 8 0]);
sg.ColumnWidth = {180, 90, '1x'};
uilabel(sg, 'Text', 'Simscape model (Simulink)', 'FontWeight', 'bold');
sim_switch = uiswitch(sg, 'Items', {'Off', 'On'}, ...
    'ValueChangedFcn', @(s, ~) simulink_on_off(strcmp(s.Value, 'On')));
uilabel(sg, 'Text', 'opens in Mechanics Explorer', 'FontColor', [0.4 0.4 0.4]);

% what this project is, step by step, and how to use the window
info = uitabgroup(side);
about_tab = uitab(info, 'Title', 'About this project');
help_tab = uitab(info, 'Title', 'How to use');
uitextarea(uigridlayout(about_tab, [1 1], 'Padding', [0 0 0 0]), 'Editable', 'off', 'Value', {
    'How this project was made:'
    ['1. SolidWorks: I drew the five parts and joined them in an assembly. The shape and ' ...
     'the dimensions come from searching online, changed while drawing.']
    '2. Simscape Multibody Link exported the assembly (an XML file and STEP files).'
    '3. DH table: read from the joint axes in that export, four numbers per joint.'
    '4. Forward kinematics: joint angles to tool tip (the sliders).'
    ['5. Inverse kinematics: target point to joint angles, solved with geometry (Go to a point). ' ...
     'Targets the arm cannot reach safely are refused, with the reason.']
    ['6. Simscape: smimport built a Simulink model from the same export. ' ...
     'The switch "Simscape model" runs it, and it follows this window.']
    '7. Checks: the CAD file, the Simscape sensor and the math agree within 0.01 mm.'
    ['The arm in the plot is drawn with the real CAD parts. It started as a course project and ' ...
     'was rebuilt so that every number comes from the CAD file.']
    });
uitextarea(uigridlayout(help_tab, [1 1], 'Padding', [0 0 0 0]), 'Editable', 'off', 'Value', {
    'Sliders: one joint each. Go to a point: type x, y, z and φ, then press Move.'
    'φ = angle of the tool from the horizontal: 0 is level, -90 is pointing down.'
    'Joint space: every joint turns evenly and the tip moves on a curve. Straight line: inverse kinematics at every step, so the tip moves straight.'
    'Elbow up or down: the two ways the arm can reach the same point.'
    'Stop: the arm stops where it is, also in the middle of a move. Start: it goes on to the same target.'
    'Home: back to the home pose from any state. Reset view: the 3D view as it was at the start.'
    'Red line: the path of the tip in the last move. Drag the 3D view to turn it, scroll to zoom.'
    });

% buttons under the 3D view
bg = uigridlayout(left, [1 5], 'Padding', [0 0 0 0]);
bg.Layout.Row = 2;
bg.ColumnWidth = {100, 110, 100, 100, '1x'};
uibutton(bg, 'Text', 'Home', 'Tooltip', 'Back to the home pose, from any state', ...
    'ButtonPushedFcn', @(~, ~) go_home());
uibutton(bg, 'Text', 'Reset view', 'Tooltip', 'The 3D view as it was when the window opened', ...
    'ButtonPushedFcn', @(~, ~) reset_view());
start_btn = uibutton(bg, 'Text', 'Start', 'Enable', 'off', 'BackgroundColor', [0.80 0.93 0.80], ...
    'Tooltip', 'Go on with the move that was stopped', 'ButtonPushedFcn', @(~, ~) go_on());
stop_btn = uibutton(bg, 'Text', 'Stop', 'Enable', 'off', 'BackgroundColor', [0.97 0.80 0.80], ...
    'Tooltip', 'Stop the arm where it is', 'ButtonPushedFcn', @(~, ~) stop_move());

show();


    % ---------------- callbacks and helpers (they share the variables above)

    function set_joint(j, value, source)
        % joint j was moved with its slider or typed in its field.
        % The sliders take over from a move that is running or was stopped.
        if moving || ~isempty(stopped)
            cancel_move();
            say('The move was cancelled, the sliders move the arm now.', black);
        end
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
            tip_label.FontColor = black;
        else
            note = ['not allowed: ' pose_msg];
            tip_label.FontColor = red;
        end
        tip_label.Text = sprintf('x = %7.1f  y = %7.1f  z = %7.1f mm    φ = %6.1f deg  elbow %s\n%s', ...
            T(1:3, 4), phi, elbow, note);
        for k = 1:4
            if ~isequal(sliders(k), source), sliders(k).Value = theta(k); end
            if ~isequal(fields(k), source), fields(k).Value = theta(k); end
        end
        if model_running()
            send_angles();
        elseif strcmp(sim_switch.Value, 'On') && ~sim_starting
            % the model was stopped outside this window, for example in Simulink
            sim_switch.Value = 'Off';
            stop_model();
        end
    end

    function move_to_target()
        % Move button
        target = [ex.Value ey.Value ez.Value];
        set(target_mark, 'XData', target(1), 'YData', target(2), 'ZData', target(3));
        m = struct('kind', 'line', 'goal', [], 'target', target, 'phi', ephi.Value, 'name', 'target');
        if strcmp(path_box.Value, 'joint space')
            [m.goal, ok, msg] = inverse_kinematics(target, ephi.Value, elbow_box.Value);
            if ~ok
                say(['Cannot move there: ' msg '.'], red);
                return
            end
            m.kind = 'joint';
        end
        run_move(m, true);
    end

    function go_home()
        set(target_mark, 'XData', nan, 'YData', nan, 'ZData', nan);
        run_move(struct('kind', 'joint', 'goal', p.home, 'target', [], 'phi', [], 'name', 'home'), true);
    end

    function go_on()
        % Start button
        if moving || isempty(stopped), return; end
        run_move(stopped, false);
    end

    function stop_move()
        % Stop button: the loop of the move ends at its next step, the arm stays there
        if ~moving, return; end
        m = current;
        cancel_move();
        stopped = m;
        set_buttons();
        say('Stopped. The arm holds this pose. Start goes on to the target, Home goes back home.', orange);
    end

    function cancel_move()
        move_id = move_id + 1;
        moving = false;
        current = [];
        stopped = [];
        set_buttons();
    end

    function set_buttons()
        stop_btn.Enable = moving;
        start_btn.Enable = ~moving && ~isempty(stopped);
    end

    function run_move(m, new_move)
        % Plan the path from the pose the arm is in now, then move along it.
        % new_move is false when Start goes on with a stopped move (the red line is kept).
        if strcmp(m.kind, 'line')
            T = forward_kinematics(theta);
            n = max(10, ceil(norm(m.target - T(1:3, 4)') / 6));        % about 6 mm per step
            [path, ok, msg] = plan_line(theta, m.target, m.phi, n);
        else
            path = joint_path(theta, m.goal);
            [ok, msg] = path_allowed(path, m);
        end
        if ~ok
            say(['Cannot move there: ' msg '.'], red);
            return
        end

        cancel_move();                      % a move that is running or stopped ends here
        my_id = move_id;
        moving = true;
        current = m;
        set_buttons();
        if new_move
            T = forward_kinematics(theta);
            set(trail, 'XData', T(1, 4), 'YData', T(2, 4), 'ZData', T(3, 4));
        end
        if strcmp(m.name, 'home'), say('Going home...', black); else, say('Moving...', black); end

        for k = 2:size(path, 1)
            theta = path(k, :);
            show();
            T = forward_kinematics(theta);
            set(trail, 'XData', [trail.XData T(1, 4)], 'YData', [trail.YData T(2, 4)], ...
                'ZData', [trail.ZData T(3, 4)]);
            drawnow limitrate;
            pause(0.02);
            % the window was closed, or Stop, Home, a new move or a slider took over
            if ~isvalid(fig) || move_id ~= my_id, return; end
        end
        drawnow;                            % limitrate may have skipped the last picture
        if ~isvalid(fig) || move_id ~= my_id, return; end
        moving = false;
        current = [];
        set_buttons();
        if strcmp(m.name, 'home')
            say('The arm is at the home pose.', green);
        else
            say(sprintf('Done. Joint angles: %.1f, %.1f, %.1f, %.1f deg', theta), green);
        end
    end

    function path = joint_path(from, to)
        % every joint turns at the same time, starting and stopping smoothly
        % (about 2 deg per step for the joint that turns the most)
        n = max(15, ceil(max(abs(to - from)) / 2));
        s = (1 - cos(pi * linspace(0, 1, n)')) / 2;
        path = from + s .* (to - from);
    end

    function [ok, msg] = path_allowed(path, m)
        % Both ends of a joint space move can be allowed while a pose in between is not
        % (the tip dips under the floor). Home is never refused, it is the way back.
        ok = true;
        msg = 'ok';
        if strcmp(m.name, 'home') || ~check_pose(path(1, :)), return; end
        for k = 2:size(path, 1)
            [good, why] = check_pose(path(k, :));
            if ~good
                ok = false;
                msg = ['on the way ' why ', try a straight line or the other elbow'];
                return
            end
        end
    end

    function say(text, color)
        status.Text = text;
        status.FontColor = color;
    end

    function reset_view()
        % the view the window opens with, also after zooming, panning or turning the 3D view
        ax.CameraPositionMode = 'auto';
        ax.CameraTargetMode = 'auto';
        ax.CameraUpVectorMode = 'auto';
        ax.CameraViewAngleMode = 'auto';
        xlim(ax, [-1200 1200]); ylim(ax, [-1200 1200]); zlim(ax, [0 1700]);
        view(ax, 135, 20);
        camlight(lamp, 'headlight');
    end

    function simulink_on_off(on)
        if ~on
            stop_model();
            say('The Simscape model was stopped.', black);
            return
        end
        say('Starting the Simscape model, the first start can take half a minute...', black);
        sim_starting = true;
        drawnow;
        if ~isvalid(fig), return; end
        try
            if ~bdIsLoaded(model)
                load_system(model);
                model_loaded_here = true;
            end
            model_settings = {get_param(model, 'StopTime'), get_param(model, 'EnablePacing')};
            send_angles();
            % no stop time, and pacing on so the model runs in real time
            set_param(model, 'StopTime', 'inf', 'EnablePacing', 'on', 'PacingRate', '1');
            set_param(model, 'SimulationCommand', 'start');
            t = tic;
            while ~any(strcmp(get_param(model, 'SimulationStatus'), {'running', 'stopped'})) && toc(t) < 120
                pause(0.2);
            end
            started = strcmp(get_param(model, 'SimulationStatus'), 'running');
            why = 'see the Diagnostic Viewer in Simulink';
        catch err
            started = false;
            why = err.message;
        end
        sim_starting = false;
        if ~isvalid(fig) || strcmp(sim_switch.Value, 'Off')
            stop_model();                   % closed or switched off while starting
            return
        end
        if started
            send_angles();                  % the arm may have moved while the model started
            say('The Simscape model is running and follows every move made in this window.', green);
        else
            sim_switch.Value = 'Off';
            stop_model();
            say(['The Simscape model did not start: ' why], red);
        end
    end

    function running = model_running()
        running = bdIsLoaded(model) && any(strcmp(get_param(model, 'SimulationStatus'), {'running', 'paused'}));
    end

    function send_angles()
        for k = 1:4
            set_param([model '/theta' num2str(k)], 'Value', num2str(theta(k), 8));
        end
    end

    function stop_model()
        % 'stop' only asks Simulink to stop, so wait until it has really stopped,
        % then give the model back its own stop time and pacing
        if ~bdIsLoaded(model), return; end
        t = tic;
        while ~strcmp(get_param(model, 'SimulationStatus'), 'stopped') && toc(t) < 20
            try
                set_param(model, 'SimulationCommand', 'stop');
            catch
                % still compiling, it cannot stop yet, try again
            end
            pause(0.2);
        end
        if ~isempty(model_settings)
            set_param(model, 'StopTime', model_settings{1}, 'EnablePacing', model_settings{2});
            model_settings = {};
        end
    end

    function close_window()
        cancel_move();
        try
            stop_model();
            % the model was only changed by this window (angles, stop time), so it is not saved
            if model_loaded_here && bdIsLoaded(model), close_system(model, 0); end
        catch err
            fprintf('Simulink: %s\n', err.message);
        end
        delete(fig);
    end
end
