# The original course version

These are the files of the first version, kept as they were handed in, so the old and the new version can be compared. The only change: the window showed my email address, and in this copy that label is blank (for this, `untitledcontroller.fig` was opened and saved again with MATLAB R2024b). The SolidWorks parts and the STL meshes of that version are the same files as in `cad/` and `cad/stl/`, so they are not copied here again.

| file | what it is |
|---|---|
| `untitledcontroller.m` | the GUIDE window: sliders for the joints, forward and inverse kinematics |
| `untitledcontroller.fig` | the layout of that window (open it with `untitledcontroller` or in GUIDE) |
| `Assem1.slx` | the Simscape model, first generation (Simscape Multibody Link 5.0, `mblibv1` library) |
| `Assem1.xml` | the SolidWorks export that `Assem1.slx` was built from |

## Opening them today

MATLAB R2024b still opens `Assem1.slx`, but it cannot simulate it, because the first generation library was removed from Simscape Multibody. `smimport` also refuses this XML, since it only reads the second generation format. That is why the new model in `simulink/` was exported again from SolidWorks.

The Persian comments in `untitledcontroller.m` are saved in the Windows-1256 code page, so GitHub and most editors show them as strange characters. The letter "ی" was already lost when the file was saved (it shows as "?"), because that code page does not have it.

## Known problems, and where they are

| problem | where |
|---|---|
| link lengths `a1 = 486`, `a3 = 420.17`, `a4 = 160` (the CAD gives 496, 451.38 and 195), and no 10 mm side offset | `untitledcontroller.m` lines 83-86, copied at 253, 333, 420 and 902 |
| `T1` is not a rotation matrix (determinant `-cos(2*theta1)`). It mirrors heights about the shoulder | line 110, copied at 278, 356 and 444 |
| the inverse kinematics keeps the tool level (`theta234 = 0`) and subtracts the tool length from the horizontal distance | lines 916 and 929 |
| no check for unreachable points: `acosd` of a number above 1 gives a complex angle, and `set_param` then fails | line 923 |
| model name written as `'assem1'`, while the file is `Assem1.slx` | line 948 |
| after the inverse kinematics only the text fields are updated, not the sliders | lines 932-945 |
| the Default button sets `slider0` twice and never resets the fourth slider | lines 228-231 |
| velocity and acceleration of every joint actuator come from Constant blocks left at 1 | `Assem1.slx` |

Because of the mirrored `T1`, the inverse kinematics and the forward kinematics of this version disagree. Asking for a height `z` and putting the answer back into the forward kinematics gives `972 - z`.

[../../docs/changes_from_course_project.md](../../docs/changes_from_course_project.md) explains how the new version fixes each of these.
