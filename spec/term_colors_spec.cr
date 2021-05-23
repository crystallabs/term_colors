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
    r= obj.color_distance(0,0,0,255,255,255)
    r.should eq 292742550
    r= obj.color_distance(255,255,255,0,0,0)
    r.should eq 292742550
    r= obj.color_distance(10,12,190,117,34,112)
    r.should eq 12725068
  end
  it "can convert rgb2hex, hex2rgb" do
    obj = ClsColors.new
    obj.rgb_to_hex([0,0,0]).should eq "#000000"
    obj.rgb_to_hex(255,255,255).should eq "#ffffff"
    obj.rgb_to_hex(12,219,114).should eq "#0cdb72"
    obj.rgb_to_hex(Colorize::ColorRGB.new 12,219,114).should eq "#0cdb72"
    obj.hex_to_rgb("#fff").should eq Tuple.new(255,255,255)
    obj.hex_to_rgb("#000000").should eq({0,0,0})
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

    TermColors::HI2RGB[0].should eq Tuple.new(0,0,0)
    TermColors::HI2RGB[255].should eq Tuple.new(238,238,238)
    TermColors::HI2RGB.size.should eq 256
  end
  it "can reduce" do
    obj = ClsColors.new
    r= obj.reduce 98, 8
    r.should eq 4
    r= obj.reduce 98, 16
    r.should eq 4
    r= obj.reduce 98, 2
    r.should eq 4
  end
  it "can find nearest colors" do
    obj = ClsColors.new
    r= obj.match(229,229,229)
    r.should eq 7
    r= obj.match(Tuple.new(229,229,229))
    r.should eq 7
    r= obj.match([229,229,229])
    r.should eq 7
    r= obj.match([229,229,230])
    r.should eq 7
    r= obj.match([229,229,235])
    r.should eq 7
  end
  it "can mix colors" do
    obj = ClsColors.new
    # TODO check if these are correct values
    obj.mix_colors(0,7).should eq 243
    obj.mix_colors(1,207).should eq 162
    obj.mix_colors(3,99).should eq 247
    obj.mix_colors(4,81).should eq 27
  end
  it "can blend" do
    obj = ClsColors.new
    obj.blend(7, 11, 1).should eq 11
    obj.blend(34, 213, 0.1).should eq 34
    obj.blend(0, 213, 0.5).should eq 96
    obj.blend(34, 0, 0.5).should eq 22
  end
  it "can convert colors" do
    obj = ClsColors.new
    # TODO check if these are correct values
    r= obj.convert 7
    r.should eq 7
    r= obj.convert "white"
    r.should eq 7
    r= obj.convert [255,255,255]
    r.should eq 15
    r= obj.convert( :wrong)
    r.should eq 511
  end
  it "has to_hex2 and to_hex4" do
    obj = ClsColors.new
    obj.to_hex2(7).should eq "07"
    obj.to_hex2(12).should eq "0c"
    obj.to_hex4(255).should eq "00ff"
  end
end
