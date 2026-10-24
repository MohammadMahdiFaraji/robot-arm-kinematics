# Where the DH table comes from

The Denavit-Hartenberg (DH) table describes the arm with four numbers per joint. If one of them is wrong, every point computed with it lands in the wrong place. This page shows where each number of the table comes from, so anyone with the SolidWorks files can check it.

All numbers were read from `simulink/Assem1.xml`. Simscape Multibody Link writes this file when it exports the assembly. It lists where each part sits and every mate (a constraint between two parts) in the part's own coordinates. Lengths are in mm, angles in degrees.

## The table

| link | a (mm) | alpha | d (mm) | theta |
|---|---|---|---|---|
| 1 | 0 | 90 | 496 | theta1 |
| 2 | 500 | 0 | 0 | theta2 |
| 3 | 451.38 | 0 | 0 | theta3 |
| 4 (tool) | 195 | 0 | 10 | theta4 |

Standard DH convention: `A_i = Rot_z(theta_i) * Trans_z(d_i) * Trans_x(a_i) * Rot_x(alpha_i)`.

The base frame {0} sits at the centre of the bottom face of the base, with z pointing up. SolidWorks uses y as "up", so the base frame is the CAD frame turned by -90 degrees about x (`x0 = X`, `y0 = -Z`, `z0 = Y`).

When every angle is zero, the arm is stretched out flat, pointing along x0, and the tool is level.

## Each number

**Joint 1, the vertical axis.** The mate `Coincident1` puts a circle of `part2-link1` on the top face of `part1-base`, 280 mm above the floor. Both share the vertical axis through the centre of the base, so joint 1 turns about z0.

**d1 = 496 and alpha1 = 90.** The bearing hole for joint 2 (`Concentric1`) is in `part2-link1` at local height 336 mm. The bottom of that part (local height 120 mm) sits on the 280 mm face. So the axis of joint 2 is 280 + 336 - 120 = 496 mm above the floor. That axis is horizontal and it meets the axis of joint 1 in one point, so a1 = 0. Turning from a vertical axis to a horizontal one is the 90 degree twist alpha1.

**a2 = 500.** `Part3` (the gold link) has its two bearing holes at local `(0, 90, 0)` and `(0, 90, -500)`. The joint 2 and joint 3 axes are parallel and 500 mm apart.

**a3 = 451.38.** `part4` is bent. Its two holes are at local `(92.545, -145)` and `(520, 0)`. That is 427.455 mm along the part and 145 mm across it. DH only cares about the straight line from one axis to the next:

    a3 = sqrt(427.455^2 + 145^2) = 451.38 mm

The bend angle, `atan2(145, 427.455) = 18.738` degrees, comes back later in the Simulink model.

**a4 = 195.** The origin of `Part5` lies on the joint 4 axis, and the far end of the part is at local x = 195 mm. So the tool tip is 195 mm from the last joint.

**d4 = 10.** Not every link sits in the same vertical plane. Seen from above, the parts are stacked side by side along the joint axes. Adding up these sideways steps, the tool tip ends 10.0 mm to the side of the plane that goes through the base axis. All the joint 2, 3 and 4 axes are parallel, so this sideways offset can go into a single `d`. It is put into d4, so that the last frame sits exactly on the tool tip.

The first version of the project left out this 10 mm. The inverse kinematics has to take it into account: seen from above, the arm points slightly past the target (`theta1 = atan2(y, x) + atan2(10, r)`).

## Checking the table against the CAD file

In the saved SolidWorks assembly, the arm stands in one pose. Reading the part rotations from the XML gives that pose in DH angles:

    theta = [-2.928  47.676  -13.256  -33.193]

The same XML gives the position of the tool tip (Part5 local `(195, 0, 0)`) in the base frame: `[902.279 -56.160 1124.989]`. Forward kinematics with the table above gives `[902.276 -56.162 1124.995]`, 0.007 mm away. The small rest comes from rounding the angles to three decimals.

There is a second check, which is easy to see: `load_arm_parts.m` attaches every STL mesh to its DH frame in this CAD pose. When `draw_arm.m` then draws the arm in any other pose, the parts stay joined at the joints. With a wrong table, they would drift apart.

## Angles in the Simulink model

The Simscape joints do not measure their angle from the DH zero. They measure it from the frames of the SolidWorks mates. The conversion is one line, `q = sim_sign .* theta + sim_offset`, with

    sim_sign   = [1  1  -1  -1]
    sim_offset = [180  0  -161.262  -18.738]

- **Joints 3 and 4:** their mates point the other way, so their sign is -1.
- **Joint 3 and joint 4 offsets:** they come from the bend of `part4` (180 - 18.738 = 161.262).
- **Joint 1 offset:** the zero of its mate is turned 180 degrees from the DH zero.

`simulink/make_model.m` builds these sign and offset blocks into the model, so the model takes DH angles directly.

## Result

`matlab/check_kinematics.m` runs all the checks and writes `results/kinematics_check.txt`:

- **Forward kinematics vs the CAD tool tip:** 0.007 mm.
- **Forward kinematics vs the Simscape model:** 0.0019 mm in 8 poses. The model has its own transform sensor between the base and the tool tip.
- **Inverse kinematics followed by forward kinematics:** back to the same point within 1e-12 mm, over 20000 random poses.
