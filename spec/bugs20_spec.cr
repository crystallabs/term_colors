require "./spec_helper"

class Bugs20Colors
  include TermColors
end

describe TermColors do
  describe "#mix" do
    it "clamps an out-of-range alpha instead of overflowing" do
      c = Bugs20Colors.new
      c.mix(0x000000, 0xffffff, -40_000.0).should eq 0xffffff
      c.mix(0x000000, 0xffffff, 1e300).should eq 0x000000
    end

    it "treats a NaN alpha as keeping the first color" do
      Bugs20Colors.new.mix(0x123456, 0xffffff, Float64::NAN).should eq 0x123456
    end

    it "is unchanged for in-range alphas" do
      c = Bugs20Colors.new
      c.mix(0x000000, 0xffffff, 1.0).should eq 0x000000
      c.mix(0x000000, 0xffffff, 0.0).should eq 0xffffff
    end
  end

  describe "HSL/HSV conversion with non-finite inputs" do
    it "maps a non-finite hue to 0 degrees instead of raising" do
      c = Bugs20Colors.new
      c.hsv_i(Float64::INFINITY).should eq c.hsv_i(0)
      c.hsv_i(Float64::NAN).should eq c.hsv_i(0)
    end

    it "parses an hsl() whose turn hue overflows to infinity" do
      c = Bugs20Colors.new
      huge = "1" + "0" * 306
      c.parse_hsl_function("hsl(#{huge}turn, 100%, 50%)").should eq c.parse_hsl_function("hsl(0, 100%, 50%)")
    end

    it "does not raise on a NaN saturation" do
      Bugs20Colors.new.hsl_to_rgb(0.0, Float64::NAN, 0.5).should be_a(Int32)
    end
  end

  describe "88-color terminals" do
    it "emits indices of xterm's 88-color palette, not of the 256-color one" do
      c = Bugs20Colors.new
      # Cube: 16 + 16r + 4g + b over the levels 00/8b/cd/ff.
      c.sgr_color(0xff0000, true, 88).should eq "91" # ANSI bright red is exact
      c.sgr_color(0x8b0000, true, 88).should eq "38;5;32"
      c.sgr_color(0x00cdff, false, 88).should eq "48;5;27"
      c.sgr_color(0x8bcd8b, true, 88).should eq "38;5;41"
      # Gray ramp 80-87.
      c.sgr_color(0x2e2e2e, true, 88).should eq "38;5;80"
      c.sgr_color(0xe7e7e7, false, 88).should eq "48;5;87"
      # Nearest entry for a color the palette lacks.
      c.sgr_color(0x900808, true, 88).should eq "38;5;32"
    end

    it "never emits an index outside the 88-color palette" do
      c = Bugs20Colors.new
      256.times do |i|
        (0...88).includes?(c.reduce(i, 88)).should be_true
      end
      [0x123456, 0xff8800, 0x5f87af, 0xeeeeee, 0x080808].each do |rgb|
        m = c.sgr_color(rgb, true, 88).match(/\A38;5;(\d+)\z/)
        m[1].to_i.should be < 88 if m
      end
    end

    it "reduces a 256-palette index to the nearest 88-color entry" do
      c = Bugs20Colors.new
      c.reduce(9, 88).should eq 9
      c.reduce(196, 88).should eq 9  # ff0000: the ANSI entry comes first
      c.reduce(21, 88).should eq 19  # 0000ff: cube 16 + 3
      c.reduce(240, 88).should eq 81 # 585858 -> 5c5c5c
    end

    it "treats other counts between 16 and 256 as a 16-color terminal" do
      c = Bugs20Colors.new
      c.sgr_color(0xff8800, true, 64).should eq c.sgr_color(0xff8800, true, 16)
      c.sgr_color(0x5f87af, false, 255).should eq c.sgr_color(0x5f87af, false, 16)
      c.reduce(98, 100).should eq c.reduce(98, 16)
      c.reduce(12, 100).should eq 12
    end

    it "keeps the 256-color encoding unchanged" do
      c = Bugs20Colors.new
      c.sgr_color(0xff8800, true, 256).should eq "38;5;208"
      c.reduce(98, 256).should eq 98
    end
  end
end
