#!/usr/bin/env ruby

# Used to produce Ccolors and Ncolor tables, which are then inserted into colors.cr
# This file is needed only if the list there somehow needs to be changed/updated

    ColorNames = {
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


   LowColorIndices = {
      "blue" => [
        4, 12, 17..21, 24..27, 31..33, 38..39, 45, 54..57, 60..63, 67..69, 74..75, 81, 91..93, 97..99, 103..105,
        110..111, 117, 128..129, 134..135, 140..141, 146..147, 153, 165, 171, 177, 183, 189
      ],
      "green" => [
        2, 10, 22, [28, 29], 34..36, 40..43, 46..50, 64..65, 70..72, 76..79,
        82..86, 106..108, 112..115, 118..122, 148..151, 154..158, 190..194
      ],
      "cyan" => [
        6, 14, 23, 30, 37, 44, 51, 66, 73, 80, 87,
        109, 116, 123, 152, 159, 195
      ],
      "red" => [
        1, 9, 52, 88..89, 94..95, 124..126, 130..132, 136..138, 160..163, 166..169, 172..175,
        178..181, 196..200, 202..206, 208..212, 214..218, 220..224
      ],
      "magenta" => [
        5, 13, 53, 90, 96, 127, 133, 139, 164, 170, 176,
        182, 201, 207, 213, 219, 225
      ],
      "yellow" => [
        3, 11, 58, 100..101, 142..144,
        184..187, 226..230
      ],
      "black" => [
        0, 8, 16, 59,
        102, 232..243
      ],
      "white" => [
        7, 15, 145, 188,
        231, 244..255
      ]
    }

ccolors = []
ncolors = []



   LowColorIndices.each do |color, list|
      list.each do |idx|
        if idx.is_a? Integer
          idx = [idx]
        end
        idx.each do |i|
          ncolors[i] = color
          ccolors[i] = ColorNames[color]
        end
      end
    end

p ccolors
p ncolors
