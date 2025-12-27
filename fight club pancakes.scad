//
// Fight club pancakes
// v1.3 (RAISED text: union; marks rise to rim height)
//
// Open source design by stephan.com
// — stephan / Cheruborg
//

// ============================
// COLORS (preview-friendly)
// ============================
base_color = "white";   // base is always white
rim_color  = "blue";    // rim color param
ink_color  = "blue";    // raised marks color param

// ============================
// TEXT / RAISE
// ============================
font_main = "American Typewriter:style=Condensed Bold";

// ============================
// DATA (item, qty, unit)
// ============================
lines = [
  ["stephan", ".", "com"],
  ["pancakes", "@",     "GPT"    ],

  // --- WET ---
  ["",           "1",   "egg"     ],
  ["oil",        "1",   "tbl"  ],
  ["milk",       "1",   "c"    ],
  ["H₂O q.s.", "¼",   "c"    ],
  ["vanilla",    "½",   "tsp"  ],

  // divider happens AFTER this row index (0-based)
  ["flour",      "1",   "c"    ],
  ["C₆H₁₂O₆",      "2",   "tbl"  ],
  ["salt",       "¼",   "tsp"  ],
  ["b. soda",    "½",   "tsp"  ],
  ["b. pwdr",    "1",   "tsp"  ]
];

divider_after_row = 6; // after "vanilla (optional)"

// ============================
// SIZING / GEOMETRY
// ============================
row_h      = 13;

plate_t    = 2.2;   // base thickness (top deck at z=plate_t)
rim_h      = 1.2;
rim_inset  = 1.6;

margin_l   = 2;
margin_r   = 2;
margin_t   = 2;
margin_b   = 10;    // footer band

corner_r   = 7;

mark_h     = rim_h; // <-- raised marks match rim height

// column widths (content area)
col_item_w = 58;  // item block (left)
col_qty_w  = 18;  // qty block (center)
col_unit_w = 24;  // unit block (right)

gap12 = 4;        // item -> qty
gap23 = 0;        // qty -> unit

// derived dims
content_w = margin_l + col_item_w + gap12 + col_qty_w + gap23 + col_unit_w + margin_r;
plate_w   = content_w;
grid_h    = len(lines) * row_h;
plate_h   = margin_t + grid_h + margin_b;

// helpers
function row_y(i) = plate_h - margin_t - (i + 0.5) * row_h;

// x positions (lanes)
x_item_l = margin_l;
x_item_r = margin_l + col_item_w;         // item right edge
x_qty_l  = x_item_r + gap12;
x_qty_r  = x_qty_l + col_qty_w;
x_qty_c  = (x_qty_l + x_qty_r) / 2;
x_unit_l = x_qty_r + gap23;
x_unit_r = x_unit_l + col_unit_w;

// ============================
// 3D RAISED TEXT PRIMITIVE
// ============================
module raised_text(str, x, y, size=10, hal="left", val="center") {
  if (str != "") {
    translate([x, y, plate_t])              // start at top deck
      linear_extrude(mark_h)                // rise to rim top
        text(str, font=font_main, size=size, halign=hal, valign=val);
  }
}

// ============================
// PLATE BASE + RIM (color-param)
// ============================
module plate_base(base_c=base_color, rim_c=rim_color) {
  union() {
    // base slab
    color(base_c)
      linear_extrude(plate_t)
        offset(r=corner_r, $fn=32)
          square([plate_w, plate_h]);

    // raised rim (ring)
    color(rim_c)
      translate([0,0,plate_t])
        difference() {
          linear_extrude(rim_h)
            offset(r=corner_r, $fn=32)
              square([plate_w, plate_h]);

          translate([rim_inset, rim_inset, -0.01])
            linear_extrude(rim_h + 0.02)
              offset(r=max(corner_r - rim_inset, 0.01), $fn=32)
                square([plate_w - 2*rim_inset, plate_h - 2*rim_inset]);
        }
  }
}

// ============================
// RULES + DIVIDER (RAISED)
// ============================
header_after_row = 1; // underline AFTER "pancakes @ GPT" (0-based)

module header_rule() {
  yb = row_y(header_after_row) - row_h/2;
  translate([margin_l, yb, plate_t])
    cube([plate_w - margin_l - margin_r, 1.0, mark_h]);
}
module divider_rule() {
  yb = row_y(divider_after_row) - row_h/2;

  translate([margin_l, yb, plate_t])
    cube([plate_w - margin_l - margin_r, 1.0, mark_h]);

  // small, lowercase labels, tucked left, non-overlapping
  label_x = max(margin_l, rim_inset) + 0.8;
  raised_text("wet", label_x, yb + 1.2, size=5, hal="left", val="bottom");
  raised_text("dry", label_x, yb - 1.2, size=5, hal="left", val="top");
}

// ============================
// GRID (item | qty | unit) (RAISED)
// ============================
module grid_text() {
  for (i = [0 : len(lines)-1]) {
    y = row_y(i);

    // item: right-just within item column
    raised_text(lines[i][0], x_item_r, y, size=10, hal="right");

    // qty: centered
    raised_text(lines[i][1], x_qty_c, y, size=10, hal="center");

    // unit: left-just so it reads like a word
    raised_text(lines[i][2], x_unit_l, y, size=10, hal="left");
  }
}

// ============================
// FOOTER (RAISED)
// ============================
module footer() {
  cx = plate_w/2;

  safe_bottom = rim_inset + 2.0;
  safe_top    = margin_b - 2.0;
  footer_y    = safe_bottom + (safe_top - safe_bottom) * 0.55;

  raised_text("add berries / chips / etc", cx, footer_y, size=6, hal="center", val="center");
}

// ============================
// BUILD (UNION)
// ============================
union() {
  plate_base(base_color, rim_color);

  color(ink_color) {
    header_rule();
    divider_rule();
    grid_text();
    footer();
  }
}
