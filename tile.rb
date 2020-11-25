require "colorize"

class Tile
  attr_reader :bomb, :revealed, :bomb_count
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
    elsif @bomb_count == 0
      '_'
    else
      @bomb_count.to_s.colorize(color_map[@bomb_count])
    end
  end

  def reveal(count)
    @revealed = true
    @bomb_count = count
  end

end


