# Color-related functions for term/console applications.
#
# Terminal apps can use 5 different palettes:
#     1. Monochrome (2-color)
#     2. Low color (8-color)
#     3. ANSI / XTerm color (16-color)
#     4. High color (256-color)
#     5. TrueColor (16M-color/24-bit color)
#
# This module provides color-related functions for the first 4 types. TrueColor is not supported yet.
#
# TODO: Add TrueColor functionality
module TermColors
  VERSION = "1.0.1"

  # Storage cache for `#match` method
  CACHE_MATCH = {} of Int32 => Int32

  # Storage cache for `#blend` method
  CACHE_BLEND = {} of Int32 => Int32

  # 16 XTerm Colors.
  #
  # (Values were taken from X11 sources, mapped to RGB, and then converted to these hex values.)
  Xterm = {
    "#000000", # black
    "#cd0000", # red3
    "#00cd00", # green3
    "#cdcd00", # yellow3
    "#0000ee", # blue2
    "#cd00cd", # magenta3
    "#00cdcd", # cyan3
    "#e5e5e5", # gray90
    "#7f7f7f", # gray50
    "#ff0000", # red
    "#00ff00", # green
    "#ffff00", # yellow
    "#5c5cff", # rgb:5c/5c/ff
    "#ff00ff", # magenta
    "#00ffff", # cyan
    "#ffffff", # white
  }

  # Mapping of notable color names to 16 color indices.
  ColorNames = {
    # XXX see if eventually strings can be replaced with symbols, here and elsewhere in similar case
    # special
    "default"          =>   -1,
    "normal"           =>   -1,
    "bg"               =>   -1,
    "fg"               =>   -1,
    # normal
    "black"            =>   0,
    "red"              =>   1,
    "green"            =>   2,
    "yellow"           =>   3,
    "blue"             =>   4,
    "magenta"          =>   5,
    "cyan"             =>   6,
    "white"            =>   7,
    # light
    "lightblack"       =>   8,
    "lightred"         =>   9,
    "lightgreen"       =>   10,
    "lightyellow"      =>   11,
    "lightblue"        =>   12,
    "lightmagenta"     =>   13,
    "lightcyan"        =>   14,
    "lightwhite"       =>   15,
    # bright
    "brightblack"      =>   8,
    "brightred"        =>   9,
    "brightgreen"      =>   10,
    "brightyellow"     =>   11,
    "brightblue"       =>   12,
    "brightmagenta"    =>   13,
    "brightcyan"       =>   14,
    "brightwhite"      =>   15,
    # alternate spellings
    "grey"             =>   8,
    "gray"             =>   8,
    "lightgrey"        =>   7,
    "lightgray"        =>   7,
    "brightgrey"       =>   7,
    "brightgray"       =>   7,
  }

  # Mapping of high color (256) indices to low color (8) indices.
  # Array indices are color indices in 256-color palette; contained values are corresponding color indices in 8-color palette.
  # If the list needs to be regenerated or updated, please see `bin/generate_colors.rb` which was used to create it.
  HI2LI = [0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7, 0, 4, 4, 4, 4, 4, 2, 6, 4, 4, 4, 4, 2, 2, 6, 4, 4, 4, 2, 2, 2, 6, 4, 4, 2, 2, 2, 2, 6, 4, 2, 2, 2, 2, 2, 6, 1, 5, 4, 4, 4, 4, 3, 0, 4, 4, 4, 4, 2, 2, 6, 4, 4, 4, 2, 2, 2, 6, 4, 4, 2, 2, 2, 2, 6, 4, 2, 2, 2, 2, 2, 6, 1, 1, 5, 4, 4, 4, 1, 1, 5, 4, 4, 4, 3, 3, 0, 4, 4, 4, 2, 2, 2, 6, 4, 4, 2, 2, 2, 2, 6, 4, 2, 2, 2, 2, 2, 6, 1, 1, 1, 5, 4, 4, 1, 1, 1, 5, 4, 4, 1, 1, 1, 5, 4, 4, 3, 3, 3, 7, 4, 4, 2, 2, 2, 2, 6, 4, 2, 2, 2, 2, 2, 6, 1, 1, 1, 1, 5, 4, 1, 1, 1, 1, 5, 4, 1, 1, 1, 1, 5, 4, 1, 1, 1, 1, 5, 4, 3, 3, 3, 3, 7, 4, 2, 2, 2, 2, 2, 6, 1, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 5, 3, 3, 3, 3, 3, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7]

  # Mapping of high color (256) indices to low color (8) names.
  # Array indices are color indices in 256-color palette; contained values are corresponding color names in 8-color palette.
  # If the list needs to be regenerated or updated, please see `bin/generate_colors.rb` which was used to create it.
  HI2LN = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white", "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white", "black", "blue", "blue", "blue", "blue", "blue", "green", "cyan", "blue", "blue", "blue", "blue", "green", "green", "cyan", "blue", "blue", "blue", "green", "green", "green", "cyan", "blue", "blue", "green", "green", "green", "green", "cyan", "blue", "green", "green", "green", "green", "green", "cyan", "red", "magenta", "blue", "blue", "blue", "blue", "yellow", "black", "blue", "blue", "blue", "blue", "green", "green", "cyan", "blue", "blue", "blue", "green", "green", "green", "cyan", "blue", "blue", "green", "green", "green", "green", "cyan", "blue", "green", "green", "green", "green", "green", "cyan", "red", "red", "magenta", "blue", "blue", "blue", "red", "red", "magenta", "blue", "blue", "blue", "yellow", "yellow", "black", "blue", "blue", "blue", "green", "green", "green", "cyan", "blue", "blue", "green", "green", "green", "green", "cyan", "blue", "green", "green", "green", "green", "green", "cyan", "red", "red", "red", "magenta", "blue", "blue", "red", "red", "red", "magenta", "blue", "blue", "red", "red", "red", "magenta", "blue", "blue", "yellow", "yellow", "yellow", "white", "blue", "blue", "green", "green", "green", "green", "cyan", "blue", "green", "green", "green", "green", "green", "cyan", "red", "red", "red", "red", "magenta", "blue", "red", "red", "red", "red", "magenta", "blue", "red", "red", "red", "red", "magenta", "blue", "red", "red", "red", "red", "magenta", "blue", "yellow", "yellow", "yellow", "yellow", "white", "blue", "green", "green", "green", "green", "green", "cyan", "red", "red", "red", "red", "red", "magenta", "red", "red", "red", "red", "red", "magenta", "red", "red", "red", "red", "red", "magenta", "red", "red", "red", "red", "red", "magenta", "red", "red", "red", "red", "red", "magenta", "yellow", "yellow", "yellow", "yellow", "yellow", "white", "black", "black", "black", "black", "black", "black", "black", "black", "black", "black", "black", "black", "white", "white", "white", "white", "white", "white", "white", "white", "white", "white", "white", "white"]

  # Mapping of high color (256) indices to hex color values.
  # Ported from the xterm color generation script. Assumes xterm defaults.
  # Array indices are color indices in 256-color palette; contained values are corresponding hex color values.
  # If the list needs to be regenerated or updated, please see `bin/generate_colors_2.js` which was used to create it.
  HI2HH = [ "#000000", "#cd0000", "#00cd00", "#cdcd00", "#0000ee", "#cd00cd", "#00cdcd", "#e5e5e5", "#7f7f7f", "#ff0000", "#00ff00", "#ffff00", "#5c5cff", "#ff00ff", "#00ffff", "#ffffff", "#000000", "#00005f", "#000087", "#0000af", "#0000d7", "#0000ff", "#005f00", "#005f5f", "#005f87", "#005faf", "#005fd7", "#005fff", "#008700", "#00875f", "#008787", "#0087af", "#0087d7", "#0087ff", "#00af00", "#00af5f", "#00af87", "#00afaf", "#00afd7", "#00afff", "#00d700", "#00d75f", "#00d787", "#00d7af", "#00d7d7", "#00d7ff", "#00ff00", "#00ff5f", "#00ff87", "#00ffaf", "#00ffd7", "#00ffff", "#5f0000", "#5f005f", "#5f0087", "#5f00af", "#5f00d7", "#5f00ff", "#5f5f00", "#5f5f5f", "#5f5f87", "#5f5faf", "#5f5fd7", "#5f5fff", "#5f8700", "#5f875f", "#5f8787", "#5f87af", "#5f87d7", "#5f87ff", "#5faf00", "#5faf5f", "#5faf87", "#5fafaf", "#5fafd7", "#5fafff", "#5fd700", "#5fd75f", "#5fd787", "#5fd7af", "#5fd7d7", "#5fd7ff", "#5fff00", "#5fff5f", "#5fff87", "#5fffaf", "#5fffd7", "#5fffff", "#870000", "#87005f", "#870087", "#8700af", "#8700d7", "#8700ff", "#875f00", "#875f5f", "#875f87", "#875faf", "#875fd7", "#875fff", "#878700", "#87875f", "#878787", "#8787af", "#8787d7", "#8787ff", "#87af00", "#87af5f", "#87af87", "#87afaf", "#87afd7", "#87afff", "#87d700", "#87d75f", "#87d787", "#87d7af", "#87d7d7", "#87d7ff", "#87ff00", "#87ff5f", "#87ff87", "#87ffaf", "#87ffd7", "#87ffff", "#af0000", "#af005f", "#af0087", "#af00af", "#af00d7", "#af00ff", "#af5f00", "#af5f5f", "#af5f87", "#af5faf", "#af5fd7", "#af5fff", "#af8700", "#af875f", "#af8787", "#af87af", "#af87d7", "#af87ff", "#afaf00", "#afaf5f", "#afaf87", "#afafaf", "#afafd7", "#afafff", "#afd700", "#afd75f", "#afd787", "#afd7af", "#afd7d7", "#afd7ff", "#afff00", "#afff5f", "#afff87", "#afffaf", "#afffd7", "#afffff", "#d70000", "#d7005f", "#d70087", "#d700af", "#d700d7", "#d700ff", "#d75f00", "#d75f5f", "#d75f87", "#d75faf", "#d75fd7", "#d75fff", "#d78700", "#d7875f", "#d78787", "#d787af", "#d787d7", "#d787ff", "#d7af00", "#d7af5f", "#d7af87", "#d7afaf", "#d7afd7", "#d7afff", "#d7d700", "#d7d75f", "#d7d787", "#d7d7af", "#d7d7d7", "#d7d7ff", "#d7ff00", "#d7ff5f", "#d7ff87", "#d7ffaf", "#d7ffd7", "#d7ffff", "#ff0000", "#ff005f", "#ff0087", "#ff00af", "#ff00d7", "#ff00ff", "#ff5f00", "#ff5f5f", "#ff5f87", "#ff5faf", "#ff5fd7", "#ff5fff", "#ff8700", "#ff875f", "#ff8787", "#ff87af", "#ff87d7", "#ff87ff", "#ffaf00", "#ffaf5f", "#ffaf87", "#ffafaf", "#ffafd7", "#ffafff", "#ffd700", "#ffd75f", "#ffd787", "#ffd7af", "#ffd7d7", "#ffd7ff", "#ffff00", "#ffff5f", "#ffff87", "#ffffaf", "#ffffd7", "#ffffff", "#080808", "#121212", "#1c1c1c", "#262626", "#303030", "#3a3a3a", "#444444", "#4e4e4e", "#585858", "#626262", "#6c6c6c", "#767676", "#808080", "#8a8a8a", "#949494", "#9e9e9e", "#a8a8a8", "#b2b2b2", "#bcbcbc", "#c6c6c6", "#d0d0d0", "#dadada", "#e4e4e4", "#eeeeee", ]

  # Mapping of high color (256) indices to RGB color values.
  # Ported from the xterm color generation script. Assumes xterm defaults.
  # Array indices are color indices in 256-color palette; contained values are corresponding RGB color values.
  # If the list needs to be regenerated or updated, please see `bin/generate_colors_2.js` which was used to create it.
  HI2RGB = [ {0,0,0}, {205,0,0}, {0,205,0}, {205,205,0}, {0,0,238}, {205,0,205}, {0,205,205}, {229,229,229}, {127,127,127}, {255,0,0}, {0,255,0}, {255,255,0}, {92,92,255}, {255,0,255}, {0,255,255}, {255,255,255}, {0,0,0}, {0,0,95}, {0,0,135}, {0,0,175}, {0,0,215}, {0,0,255}, {0,95,0}, {0,95,95}, {0,95,135}, {0,95,175}, {0,95,215}, {0,95,255}, {0,135,0}, {0,135,95}, {0,135,135}, {0,135,175}, {0,135,215}, {0,135,255}, {0,175,0}, {0,175,95}, {0,175,135}, {0,175,175}, {0,175,215}, {0,175,255}, {0,215,0}, {0,215,95}, {0,215,135}, {0,215,175}, {0,215,215}, {0,215,255}, {0,255,0}, {0,255,95}, {0,255,135}, {0,255,175}, {0,255,215}, {0,255,255}, {95,0,0}, {95,0,95}, {95,0,135}, {95,0,175}, {95,0,215}, {95,0,255}, {95,95,0}, {95,95,95}, {95,95,135}, {95,95,175}, {95,95,215}, {95,95,255}, {95,135,0}, {95,135,95}, {95,135,135}, {95,135,175}, {95,135,215}, {95,135,255}, {95,175,0}, {95,175,95}, {95,175,135}, {95,175,175}, {95,175,215}, {95,175,255}, {95,215,0}, {95,215,95}, {95,215,135}, {95,215,175}, {95,215,215}, {95,215,255}, {95,255,0}, {95,255,95}, {95,255,135}, {95,255,175}, {95,255,215}, {95,255,255}, {135,0,0}, {135,0,95}, {135,0,135}, {135,0,175}, {135,0,215}, {135,0,255}, {135,95,0}, {135,95,95}, {135,95,135}, {135,95,175}, {135,95,215}, {135,95,255}, {135,135,0}, {135,135,95}, {135,135,135}, {135,135,175}, {135,135,215}, {135,135,255}, {135,175,0}, {135,175,95}, {135,175,135}, {135,175,175}, {135,175,215}, {135,175,255}, {135,215,0}, {135,215,95}, {135,215,135}, {135,215,175}, {135,215,215}, {135,215,255}, {135,255,0}, {135,255,95}, {135,255,135}, {135,255,175}, {135,255,215}, {135,255,255}, {175,0,0}, {175,0,95}, {175,0,135}, {175,0,175}, {175,0,215}, {175,0,255}, {175,95,0}, {175,95,95}, {175,95,135}, {175,95,175}, {175,95,215}, {175,95,255}, {175,135,0}, {175,135,95}, {175,135,135}, {175,135,175}, {175,135,215}, {175,135,255}, {175,175,0}, {175,175,95}, {175,175,135}, {175,175,175}, {175,175,215}, {175,175,255}, {175,215,0}, {175,215,95}, {175,215,135}, {175,215,175}, {175,215,215}, {175,215,255}, {175,255,0}, {175,255,95}, {175,255,135}, {175,255,175}, {175,255,215}, {175,255,255}, {215,0,0}, {215,0,95}, {215,0,135}, {215,0,175}, {215,0,215}, {215,0,255}, {215,95,0}, {215,95,95}, {215,95,135}, {215,95,175}, {215,95,215}, {215,95,255}, {215,135,0}, {215,135,95}, {215,135,135}, {215,135,175}, {215,135,215}, {215,135,255}, {215,175,0}, {215,175,95}, {215,175,135}, {215,175,175}, {215,175,215}, {215,175,255}, {215,215,0}, {215,215,95}, {215,215,135}, {215,215,175}, {215,215,215}, {215,215,255}, {215,255,0}, {215,255,95}, {215,255,135}, {215,255,175}, {215,255,215}, {215,255,255}, {255,0,0}, {255,0,95}, {255,0,135}, {255,0,175}, {255,0,215}, {255,0,255}, {255,95,0}, {255,95,95}, {255,95,135}, {255,95,175}, {255,95,215}, {255,95,255}, {255,135,0}, {255,135,95}, {255,135,135}, {255,135,175}, {255,135,215}, {255,135,255}, {255,175,0}, {255,175,95}, {255,175,135}, {255,175,175}, {255,175,215}, {255,175,255}, {255,215,0}, {255,215,95}, {255,215,135}, {255,215,175}, {255,215,215}, {255,215,255}, {255,255,0}, {255,255,95}, {255,255,135}, {255,255,175}, {255,255,215}, {255,255,255}, {8,8,8}, {18,18,18}, {28,28,28}, {38,38,38}, {48,48,48}, {58,58,58}, {68,68,68}, {78,78,78}, {88,88,88}, {98,98,98}, {108,108,108}, {118,118,118}, {128,128,128}, {138,138,138}, {148,148,148}, {158,158,158}, {168,168,168}, {178,178,178}, {188,188,188}, {198,198,198}, {208,208,208}, {218,218,218}, {228,228,228}, {238,238,238}, ]

  # Takes color value and returns index of the nearest/closest matching color in the current palette.
  def match( r1 : String)
    hex = r1
    if (hex[0] != '#')
      raise "Color value must start with '#'"
    end
    hex = hex_to_rgb(hex)
    r1 = hex[0]; g1 = hex[1]; b1 = hex[2]
    match r1, g1, b1
  end
  # :ditto:
  def match( r1 : Array)
    b1 = r1[2]; g1 = r1[1]; r1 = r1[0]
    match r1, g1, b1
  end
  # :ditto:
  def match( r1 : Tuple)
    match *r1
  end
  # :ditto:
  def match(r1 : Int, g1 : Int, b1 : Int)
    hash : Int32 = (r1 << 16) | (g1 << 8) | b1

    if CACHE_MATCH.has_key? hash
      return CACHE_MATCH[hash]
    end

    #ldiff = Float64::INFINITY
    ldiff = Int32::MAX # Make it match type of `CACHE_MATCH` above.
    li = -1
    i = 0

    while i < HI2RGB.size
      c = HI2RGB[i]
      r2 = c[0]
      g2 = c[1]
      b2 = c[2]

      diff = color_distance(r1, g1, b1, r2, g2, b2)

      if (diff==0)
        li = i
        break
      end

      if (diff < ldiff)
        ldiff = diff
        li = i
      end
      i+= 1
    end

    CACHE_MATCH[hash] = li
  end

  # Converts RGB to hex color value (#color)
  def rgb_to_hex(r : Array)
    rgb_to_hex r[0], r[1], r[2]
  end
  # :ditto:
  def rgb_to_hex(r : Colorize::ColorRGB)
    rgb_to_hex r.red, r.green, r.blue
  end
  # :ditto:
  def rgb_to_hex(r, g, b)
    "#" + to_hex2(r) + to_hex2(g) + to_hex2(b)
  end

  # Converts number to hex value with 2 places.
  def to_hex2(n)
    n = n.to_s 16
    if (n.size < 2)
      n = "0" + n
    end
    n
  end

  # Converts number to hex value with 4 places.
  def to_hex4(n)
    n = n.to_s 16
    while (n.size < 4)
      n = "0" + n
    end
    n
  end

  # Converts hex color value (#col or #color) to {r,g,b}.
  def hex_to_rgb(hex : String)
    if hex.size == 4
      # Converts #abc into #aabbcc
      hex = hex[0].to_s + hex[1] + hex[1] + hex[2] + hex[2] + hex[3] + hex[3]
    end
    col = hex[1..-1].to_i 16
    r = (col >> 16) & 0xff
    g = (col >> 8) & 0xff
    b = col & 0xff
    {r, g, b}
  end

  # Finds color similarity.
  # As it happens, comparing how similar two colors are is really hard. Here is
  # one of the simplest solutions, which doesn't require conversion to another
  # color space, posted on stackoverflow{1}. Maybe someone better at math can
  # propose a superior solution.
  # {1} http:#stackoverflow.com/questions/1633828
  def color_distance(r1, g1, b1, r2, g2, b2)
    ((30 * (r1 - r2))**2) + ((59 * (g1 - g2))**2) + ((11 * (b1 - b2))**2)
  end

  # Mixes colors.
  # Mixing is done in the context of current palette and colors must exist in it.
  # This might work well enough for terminal's colors: treat RGB as XYZ in a
  # 3-dimensional space and go midway between the two points.
  def mix_colors(c1, c2, alpha=0.5)
    #if (c1 == 0x1ff) return c1
    #if (c2 == 0x1ff) return c1
    c1 = 0 if c1 == 0x1ff
    c2 = 0 if c2 == 0x1ff

    c1 = HI2RGB[c1]
    r1 = c1[0]
    g1 = c1[1]
    b1 = c1[2]

    c2 = HI2RGB[c2]
    r2 = c2[0]
    g2 = c2[1]
    b2 = c2[2]

    r1 += ((r2 - r1) * alpha).to_i
    g1 += ((g2 - g1) * alpha).to_i
    b1 += ((b2 - b1) * alpha).to_i

    match r1, g1, b1
  end

  # Blends two attributes together, taking into account alpha/transparency value.
  # Both the background and the foreground attributes are blended.
  def blend(attr=0, attr2=0, alpha : Float | Int = 0.5)
    # First blend background
    bg = attr & 0x1ff
    if !attr2.nil?
      bg2 = attr2 & 0x1ff
      if (bg == 0x1ff);  bg = 0 end
      if (bg2 == 0x1ff); bg2 = 0 end
      bg = mix_colors(bg, bg2, alpha)
    else
      bg = _round(bg)
    end
    attr &= ~0x1ff
    attr |= bg

    # Then blend foreground
    fg = (attr >> 9) & 0x1ff
    if !attr2.nil?
      fg2 = (attr2 >> 9) & 0x1ff
      # 0, 7, 188, 231, 251
      if fg == 0x1ff
        # workaround
        fg = 248
      else
        if (fg == 0x1ff);  fg = 7 end
        if (fg2 == 0x1ff); fg2 = 7 end
        fg = mix_colors(fg, fg2, alpha)
      end
    else
      fg = _round fg
    end
    attr &= ~(0x1ff << 9)
    attr |= fg << 9

    attr
  end

  def _round(c)
    if CACHE_BLEND[c]?
      c = CACHE_BLEND[c]
    # } else if (bg < 8) {
    #   bg += 8
    elsif (c >= 8) && (c <= 15)
      c -= 8
    else
      if name = HI2LN[c]?
        i= -1
        while i < HI2LN.size
          i += 1
          if (name == HI2LN[i]) && (i != c)
            c2 = HI2RGB[c]
            nc = HI2RGB[i]
            if (nc[0] + nc[1] + nc[2]) < (c2[0] + c2[1] + c2[2])
              CACHE_BLEND[c] = i
              c = i
              break
            end
          end
        end
      end
    end
    c
  end

  # Converts color into lower/smaller color space.
  #
  # ```
  # reduce(color, @tput.colors)
  # ```
  def reduce(color, total)
    if(color >= 16 && total <= 16)
      color = HI2LI[color]
    elsif(color >= 8 && total <= 8)
      color -= 8
    elsif(color >= 2 && total <= 2)
      color %= 2
    end
    color
  end

  # Converts color to index in the current palette.
  def convert(color : Int)
    return color != -1 ? color : 0x1ff
  end
  # :ditto:
  def convert(color : String)
    #color = color.gsub(/{\- }/, "")
    color = color.gsub(/[\- ]/, "")
    color = ColorNames[color]? || match(color)
    convert color
  end
  # :ditto:
  def convert(color : Array)
    convert match color
  end
  # :nodoc:
  def convert(color)
    convert -1
  end

  # Represents Colors class.
  #
  # This class should be used when a class is preferred
  # over using a module.
  class Data
    include ::TermColors
  end
end
