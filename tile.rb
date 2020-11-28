require "colorize"

class Tile
  attr_reader :bomb, :revealed, :bomb_count, :flagged
  attr_writer :bomb_count, :revealed, :flagged

  def initialize(bomb = false)
    @bomb = bomb
    @revealed = false
    @bomb_count = nil
    @flagged = false
    @selected = false
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

  def unflag
    if !@flagged
      return false
    elsif @revealed
      return false
    else
      @flagged = false
    end
  end

  def explode
    if @bomb
      @bomb = nil
    end
  end

  def to_s_unselected
    output = ''
    bomb = "\u260c".encode('utf-8')
    flag = "\u2691".encode('utf-8')
    if @bomb == nil
      bomb.colorize(:black).on_red
    elsif @flagged && @revealed && !@bomb
      flag.colorize(:light_black)
    elsif @flagged && @revealed && @bomb
      flag.colorize(:light_red)
    elsif @revealed && @bomb
      bomb.colorize(:red)
    elsif @flagged
      flag.colorize(:red)
    elsif !@revealed
      '*'
    elsif @bomb_count == 0
      '_'
    else
      @bomb_count.to_s.colorize(color_map[@bomb_count])
    end
  end

  def to_s
    if !@selected || @bomb == nil
      to_s_unselected
    else
      to_s_unselected.black.on_white
    end
  end


  def reveal(count, forced = false)
    if !forced && (@revealed || @flagged)
      return false
    end
    @revealed = true
    @bomb_count = count
    true
  end

  def select
    @selected = true
  end

  def unselect
    @selected = false
  end

end


