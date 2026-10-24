function p = robot_params()
% ROBOT_PARAMS  Dimensions of the arm and the numbers that connect the math to the Simulink model.
% All lengths are in mm and all angles in degrees.
%
% The lengths were measured between the joint axes of the SolidWorks assembly
% (cad/Assem1.SLDASM). docs/dh_parameters.md explains where each number comes from.
%
% MohammadMahdi Faraji, mmyasharfaraji@gmail.com

% DH table (standard convention), one column per link
%            link 1   link 2   link 3   link 4 (tool)
p.a     = [    0      500      451.38    195 ];
p.alpha = [   90        0        0         0 ];
p.d     = [  496        0        0        10 ];

% joint limits [min max], the same ranges as the sliders of my first version
p.limits = [-180 180;
             -20 180;
            -150  75;
            -145  75];

% the base of the arm as two cylinders [radius height] in mm, measured from the STL files:
% the foot, and the column that turns with joint 1 (check_pose.m keeps the tool out of them)
p.base_size = [280 280;
               160 630];

% a comfortable starting pose
p.home = [0 45 -15 -30];

% The pose in which the arm was drawn in SolidWorks
p.cad_pose = [-2.928 47.676 -13.256 -33.193];

% In the Simulink model every joint measures its angle from the frames of the CAD mates,
% not from the DH zero. This line converts a DH angle to the angle of the model joint:
%   q = sim_sign .* theta + sim_offset
% (link 3 is bent by 18.738 deg, that is where the odd offsets come from)
p.sim_sign   = [1 1 -1 -1];
p.sim_offset = [180 0 -161.262 -18.738];
end
