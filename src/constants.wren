/**
 * Any common values that need to be shared across the rest of the game live here.
 */
class Constants {
  static tileSize { 24 }  // in pixels
  static mapWidth { 12 }  // in 24x24 cells
  static mapHeight { 9 }
  // Levels are defined as 4-item array with the following items:
  // 1: A multi-line string denoting the layout of the level. s = sword, d = shield, b = bow, _ = empty, x = solid block
  // 2 - 4. The number of each tile that the player is allowed to place in each level, in order of sword, shield, bow
  static levels {[
["
s_s
xxx
___
", 1, 0, 0],
["
s_b_d
s_b_d
xxxxx
_____
", 1, 1, 1],
["
s_s
b_b
d_d
xxx
___
", 1, 1, 1],
["
s_b
b_s
d_d
xxx
___
", 1, 1, 2],
[
"
__b__
__ss_
xxbxx
_xbx_
_xxx_
", 1, 0, 0],
["
__xs_sx__
__dd_dd__
xxxxxxxxx
_________
", 1, 2, 0],
["
__s_s__
__sbs__
ssdbdss
xxxxxxx
", 0, 1, 1],
["
___s___
__sxs__
_sdsds_
sdsxsds
xxxxxxx
", 5, 2, 0],
["
____d__
____d__
_xddbx_
_dsbdd_
_dsdbxd
xxxxxxx
", 1, 2, 0],
["
d___d
xb_bx
xsbsx
xxxxx
_____
", 4, 3, 1],
]}
}