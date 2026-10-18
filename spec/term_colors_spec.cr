require "./spec_helper"

class ClsColors
  include TermColors
end

describe TermColors do
  it "knows Xterm colors" do
    TermColors::Xterm[0].should eq "#000000"
    TermColors::Xterm[-1].should eq "#ffffff"
    TermColors::Xterm.size.should eq 16
  end
  it "knows color names" do
    TermColors::ColorNames["brightwhite"].should eq 15
    TermColors::ColorNames["fg"].should eq -1
    TermColors::ColorNames.size.should eq 34
  end
  it "knows color distance" do
    obj = ClsColors.new
    r = obj.color_distance(0, 0, 0, 255, 255, 255)
    r.should eq 292742550
    r = obj.color_distance(255, 255, 255, 0, 0, 0)
    r.should eq 292742550
    r = obj.color_distance(10, 12, 190, 117, 34, 112)
    r.should eq 12725068
  end
  it "can convert rgb2hex, hex2rgb" do
    obj = ClsColors.new
    obj.rgb_to_hex([0, 0, 0]).should eq "#000000"
    obj.rgb_to_hex(255, 255, 255).should eq "#ffffff"
    obj.rgb_to_hex(12, 219, 114).should eq "#0cdb72"
    obj.rgb_to_hex(Colorize::ColorRGB.new 12, 219, 114).should eq "#0cdb72"
    # Tuple input is accepted (mirrors `match`/`convert`), so `rgb_to_hex`
    # composes with `hex_to_rgb` (its inverse), which returns a Tuple.
    obj.rgb_to_hex({12, 219, 114}).should eq "#0cdb72"
    obj.rgb_to_hex(obj.hex_to_rgb("#0cdb72")).should eq "#0cdb72"
    obj.hex_to_rgb("#fff").should eq Tuple.new(255, 255, 255)
    obj.hex_to_rgb("#000000").should eq({0, 0, 0})
    obj.hex_to_rgb("#23ce9a").should eq({35, 206, 154})
    obj.hex_to_rgb("#ABC").should eq({0xaa, 0xbb, 0xcc})
    obj.hex_to_rgb("#1a2").should eq({0x11, 0xaa, 0x22})
  end
  it "has ccolors and ncolors" do
    TermColors::HI2LN[0].should eq "black"
    TermColors::HI2LN[208].should eq "red"
    TermColors::HI2LN[255].should eq "white"
    TermColors::HI2LN.size.should eq 256

    TermColors::HI2LI[0].should eq 0
    TermColors::HI2LI[255].should eq 7
    TermColors::HI2LI.size.should eq 256
  end
  it "has colors and vcolors" do
    TermColors::HI2HH[0].should eq "#000000"
    TermColors::HI2HH[208].should eq "#ff8700"
    TermColors::HI2HH[255].should eq "#eeeeee"
    TermColors::HI2HH.size.should eq 256

    TermColors::HI2RGB[0].should eq Tuple.new(0, 0, 0)
    TermColors::HI2RGB[255].should eq Tuple.new(238, 238, 238)
    TermColors::HI2RGB.size.should eq 256
  end
  it "can reduce" do
    obj = ClsColors.new
    r = obj.reduce 98, 8
    r.should eq 4
    r = obj.reduce 98, 16
    r.should eq 4
    r = obj.reduce 98, 2
    r.should eq 0
  end
  it "can find nearest colors" do
    obj = ClsColors.new
    r = obj.match(229, 229, 229)
    r.should eq 7
    r = obj.match(Tuple.new(229, 229, 229))
    r.should eq 7
    r = obj.match([229, 229, 229])
    r.should eq 7
    r = obj.match([229, 229, 230])
    r.should eq 7
    r = obj.match([229, 229, 235])
    r.should eq 7
    obj.match("#e5e5e5").should eq 7
    obj.match("#fff").should eq 15
    expect_raises(Exception, /must start with/) { obj.match("ffffff") }
    expect_raises(Exception, /must start with/) { obj.match("") }
  end
  it "accepts any integer width where `Int` is declared" do
    obj = ClsColors.new
    # Packed colors and channels typed `Int` must work for every integer type,
    # not just Int32: wider ones are narrowed, narrow ones (UInt8) widened
    # before shifting so nothing overflows.
    obj.rgb_channels(0xff8800_i64).should eq({255, 136, 0})
    obj.rgb_channels(0xff8800_u32).should eq({255, 136, 0})
    obj.mix(0xffffff_i64, 0_i64, 0.5).should eq 0x7f7f7f
    obj.sgr_color(0xff8800_i64, true, 256).should eq "38;5;208"
    obj.match(255_u8, 136_u8, 0_u8).should eq 208
    obj.match(255_i64, 136_i64, 0_i64).should eq 208
  end
  it "can mix RGB colors" do
    obj = ClsColors.new
    # `alpha` is the opacity/weight of the first color: 1.0 keeps it fully.
    obj.mix(0x000000, 0xffffff, 0.5).should eq 0x7f7f7f
    obj.mix(0xff0000, 0x0000ff, 0.5).should eq 0x7f007f
    obj.mix(0x123456, 0xabcdef, 1.0).should eq 0x123456
    obj.mix(0x123456, 0xabcdef, 0.0).should eq 0xabcdef
  end
  it "can convert color specs to native RGB" do
    obj = ClsColors.new
    obj.convert(0xff8800).should eq 0xff8800 # native int passthrough
    obj.convert(-1).should eq -1             # default
    obj.convert("#ff8800").should eq 0xff8800
    obj.convert("white").should eq 0xe5e5e5 # name -> RGB
    obj.convert("default").should eq -1
    obj.convert("WHITE").should eq 0xe5e5e5 # names are case-insensitive
    obj.convert("Light Blue").should eq 0x5c5cff
    obj.convert("bright-red").should eq 0xff0000
    obj.convert("nosuchcolor").should eq -1
    # Every named color resolves to the same RGB the Xterm hex table gives.
    TermColors::ColorNames.each do |name, idx|
      expected = idx < 0 ? -1 : obj.hex_to_int(TermColors::Xterm[idx])
      obj.convert(name).should eq expected
    end
    obj.convert([255, 255, 255]).should eq 0xffffff
    obj.convert({16, 32, 48}).should eq 0x102030
    obj.convert(:wrong).should eq -1
  end
  it "degrades malformed hex specs to the default instead of raising" do
    obj = ClsColors.new
    # `convert` is the total color-spec parser: a malformed `#...` must fall back
    # to the terminal default (-1), the same as an unknown name or bad type,
    # rather than raising from the underlying hex parser.
    obj.convert("#").should eq -1       # empty body
    obj.convert("#12").should eq -1     # wrong length
    obj.convert("#gg0000").should eq -1 # non-hex digit
    # `#abcd` is NOT malformed anymore: 4 hex digits is the `#rgba` short
    # alpha form; the alpha channel is stripped (this is a pure color library
    # with no compositing) and the remaining `#abc` parses normally.
    obj.convert("#abcd").should eq obj.convert("#abc")
    obj.convert("#11223344").should eq 0x112233 # #rrggbbaa long alpha form
    obj.convert("#1122334").should eq -1        # 7 digits: no valid form
    # Well-formed specs still parse, including after separator stripping.
    obj.convert("#fff").should eq 0xffffff
    obj.convert("#ff-88-00").should eq 0xff8800
  end
  it "maps hex strings and palette indices to native RGB" do
    obj = ClsColors.new
    obj.hex_to_int("#0cdb72").should eq 0x0cdb72
    obj.hex_to_int("#fff").should eq 0xffffff
    obj.hex_to_int("#1a2").should eq 0x11aa22
    obj.palette_to_rgb(0).should eq 0x000000
    obj.palette_to_rgb(15).should eq 0xffffff
    # Out-of-range indices fall back to 0. Negative indices must NOT wrap around
    # to a real palette entry via Crystal's `Array#[]?` negative-index semantics.
    obj.palette_to_rgb(256).should eq 0
    obj.palette_to_rgb(-1).should eq 0
  end
  it "builds colorspace-aware SGR color fragments" do
    obj = ClsColors.new
    obj.sgr_color(0xff8800, true, 0x1000000).should eq "38;2;255;136;0"
    obj.sgr_color(0x102030, false, 0x1000000).should eq "48;2;16;32;48"
    obj.sgr_color(0xff8800, true, 256).should eq "38;5;208"
    obj.sgr_color(0xcd0000, true, 16).should eq "31"
    obj.sgr_color(-1, true, 256).should eq "39"
    obj.sgr_color(0xffff00, false, 8).should eq "43"
    obj.sgr_color(0xffffff, true, 16).should eq "97"
    # Monochrome targets get the terminal default; both forms must agree.
    obj.sgr_color(0xff0000, true, 1).should eq "39"
    obj.sgr_color(0xff0000, false, 0).should eq "49"
    String.build { |io| obj.sgr_color_to(io, 0xff0000, true, 1) }.should eq "39"
    String.build { |io| obj.sgr_color_to(io, 0xff8800, true, 256) }.should eq "38;5;208"
  end
  it "parses CSS rgb()/hsl() function bodies" do
    obj = ClsColors.new
    obj.parse_rgb_function("rgb(255, 136, 0)").should eq 0xff8800
    obj.parse_rgb_function("rgba(100%, 50%, 0%, 0.5)").should eq 0xff8000
    obj.parse_rgb_function("rgb(-10 300 0)").should eq 0x00ff00 # clamps
    obj.parse_rgb_function("rgb(1, 2)").should be_nil
    obj.parse_hsl_function("hsl(120, 100%, 50%)").should eq 0x00ff00
    obj.parse_hsl_function("hsla(0.5turn, 100%, 50%, 1)").should eq 0x00ffff
    obj.parse_hsl_function("hsl(100grad 100% 50%)").should eq 0x80ff00
    obj.parse_hsl_function("hsl(0, 0%)").should be_nil
  end
  it "converts between RGB and HSL" do
    obj = ClsColors.new
    obj.hsl_to_rgb(0.0, 1.0, 0.5).should eq 0xff0000
    obj.hsl_to_rgb(120.0, 1.0, 0.5).should eq 0x00ff00
    obj.hsl_to_rgb(240.0, 1.0, 0.5).should eq 0x0000ff
    obj.hsl_to_rgb(0.0, 0.0, 0.5).should eq 0x808080   # achromatic
    obj.hsl_to_rgb(-30.0, 1.0, 0.5).should eq 0xff0080 # negative hue wraps
    obj.hsl_to_rgb(390.0, 1.0, 0.5).should eq 0xff8000 # >360 wraps
    obj.rgb_to_hsl(0xff0000).should eq({0.0, 1.0, 0.5})
    obj.rgb_to_hsl(0x808080).should eq({0.0, 0.0, 128 / 255.0})
    obj.rgb_to_hsv(0x0000ff).should eq({240.0, 1.0, 1.0})
    obj.rgb_to_hsv(0x000000).should eq({0.0, 0.0, 0.0})
    # HSL and HSV paths agree on every pure hue.
    (0...360).each do |hue|
      obj.hsl_to_rgb(hue.to_f, 1.0, 0.5).should eq obj.hsv_i(hue)
      TermColors::HSV_LUT[hue].should eq obj.hsv_i(hue)
    end
    # Round trips.
    [0x123456, 0xff8800, 0x00ff7f, 0xabcdef].each do |color|
      h, s, l = obj.rgb_to_hsl(color)
      obj.hsl_to_rgb(h, s, l).should eq color
      h, s, v = obj.rgb_to_hsv(color)
      obj.hsv_i(h, s, v).should eq color
    end
    obj.lighten(0x800000, 0.25).should eq 0xff0000
    obj.darken(0xff0000, 0.25).should eq 0x800000
    obj.lighter(0x800000).should eq 0xc00000
    obj.darker(0xff0000).should eq 0x800000
  end
  it "formats packed colors as hex" do
    obj = ClsColors.new
    obj.hex(0x000000).should eq "#000000"
    obj.hex(0xff8800).should eq "#ff8800"
    obj.hex(0x0a0b0c).should eq "#0a0b0c"
    obj.hex(0xffffff).should eq "#ffffff"
    obj.hex(0x7f123456).should eq "#123456" # only the low 24 bits
    (0...256).step(17) { |v| obj.hex(obj.rgb(v, 255 - v, v // 2)).should eq "#%02x%02x%02x" % {v, 255 - v, v // 2} }
  end
  it "has to_hex2 and to_hex4" do
    obj = ClsColors.new
    obj.to_hex2(7).should eq "07"
    obj.to_hex2(12).should eq "0c"
    obj.to_hex4(255).should eq "00ff"
  end
  it "converts HSV to RGB" do
    obj = ClsColors.new
    # Fully saturated, full-brightness primaries/secondaries around the wheel.
    obj.hsv_i(0).should eq 0xff0000
    obj.hsv_i(60).should eq 0xffff00
    obj.hsv_i(120).should eq 0x00ff00
    obj.hsv_i(240).should eq 0x0000ff
    # Hue wraps into 0..360.
    obj.hsv_i(360).should eq 0xff0000
    obj.hsv_i(-120).should eq 0x0000ff
    # Saturation/value extremes.
    obj.hsv_i(120, 0.0).should eq 0xffffff      # s=0 -> white
    obj.hsv_i(120, 1.0, 0.0).should eq 0x000000 # v=0 -> black
    # Fractional channels round, not truncate: hue 30 gives g=127.5 -> 128
    # (0xff8000), matching the HSL path rather than flooring to 127 (0xff7f00).
    obj.hsv_i(30).should eq 0xff8000
    # String form.
    obj.hsv(120).should eq "#00ff00"
    obj.hsv(0).should eq "#ff0000"
  end
end
