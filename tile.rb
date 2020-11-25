require "colorize"

class Tile
  attr_writer :bomb_count, :revealed

  def initialize(bomb = false)
    @bomb = bomb
    @revealed = false
    @bomb_count = nil
  end

  def color_map
    { 1=>:cyan,
      2=>:green,
      3=>:red,
      4=>:blue,
      5=>:magenta,
      6=>:light_cyan,
      7=>:light_black,
      8=>:white }
  end

  def to_s
    if !@revealed
      '*'
    else
      @bomb_count.to_s.colorize(color_map[@bomb_count])
    end
  end

end


