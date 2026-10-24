# What changed since the course version

The first version of this project was a course project: a SolidWorks arm, a Simscape model exported from it, and a GUIDE window with sliders. Those original files are kept in `legacy/original_course_submission/`, so the two versions can be compared.

When the project was opened again for this repository, the original files were checked one by one against the 3D model. The window looked fine, but several numbers did not match the arm. The list below says what was wrong and how the new version handles it.

## Kinematics

**The link lengths did not match the CAD model.** The old code used `a1 = 486`, `a3 = 420.17` and `a4 = 160`. The joint axes in the assembly give 496, 451.38 and 195 mm. Link 3 is bent, so its DH length is the straight distance between its two joint axes. `docs/dh_parameters.md` shows where every new number comes from.

**The 10 mm side offset of the tool was missing.** Seen from above, the tool tip is 10 mm beside the plane of the arm. The new table has it as `d4 = 10`.

**The first matrix was not a rotation.** In the old `T1`, the first and third columns were not perpendicular, and its determinant was `-cos(2*theta1)` instead of 1. Its second column pointed down instead of up, which mirrors the arm about the height of the shoulder. For example, turning joint 2 to +45 degrees put the elbow at a height of about 132 mm, below the 486 mm shoulder. The new `forward_kinematics.m` builds every matrix from one DH function, so a typo cannot hide in one link.

**Forward and inverse kinematics disagreed.** Because of that mirror, the old forward kinematics measured height downwards from the shoulder, and the old inverse kinematics measured it upwards. If you asked the inverse kinematics for a height z and put the answer back into the forward kinematics, you got `972 - z`. Now both use the same frames. `check_kinematics.m` tests this round trip on 20000 random poses, and the largest error is about 1e-12 mm.

**The tool angle was fixed in the inverse kinematics.** The old code had `theta234 = 0` as a placeholder, so the tool was always level, and the 160 mm tool length was simply subtracted from the horizontal distance. The new `inverse_kinematics.m` takes the tool angle `phi` as an input (for example -90 to point straight down) and lets you choose elbow up or elbow down.

**Unreachable targets were not detected.** For a point out of reach, `acosd` of a number larger than 1 gives a complex angle, and Simulink stops with an error when it receives it. The new inverse kinematics answers `ok = false` with a message instead. The cases are: out of reach, too close to the base axis, a joint beyond its limit, under the floor, or the tool inside the base of the arm. `check_pose.m` holds the last three checks, so the GUI and the workspace plot use the same rules.

## Simulink model

**It no longer runs in current MATLAB.** The old model was built with the first generation of Simscape Multibody (the `mblibv1` library). MATLAB R2024b can still open it, but it cannot simulate it. The new model is imported again from SolidWorks with Simscape Multibody Link (second generation, XML plus STEP files). `simulink/make_model.m` rebuilds it from the export with one command.

**Velocity and acceleration inputs were fixed.** Each old joint actuator received position, velocity and acceleration. The velocity and the acceleration came from Constant blocks left at their default value of 1. In the new model each joint gets only its angle, and the Simulink-PS converter computes smooth derivatives from it.

**The joint angles did not mean the same thing as in the code.** Simscape measures each joint from the frames of the SolidWorks mates, not from the DH zero. The new model has a sign and an offset block for each joint (`sim_sign` and `sim_offset` in `robot_params.m`), so it takes DH angles directly. A transform sensor in the model measures the tool tip, and it agrees with `forward_kinematics.m` within 0.002 mm.

**The model name was written in two ways.** The window used `'Assem1'` in some callbacks and `'assem1'` in the inverse kinematics callback. Model names are case sensitive, so the inverse kinematics button could not reach the model.

## The window

The GUIDE window (`.fig` plus a 968 line `.m` file) was replaced by `arm_gui.m`, one file that builds the window in code. Some small bugs went away with it:

- The Default button set the first slider twice and never reset the fourth one, so the slider of theta4 stayed where it was while the model went to zero.
- After the inverse kinematics, the sliders kept their old positions.
- The same DH matrices were copied into every slider callback. The new window calls `forward_kinematics.m` instead.

Some things are new:

- the real CAD parts drawn in 3D
- a straight-line mode in the inverse kinematics panel
- a red trace of the tool tip path
- a warning when the sliders put the arm in a pose `check_pose.m` does not allow
- one button to start and stop the Simscape model, which then follows every move made in the window
- a short demo (Play demo button, or `click_to_fast_start` in the main folder) and an "About this project" tab

## New files

- `check_kinematics.m`: all the checks in one script, with the results saved in `results/kinematics_check.txt`.
- `plot_workspace.m`: the reachable area seen from the side.
- `plan_line.m` and `line_demo.m`: the tool tip draws a square on a table with straight lines.
- `docs/dh_parameters.md`: where each number of the DH table comes from.
