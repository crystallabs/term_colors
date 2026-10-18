[![CI](https://github.com/crystallabs/term_colors/actions/workflows/ci.yml/badge.svg)](https://github.com/crystallabs/term_colors/actions/workflows/ci.yml)
[![Version](https://img.shields.io/github/tag/crystallabs/term_colors.svg?maxAge=360)](https://github.com/crystallabs/term_colors/releases/latest)
[![License](https://img.shields.io/github/license/crystallabs/term_colors.svg)](https://github.com/crystallabs/term_colors/blob/master/LICENSE)

# Term Colors

Term_colors is a library containing color manipulation routines for term/console applications.

Terminal apps can use 5 different palettes:
1. Monochrome (2-color)
2. Low color (8-color)
3. ANSI / XTerm color (16-color)
4. High color (256-color)
5. TrueColor (16M-color/24-bit color)

The native color space is TrueColor: colors are parsed into, and manipulated
as, packed 24-bit `0xRRGGBB` integers (with `-1` meaning the terminal default).
Reduction to a smaller palette happens only at output time, when building the
SGR escape sequence for a terminal with a given number of colors.

## Installation

Add the dependency to `shard.yml`:

```yaml
dependencies:
  term_colors:
    github: crystallabs/term_colors
    version: ~> 2.0
```

## Available functions

All functions are instance methods of the `TermColors` module; `include` it, or
use the ready-made `TermColors::Data` class.

```
# Parses a color spec (0xRRGGBB or -1 Int, "#rgb"/"#rrggbb"/"#rgba"/"#rrggbbaa",
# color name, {r, g, b} Tuple/Array) into the native value; -1 on anything else.
  def convert(color : Int)
  def convert(color : String)
  def convert(color : Tuple | Array)
  def convert(color)

# Builds the SGR parameter fragment for one color on a terminal with `colors`
# colors (TrueColor, 256-color, or 16/8-color ANSI codes, whichever fits).
  def sgr_color(color : Int, fg : Bool, colors : Int) : String
  def sgr_color_to(io : IO, color : Int, fg : Bool, colors : Int) : Nil

# Packs/unpacks 0xRRGGBB <-> {r, g, b}, and formats as "#rrggbb".
  def rgb(r : Int, g : Int, b : Int) : Int32
  def rgb_channels(rgb : Int) : Tuple(Int32, Int32, Int32)
  def hex(rgb : Int32) : String

# Hex string conversions.
  def hex_to_int(hex : String) : Int32
  def hex_to_rgb(hex : String) : Tuple(Int32, Int32, Int32)
  def rgb_to_hex(r : Array | Tuple)
  def rgb_to_hex(r : Colorize::ColorRGB)
  def rgb_to_hex(r : Int, g : Int, b : Int)
  def to_hex2(n)
  def to_hex4(n)

# Index of the nearest color in the 256-color palette, and the distance metric.
  def match(r1 : String)
  def match(r1 : Array | Tuple)
  def match(r1 : Int, g1 : Int, b1 : Int)
  def color_distance(r1, g1, b1, r2, g2, b2)

# 256-color palette index -> 0xRRGGBB; palette index -> smaller palette index.
  def palette_to_rgb(idx : Int) : Int32
  def reduce(color, total)

# Mixing and lightness.
  def mix(c1 : Int, c2 : Int, alpha = 0.5) : Int32
  def adjust_lightness(rgb : Int32, delta : Float64) : Int32
  def lighten(rgb : Int32, amount : Float64) : Int32
  def darken(rgb : Int32, amount : Float64) : Int32
  def lighter(color : Int, factor : Int = 150) : Int32   # Qt-style, multiplicative
  def darker(color : Int, factor : Int = 200) : Int32    # Qt-style, multiplicative
  def luminance(rgb : Int32) : Float64
  def readable_on(bg : Int32, dark : Int32, light : Int32) : Int32

# HSL / HSV.
  def rgb_to_hsl(rgb : Int32) : Tuple(Float64, Float64, Float64)
  def hsl_to_rgb(h : Float64, s : Float64, l : Float64) : Int32
  def rgb_to_hsv(rgb : Int32) : Tuple(Float64, Float64, Float64)
  def hsv_i(h : Int | Float, s : Float64 = 1.0, v : Float64 = 1.0) : Int32
  def hsv(h : Int | Float, s : Float64 = 1.0, v : Float64 = 1.0) : String

# CSS rgb()/rgba() and hsl()/hsla() function bodies -> 0xRRGGBB (nil if malformed).
  def parse_rgb_function(value : String) : Int32?
  def parse_hsl_function(value : String) : Int32?
```

Tables: `Xterm` (16 ANSI colors as hex), `ColorNames` (name -> 16-color index),
`HI2RGB`/`HI2HH` (256-color index -> RGB tuple / hex), `HI2LI`/`HI2LN`
(256-color index -> 8-color index / name), `HSV_LUT` (`hsv_i(h)` for each
integer hue).

### Testing

Run `crystal spec` as usual.

### Documentation

Run `crystal docs` as usual.

## Thanks

* All the fine folks on Libera.Chat IRC channel #crystal-lang and on Crystal's Gitter channel https://gitter.im/crystal-lang/crystal

## Other projects

List of interesting or similar projects in no particular order:

Colors-related:

- https://crystal-lang.org/api/master/Colorize.html - Crystal's built-in module Colorize
- https://github.com/veelenga/rainbow-spec - Rainbow spec formatter for Crystal
- https://github.com/watzon/cor - Make working with colors in Crystal fun!
- https://github.com/icyleaf/terminal - Terminal output styling
- https://github.com/ndudnicz/selenite - Color representation convertion methods (rgb, hsv, hsl, ...) for Crystal
- https://github.com/jaydorsey/colorls-cr - Crystal toy app for colorizing LS output

Terminal-related:

- https://github.com/crystallabs/terminfo - Library for parsing standard and extended terminfo files
- https://github.com/crystallabs/tput - Low-level component for building term/console applications
- https://github.com/crystallabs/term_app - Functional term/console app environment
- https://github.com/crystallabs/crysterm - Console / terminal GUI toolkit for Crystal
