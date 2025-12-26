//
// Fight club pancakes
// v1.1
//
// Open source design by stephan.com
//
// — stephan / Cheruborg
//
// Infinite colorways. Any recipe. No responsibility.
// Sinivalkoinen suomalaisille — sisua ja turnauskestävyyttä.
//

lines = [
  ["stephan.com", "", ""],
  ["@",  "GPT",         "pancakes"],
  ["¼",  "tsp",         "salt"],
  ["1",  "c",           "flour"],
  ["2",  "tbl",         "sugar"],
  ["½",  "tsp",         "b. soda"],
  ["1",  "tsp",         "b. powder"],
  ["2",  "tsp",         "milk pwdr"],
];

row_height = 13;
thickness  = 3;

cols    = [67, 70, 55];
coljust = ["right", "left", "right"];

corner_radius = 7;
text_width    = 90;
plate_width   = text_width;
plate_height  = len(lines) * row_height;
plate_depth   = 1.5;

footer_1 = "add 1 egg, 1 tbl oil, H₂O ¼ c q.s.";

font_main = "American Typewriter:style=Condensed Bold";

module cell(row, col) {
  translate([cols[col], -row*row_height, 0])
    linear_extrude(thickness)
      text(
        lines[row][col],
        font   = font_main,
        halign = coljust[col],
        valign = "middle"
      );
}

module recipe() {
  // divider AFTER stephan.com (row index 0)
  divider_y = -((0 + 1) * row_height) - 2.5;
  translate([0, divider_y, 0])
    cube([text_width, 1, thickness]);

  // grid text
  for (i = [0 : len(lines)-1], j = [0 : 2]) {
    cell(i, j);
  }
}

module plate() {
  difference() {
    linear_extrude(plate_depth + thickness - 1)
      offset(corner_radius, $fn=24)
        square([plate_width, plate_height]);

    translate([0, 0, plate_depth])
      linear_extrude(thickness)
        offset(corner_radius - plate_depth, $fn=24)
          square([plate_width, plate_height]);
  }
}

plate();

// flip recipe into place
translate([0, 5, plate_depth - 1])
  translate([0, (len(lines)-1)*row_height, 0])
    recipe();

// footer chant
translate([48, -3, 0])
  linear_extrude(thickness)
    scale(0.5)
      text(
        footer_1,
        font   = font_main,
        halign = "center",
        valign = "middle"
      );
