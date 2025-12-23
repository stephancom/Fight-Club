//
// Hangover Fight Club: 2IB5
// v2.1.2
//
// Open source design by stephan.com
// ChatGPT (Tinkerbell) assisted with parametric breakaway seam + engraving placement.
//
// — stephan / Cheruborg
//
// Infinite colorways. Any prescription. No responsibility.
// Sinivalkoinen suomalaisille — sisua ja turnauskestävyyttä.
//

// ============================
// FILE
// ============================
stl_file = "cavi-fight-club-v1.stl";

// ============================
// TRANSFORM
// ============================
model_scale = 0.50;   // scale BEFORE seam/engraving logic
rot_z      = 180;     // rotate about Z (affects which face becomes "south")

// ============================
// BREAKAWAY SEAM (perforated rectangles)
// ============================
// seam_x is in transformed space (post rotate/scale)
seam_x     = 45;      // seam line (in transformed space)
seam_width = 0.40;    // target gap width (~1 layer)

// seam strength tuning:
//  - smaller stitch_len => weaker seam
//  - larger open_len    => weaker seam
stitch_len = 0.8;
open_len   = 2.2;

// extents in transformed space
z_start = -5;
z_end   = 50;
y_span  = 120;

// ============================
// SOUTH-SIDE ENGRAVING
// Must be visible BEFORE opening.
// ============================
// NOTE: because rot_z=180 flips +/-Y in transformed space, "south" ends up at +Y.
// We cut from OUTSIDE toward the body so the text bites the OUTERMOST perimeter.
engrave_text  = "stephan.com";  // ONLY printed signature
engrave_size  = 4.0;            // mm (text size)
engrave_depth = 1.6;            // mm (bite into outer wall)

// These are in *POST-xform* ("what you see") coordinates
engrave_x = 23.9;
engrave_y = 29.0;
engrave_z = 6;

// Because we do engraving inside xform(), compensate translations for scale:
engrave_x_u = engrave_x / model_scale;
engrave_y_u = engrave_y / model_scale;
engrave_z_u = engrave_z / model_scale;
engrave_d_u = engrave_depth / model_scale;

// ============================
// TRANSFORM WRAPPER
// ============================
module xform() {
  rotate([0, 0, rot_z])
    scale([model_scale, model_scale, model_scale])
      children();
}

// ============================
// MODEL
// ============================
difference() {

  // --- Base model (transformed) ---
  xform()
    import(stl_file);

  // --- Perforated breakaway seam (transformed) ---
  xform()
    for (y = [-y_span : stitch_len + open_len : y_span]) {
      translate([seam_x - seam_width/2, y, z_start])
        cube([seam_width, open_len, z_end - z_start], center=false);
    }

  // --- SOUTH-side engraving (transformed), external bite ---
  // Place cutter just OUTSIDE the target face, then extrude inward along Y.
  xform()
    translate([engrave_x_u, engrave_y_u + 0.05, engrave_z_u])   // 0.05mm nudge to avoid coplanar weirdness
      rotate([-90, 180, 0])                                      // makes +Z extrude go toward -Y
        linear_extrude(height = engrave_d_u)
          text(
            engrave_text,
            size   = engrave_size / model_scale,
            halign = "center",
            valign = "center"
          );
}
