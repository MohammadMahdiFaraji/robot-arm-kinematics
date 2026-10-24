function parts = load_arm_parts()
% LOAD_ARM_PARTS  The five STL meshes, each one stored relative to the DH frame it moves with.
%
% Assem1.xml says where every part sits in the SolidWorks pose (p.cad_pose). In that pose
% I compute the DH frames with forward_kinematics and keep each mesh relative to its frame.
% After that, drawing the arm for any angles only means moving every mesh with its frame
% (see draw_arm.m). If the DH table were wrong, the parts would come apart in the picture.
here = fileparts(mfilename('fullpath'));
p = robot_params();

names = {'part1-base', 'part2-link1', 'Part3', 'part4', 'Part5'};
uids  = {'part1-base-1', 'part2-link1-1', 'Part3-1', 'part4-1', 'Part5-1'};
colors = [0.80 0.82 0.93; 0.80 0.82 0.93; 0.97 0.88 0.60; 0.80 0.82 0.93; 0.80 0.82 0.93];

% where each part is in the CAD file (metres, y axis up)
pose = read_cad_poses(fullfile(here, '..', 'simulink', 'Assem1.xml'));

% base frame {0}: same origin as the base part, z up instead of y up
R0 = [1 0 0; 0 0 -1; 0 1 0];
base = pose.(matlab.lang.makeValidName(uids{1}));

[~, ~, frames] = forward_kinematics(p.cad_pose);
parts = struct('name', names, 'faces', [], 'vertices', [], 'color', []);
for k = 1:5
    mesh = stlread(fullfile(here, '..', 'cad', 'stl', [names{k} '.STL']));
    P = pose.(matlab.lang.makeValidName(uids{k}));
    % part frame -> base frame, in mm
    T_part = [R0 * P.R, 1000 * R0 * (P.t - base.t); 0 0 0 1];
    % part frame relative to the DH frame it is fixed to
    T_rel = frames(:, :, k) \ T_part;
    v = 1000 * mesh.Points';                       % m -> mm
    v = T_rel(1:3, 1:3) * v + T_rel(1:3, 4);
    parts(k).faces = mesh.ConnectivityList;
    parts(k).vertices = v';
    parts(k).color = colors(k, :);
end
end


function pose = read_cad_poses(xml_file)
% rotation and translation of every part instance in Assem1.xml
doc = xmlread(xml_file);
list = doc.getElementsByTagName('Instance');
pose = struct();
for i = 0:list.getLength - 1
    node = list.item(i);
    uid = char(node.getAttribute('uid'));
    R = sscanf(char(node.getElementsByTagName('Rotation').item(0).getTextContent), '%f');
    t = sscanf(char(node.getElementsByTagName('Translation').item(0).getTextContent), '%f');
    pose.(matlab.lang.makeValidName(uid)).R = reshape(R, 3, 3)';   % the file lists the rows
    pose.(matlab.lang.makeValidName(uid)).t = t(:);
end
end
