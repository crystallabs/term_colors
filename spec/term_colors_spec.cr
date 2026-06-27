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
    obj.hex_to_rgb("#fff").should eq Tuple.new(255, 255, 255)
    obj.hex_to_rgb("#000000").should eq({0, 0, 0})
    obj.hex_to_rgb("#23ce9a").should eq({35, 206, 154})
  end
  it "has ccolors and ncolors" do
    TermColors::HI2LN[0].should eq "black"
    TermColors::HI2LN[255].should eq "white"
    TermColors::HI2LN.size.should eq 256

    TermColors::HI2LI[0].should eq 0
    TermColors::HI2LI[255].should eq 7
    TermColors::HI2LI.size.should eq 256
  end
  it "has colors and vcolors" do
    TermColors::HI2HH[0].should eq "#000000"
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
    obj.convert([255, 255, 255]).should eq 0xffffff
    obj.convert({16, 32, 48}).should eq 0x102030
    obj.convert(:wrong).should eq -1
  end
  it "maps hex strings and palette indices to native RGB" do
    obj = ClsColors.new
    obj.hex_to_int("#0cdb72").should eq 0x0cdb72
    obj.hex_to_int("#fff").should eq 0xffffff
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
