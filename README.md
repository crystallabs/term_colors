[![Build Status](https://travis-ci.com/crystallabs/term_colors.svg?branch=master)](https://travis-ci.com/crystallabs/term_colors)
[![Version](https://img.shields.io/github/tag/crystallabs/term_colors.svg?maxAge=360)](https://github.com/crystallabs/term_colors/releases/latest)
[![License](https://img.shields.io/github/license/crystallabs/term_colors.svg)](https://github.com/crystallabs/term_colors/blob/master/LICENSE)

# Term_colors

Term_colors is a library containing color manipulation routines for term/console applications.

It deals with color manipulation/conversion functions, not with the output to the terminal.

## Installation

Add the dependency to `shard.yml`:

```yaml
dependencies:
  term_colors:
    github: crystallabs/term_colors
    version: 0.1.1
```

## Available functions

```
# Takes color value and returns index of the nearest/closest
# matching color in the current palette.
  def match( r1 : String)
  def match( r1 : Array)
  def match( r1 : Tuple)
  def match(r1, g1, b1)

# Calculates color distance.
  def color_distance(r1, g1, b1, r2, g2, b2)

# Converts RGB to hex color value (#color).
  def rgb_to_hex(r : Array)
  def rgb_to_hex(r : Colorize::ColorRGB)
  def rgb_to_hex(r, g, b)

# Converts number to hex value with 2 places.
  def to_hex2(n)

# Converts number to hex value with 4 places.
  def to_hex4(n)

# Converts hex color value (#col or #color) to {r,g,b}.
  def hex_to_rgb(hex : String)

# Mixes colors.
  def mix_colors(c1, c2, alpha=0.5)

# Blends two attributes together, taking into account alpha/transparency value.
  def blend(attr, attr2, alpha)

# Converts color into lower/smaller color space.
  def reduce(color, total)

# Converts color to index in the current palette.
  def convert(color : Int)
  def convert(color : String)
  def convert(color : Array)
  def convert(color)
```

### Testing

Run `crystal spec` as usual.

### Documentation

Run `crystal docs` as usual.

## Thanks

* All the fine folks on FreeNode IRC channel #crystal-lang and on Crystal's Gitter channel https://gitter.im/crystal-lang/crystal

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
