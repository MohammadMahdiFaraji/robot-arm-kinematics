% MAKE_MODEL  Builds robot_arm.slx from the SolidWorks export.
%
% Steps:
%   1. smimport reads Assem1.xml (made with Simscape Multibody Link) and the STEP files
%   2. every joint gets a motion input: the angle in degrees, in the DH convention
%   3. a base frame and a tool tip frame are added, with a sensor between them,
%      so the model itself reports where the tip is (to check forward_kinematics.m)
% Run it again if the arm is exported from SolidWorks again.
%
% MohammadMahdi Faraji, mmyasharfaraji@gmail.com

here = fileparts(mfilename('fullpath'));
cd(here);
addpath(fullfile(here, '..', 'matlab'));
p = robot_params();
model = 'robot_arm';

if bdIsLoaded(model), close_system(model, 0); end
if isfile([model '.slx']), delete([model '.slx']); end
if isfile('robot_arm_data.m'), delete('robot_arm_data.m'); end
smimport('Assem1.xml', 'ModelName', model, 'DataFileName', 'robot_arm_data');

% ---- joints: angle comes from outside, torque is computed by Simscape
old_names = {'Revolute', 'Revolute1', 'Revolute2', 'Revolute3'};
for i = 1:4
    j = [model '/Joint' num2str(i)];
    set_param([model '/' old_names{i}], 'Name', ['Joint' num2str(i)]);
    set_param(j, 'TorqueActuationMode', 'ComputedTorque', 'MotionActuationMode', 'InputMotion', ...
        'PositionTargetSpecify', 'off');

    % theta (DH, deg) -> sign and offset -> physical signal for the joint
    x = 40;  y = 60 + 110 * (i - 1);
    add_block('simulink/Sources/Constant', [model '/theta' num2str(i)], 'Value', num2str(p.home(i)), ...
        'Position', [x y x+50 y+30]);
    add_block('simulink/Math Operations/Gain', [model '/sign' num2str(i)], 'Gain', num2str(p.sim_sign(i)), ...
        'Position', [x+90 y x+120 y+30]);
    add_block('simulink/Math Operations/Bias', [model '/offset' num2str(i)], 'Bias', num2str(p.sim_offset(i)), ...
        'Position', [x+150 y x+200 y+30]);
    add_block('nesl_utility/Simulink-PS Converter', [model '/to joint' num2str(i)], 'Unit', 'deg', ...
        'FilteringAndDerivatives', 'filter', 'SimscapeFilterOrder', '2', 'InputFilterTimeConstant', '0.1', ...
        'Position', [x+240 y x+270 y+30]);
    add_line(model, ['theta' num2str(i) '/1'], ['sign' num2str(i) '/1']);
    add_line(model, ['sign' num2str(i) '/1'], ['offset' num2str(i) '/1']);
    add_line(model, ['offset' num2str(i) '/1'], ['to joint' num2str(i) '/1']);
    conv = get_param([model '/to joint' num2str(i)], 'PortHandles');
    joint = get_param(j, 'PortHandles');
    add_line(model, conv.RConn(1), joint.LConn(2));
end

% ---- base frame {0}: bottom centre of the base, z up (the CAD uses y up)
base = [model '/part1_base_1_RIGID'];
add_block('sm_lib/Frames and Transforms/Rigid Transform', [base '/Frame 0'], ...
    'RotationMethod', 'StandardAxis', 'RotationStandardAxis', '+X', 'RotationAngle', '-90');
add_block('nesl_utility/Connection Port', [base '/F0'], 'Side', 'Right');
connect_frames(base, 'ReferenceFrame', 'Frame 0', 'F0');

% ---- tool tip: end of the last part, 195 mm along its own x axis
tool = [model '/Part5_1_RIGID'];
add_block('sm_lib/Frames and Transforms/Rigid Transform', [tool '/Tool tip'], ...
    'TranslationMethod', 'Cartesian', 'TranslationCartesianOffset', '[195 0 0]', ...
    'TranslationCartesianOffsetUnits', 'mm');
add_block('nesl_utility/Connection Port', [tool '/TCP'], 'Side', 'Right');
connect_frames(tool, 'ReferenceFrame', 'Tool tip', 'TCP');

% ---- sensor: position of the tool tip in frame {0}, in mm
add_block('sm_lib/Frames and Transforms/Transform Sensor', [model '/Tip sensor'], ...
    'MeasurementFrame', 'Base', 'SenseX', 'on', 'SenseY', 'on', 'SenseZ', 'on');
base_ports = get_param(base, 'PortHandles');
tool_ports = get_param(tool, 'PortHandles');
sensor = get_param([model '/Tip sensor'], 'PortHandles');
add_line(model, base_ports.RConn(end), sensor.LConn(1));
add_line(model, tool_ports.RConn(end), sensor.RConn(1));
add_block('simulink/Signal Routing/Mux', [model '/Mux'], 'Inputs', '3');
xyz = {'x', 'y', 'z'};
for k = 1:3
    name = [model '/' xyz{k} ' (mm)'];
    add_block('nesl_utility/PS-Simulink Converter', name, 'Unit', 'mm');
    c = get_param(name, 'PortHandles');
    add_line(model, sensor.RConn(1 + k), c.LConn(1));
    add_line(model, [xyz{k} ' (mm)/1'], ['Mux/' num2str(k)]);
end
add_block('simulink/Sinks/Display', [model '/tip position (mm)']);
add_block('simulink/Sinks/To Workspace', [model '/tip'], 'VariableName', 'tip_mm', 'SaveFormat', 'Array');
add_line(model, 'Mux/1', 'tip position (mm)/1');
add_line(model, 'Mux/1', 'tip/1');

Simulink.BlockDiagram.arrangeSystem(model);
set_param(model, 'StopTime', '10');

% smimport keeps the part data (masses, colours, frames) in robot_arm_data.m and the model
% points to that file with its full path on this computer. Keep the data inside the
% model instead, so the model also opens on another computer.
ws = get_param(model, 'ModelWorkspace');
ws.FileName = 'robot_arm_data.m';      % without the folder, the model still remembers this name
ws.DataSource = 'Model File';
delete('robot_arm_data.m');
save_system(model);
fprintf('saved %s.slx\n', model);


function connect_frames(sys, ref_block, transform_block, port_block)
% Reference frame -> rigid transform -> connection port, inside a part subsystem
r = get_param([sys '/' ref_block], 'PortHandles');
t = get_param([sys '/' transform_block], 'PortHandles');
c = get_param([sys '/' port_block], 'PortHandles');
add_line(sys, r.RConn(1), t.LConn(1));
add_line(sys, t.RConn(1), c.RConn(1));
end
