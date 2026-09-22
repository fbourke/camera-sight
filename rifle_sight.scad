$fn = 32;

quick = false;

// Format: 35 mm 4-perf, Academy camera aperture (SMPTE 59), 1.372:1.
gate_w = 21.95;
gate_h = 16.00;
f_lens = 50;

// Pupil to the rear face. The only ergonomic knob: frame size and front ring both
// scale off it. 66 is what the original 2.5/3.5 ring pair already implied.
eye_relief = 66;

l_sight = 30;
th_sight = 2;
l_offset_sight = l_sight/2 - 12;

// The front opening is the frame, so it must subtend the lens' field from the eye.
// The rear opening is the same size but nearer, so it subtends more and never clips.
d_frame = eye_relief + l_sight;
w_sight = gate_w * d_frame / f_lens;
h_sight = gate_h * d_frame / f_lens;

w_crosshairs = 1;
l_crosshairs = 3;
aperture_r = 2.5;
// Sized so both rings subtend the same angle at the design eye position: they nest
// concentrically only there, which is what holds eye_relief (and the framing) honest.
aperture_f = aperture_r * (d_frame - l_crosshairs/2) / (eye_relief + l_crosshairs/2);

r_fillet = 1;
r_inner_sight = 3;
r_outer_sight = r_inner_sight + th_sight;

// Straight run of the webs under the front reticle, printing rear face down, and how
// far their edge bows in from it. Steepest overhang is 90 - a_gusset + a_concave, so
// a_concave = 0 is a straight 45 deg web and 45 puts the edge tangent to the arm.
a_gusset = 45;
a_concave = 20;

// Cold shoe foot, superseded by the Eyemo holes but kept as an option. Wall it mounts
// on: side stands the plate vertical alongside the sight, otherwise it lies flat
// underneath.
with_foot = false;
mount_side = false;

w_foot = 18.1;
l_foot = 20;
h_foot = 1.99;
r_foot = 2;

w_leg = 12.5;
h_leg = 2;

// Eyemo finder mount: two clearance holes through the side wall away from the shoe,
// one either side of the axis, the pair set l_mount back from the front face. Screws
// thread into the camera, so the holes only need to clear the 0.125" major diameter.
d_mount_screw = 0.125 * 25.4;
d_mount_hole = d_mount_screw + 0.4;
p_mount = 0.918 * 25.4;
l_mount = l_sight/3;

// Focal length engraved in the top wall, reading left to right from the eye. Bottom
// instead puts it where it reads the same way once the sight is turned over.
label_top = false;
s_label = 8;
d_label = 0.6;

echo (str ("frame ", w_sight, " x ", h_sight, " mm at ", d_frame, " mm from the eye"));
echo (str ("fov ", 2 * atan (gate_w / (2 * f_lens)), " x ", 2 * atan (gate_h / (2 * f_lens)), " deg"));
echo (str ("web overhang ", 90 - a_gusset + a_concave, " deg"));

// Sight sits on its own axis, foot swung round to whichever wall it mounts on.
translate ([0, l_sight/2 - l_offset_sight, 0])
    rotate ([90, 0, 0])
        sight (r_fillet);

if (with_foot)
    rotate ([0, mount_side ? 90 : 0, 0])
        translate ([0, 0, - (mount_side ? w_sight : h_sight)/2 - th_sight - h_foot - h_leg])
            foot ();

module foot ()
{
    h_ramp = h_foot + h_leg;

    difference ()
    {
        union ()
        {
            translate ([0, 0, h_foot])
                linear_extrude (h_leg)
                    square ([w_leg, l_foot], center = true);

            linear_extrude (h_foot)
            {
                minkowski ()
                {
                    square ([w_foot - 2* r_foot, l_foot - 2 * r_foot], center = true);
                    circle (r_foot);
                }
            }
        }

        // Lead in on the rear end. Printing rear face down that edge would otherwise
        // start in open air, so taper it to grow off the tube wall at 45 deg.
        rotate ([0, 90, 0])
            linear_extrude (w_foot + 2, center = true)
                polygon ([[1, l_foot/2 + 1],
                          [- h_ramp - 1, l_foot/2 + 1],
                          [1, l_foot/2 - h_ramp - 1]]);
    }
}

module sight (r)
{
    // Pad under the foot's leg.
    if (with_foot)
        rotate ([0, 0, mount_side ? -90 : 0])
        translate ([0, - (mount_side ? w_sight : h_sight)/2 - 0.001, l_sight/2 - l_offset_sight])
            hull ()
            {
                translate ([0, - th_sight + 0.001, 0])
                    cube ([w_leg, 0.001, l_foot], center = true);

                cube ([w_leg, 0.001, l_foot], center = true);
            }

    translate ([0, 0, l_sight - l_crosshairs])
        crosshairs (aperture_f);

    gussets (aperture_f);

    crosshairs (aperture_r);

    difference ()
    {
        sight_body (r);

        translate ([0, 0, -1])
            linear_extrude (l_sight + 2)
                minkowski ()
                {
                    square ([w_sight - 2 * r_inner_sight, h_sight - 2 * r_inner_sight], center = true);
                    circle (r = r_inner_sight);
                }

        mount_holes ();

        label ();
    }
}

// Through the side wall, in the flat between the corner rounds.
module mount_holes ()
{
    for (i = [-1, 1])
        translate ([w_sight/2 - 1, i * p_mount/2, l_sight - l_mount])
            rotate ([0, 90, 0])
                cylinder (d = d_mount_hole, h = th_sight + 2);
}

// Cut into the outer face of the top wall. Rotated so it reads left to right with
// the tops of the letters towards the front when looked down on from the eye.
module label ()
{
    rotate ([0, 0, label_top ? 0 : 180])
    translate ([0, h_sight/2 + th_sight - d_label, l_sight/2])
        rotate ([0, 0, 180])
            rotate ([90, 0, 0])
                linear_extrude (d_label + 1)
                    text (str (f_lens, " mm"), size = s_label, halign = "center", valign = "center",
                          font = "Liberation Sans:style=Bold");
}

module sight_body (rr)
{
    if (!quick)
    {
        hull ()
            for (k=[0, 1])
            {
                translate ([0, 0, rr + k * (l_sight - 2 * rr)])
                {
                    for (i=[-1, 1])
                    {
                        translate ([0, i * (h_sight/2 - r_inner_sight), 0])
                        for (j=[-1, 1])
                        {
                            translate ([j * (w_sight/2 - r_inner_sight), 0, 0])
                                rotate_extrude ()
                                {
                                    translate ([r_outer_sight - rr, 0, 0])
                                        circle (rr);
                                }
                        }
                    }
                }
            }
    }
    else
        linear_extrude (l_sight)
            {

                minkowski ()
                {
                    square ([w_sight - 2 * r_inner_sight, h_sight - 2 * r_inner_sight], center = true);
                    circle (r_outer_sight);
                }
            }
}

// Webs carrying the front reticle back to the rear face, one under each arm. They
// lie in planes through the sight axis, so they grow off the wall at a_gusset and
// sit edge on to the eye behind the arm they support.
module gussets (r)
{
    for (a = [0, 90, 180, 270])
        rotate ([0, 0, a])
            rotate ([90, 0, 0])
                linear_extrude (w_crosshairs, center = true)
                    gusset (r + w_crosshairs, a % 180 == 0 ? w_sight/2 : h_sight/2);
}

// Profile of one web, radius across and sight axis up. Squares off against the rear
// face if a_gusset is too steep to reach the wall in the length available.
module gusset (r_in, r_out)
{
    z0 = l_sight - l_crosshairs;
    dv = (r_out - r_in) * tan (a_gusset);
    c = norm ([r_out - r_in, dv]) / 2;

    difference ()
    {
        intersection ()
        {
            translate ([r_in, 0])
                square ([r_out - r_in, z0]);

            translate ([r_in, z0])
                rotate (- a_gusset)
                    square (w_sight + l_sight);
        }

        // Arc through both ends of the straight edge, bowed in towards the corner.
        if (a_concave > 0)
            let (n = [dv, r_out - r_in] / (2 * c))
                translate ([(r_in + r_out)/2, z0 - dv/2] - c / tan (a_concave) * n)
                    circle (c / sin (a_concave), $fn = 128);
    }
}

module crosshairs (r)
{
    linear_extrude (l_crosshairs)
        difference ()
        {
            union ()
            {
                square ([w_sight, w_crosshairs], center = true);
                square ([w_crosshairs, h_sight], center = true);
                circle (r + w_crosshairs);
            }
            circle (r);
        }
}
