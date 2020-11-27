require "colorize"

class Tile
  attr_reader :bomb, :revealed, :bomb_count, :flagged
  attr_writer :bomb_count, :revealed, :flagged

  def initialize(bomb = false)
    @bomb = bomb
    @revealed = false
    @bomb_count = nil
    @flagged = false
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

  def flag
    if @flagged
      return false
    elsif @revealed
      return false
    else
      @flagged = true
    end
  end

  def to_s
    bomb = "\u260c".encode('utf-8')
    flag = "\u2691".encode('utf-8')
    if @flagged
      flag.colorize(:red)
    elsif !@revealed
      '*'
    elsif @bomb_count == 0
      '_'
    else
      @bomb_count.to_s.colorize(color_map[@bomb_count])
    end
  end

  def reveal(count)
    if @revealed || @flagged
      return false
    end
    @revealed = true
    @bomb_count = count
    true
  end

end


