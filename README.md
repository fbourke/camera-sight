# camera-sight

A 3D-printed open-frame "rifle sight" for a 35 mm cine camera, written in
[OpenSCAD](https://openscad.org/). You look through the rear ring at the front
ring; when the two rings nest concentrically your eye is at the design eye
relief, and the front opening then frames exactly what the lens sees.

The frame is derived from the camera gate (35 mm 4-perf Academy, SMPTE 59) and
the lens focal length, so one file covers every lens: change `f_lens` and
export.

## Mounting

Two clearance holes on the side wall take the finder screws of a Bell & Howell
Eyemo: 0.125" screws on 0.918" centres, set a third of the way back from the
front face. The screws thread into the camera; the sight only needs to clear
them.

The original cold-shoe foot is still in the file behind `with_foot` if you
want it instead.

## Usage

Open `rifle_sight.scad` and set the knobs at the top of the file:

| Parameter | What it does |
| --- | --- |
| `f_lens` | Lens focal length in mm. Sets the frame size and the engraved label. |
| `eye_relief` | Distance from your pupil to the rear face, mm. |
| `with_foot`, `mount_side` | Add the cold-shoe foot, and whether it stands beside or lies under the sight. |
| `label_top` | Engrave the focal length on the top wall (`true`) or the bottom (`false`). |
| `quick` | Skip the filleted body for a faster preview. |

Then render (F6) and export an STL. From the command line:

```sh
openscad -D f_lens=50 -o rifle_sight_50mm.stl rifle_sight.scad
```

The console echoes the frame size and the field of view it subtends, which is
a handy sanity check against the lens.

## Printing

Print with the rear (eye) face down. The webs carrying the front reticle are
angled so their steepest overhang is `90 - a_gusset + a_concave` degrees (65
by default), which prints without support.

Ready-made STLs for 28, 35 and 50 mm lenses are in the repo.
