require_relative "tile.rb"
require "colorize"
require 'set'

class Board
  attr_reader :flag_count

  def initialize(height = 9, width = 9)
    @m = height
    @n = width
    @grid = Array.new(height) { Array.new(width) }
    @flag_count = nil
    @selected = [0,0]
  end

  def [](*pos)
    i,j = pos
    @grid[i][j]
  end

  def []=(*pos,val)
    i,j = pos
    @grid[i][j] = val
  end

  def populate(count=10)
    m = @grid.length
    n = @grid[0].length
    bombs = (0...m*n).to_a.sample(count)
    bombs.map! { |i| [i / n, i % n] }
    @grid.each_with_index do |row,i|
      row.each_with_index do |entry,j|
        if bombs.include?([i,j])
          self[i,j] = Tile.new(true)
        else
          self[i,j] = Tile.new(false)
        end
      end
    end
    @flag_count = count
  end

  def render
    head = " "
    #if @grid[0].length <= 10
    #  head = "  " + ('1'..'10').to_a[0...@grid[0].length].join(" ")
    #else
    #  head = "  "
    #  (1..@grid[0].length).each do |k|
    #    append = String(k)
    #    if k < 10
    #      append << " "
    #    end
    #    if k%2 != 0
    #      append = append.colorize(:light_black)
    #    end
    #    head << append
    #  end
    #end
    puts head
    @grid.each_with_index do |row,i|
      row_rendered = ""
      #row_rendered << (i+65).chr
      row.each { |tile| row_rendered << " " + tile.to_s }
      puts row_rendered
    end
    nil
  end

  def reveal_selected
    reveal(*@selected)
  end

  def toggle_flag
    if self[*@selected].revealed
      return nil
    elsif self[*@selected].flagged
      unflag(*@selected)
    else
      flag(*@selected)
    end
  end

  def reveal(*pos)
    # returns true iff a bomb exploded (to trigger game end)
    if self[*pos].revealed || self[*pos].flagged
      return false
    elsif self[*pos].bomb
      self[*pos].explode
      return true
    else
      self[*pos].reveal(count_adjacent_bombs(*pos))
      if self[*pos].bomb_count == 0
        reveal_neighbors(*pos)
      end
      false
    end
  end

  def reveal_all
    @grid.each_with_index do |row,i|
      row.each_with_index do |tile,j|
        tile.reveal(count_adjacent_bombs(i,j), true)
      end
    end
  end

  def neighbors(*pos)
    i,j = pos
    result = []
    [i-1,i,i+1].each do |y|
      [j-1,j,j+1].each do |x|
        if y.between?(0, @grid.length-1) &&
          x.between?(0, @grid[0].length-1) &&
          result << [y,x]
        end
      end
    end
    result
  end

  def flag(*pos)
    if self[*pos].revealed || self[*pos].flagged
      return false
    end
    self[*pos].flag
    @flag_count -= 1
    true
  end

  def unflag(*pos)
    if self[*pos].revealed || !self[*pos].flagged
      return false
    end
    self[*pos].unflag
    @flag_count += 1
    true
  end

  def reveal_neighbors(*pos)
    to_do = [pos]
    seen = Set.new([pos])
    while to_do.length > 0
      new_to_do = []
      to_do.each do |crd|
        neighbors(*crd).each do |nbr|
          bombs = count_adjacent_bombs(*nbr)
          if bombs == 0 && !seen.include?(nbr) && !self[*nbr].revealed
            new_to_do << nbr
          end
          seen << nbr
          self[*nbr].reveal(bombs)
        end
      end
      to_do = new_to_do
    end
  end
            

  def count_adjacent_bombs(*pos)
    count = 0
    neighbors(*pos).each do |nbr|
      count += 1 if (self[*nbr].bomb || self[*nbr].bomb == nil)
    end
    count
  end

  def select(*pos)
    self[*@selected].unselect
    self[*pos].select
    @selected = pos
  end

  def move_cursor(string)
    i,j = @selected
    if string == 'left' && j > 0
      select(i,j-1)
    elsif string == 'right' && j < @n-1
      select(i,j+1)
    elsif string == 'up' && i > 0
      select(i-1,j)
    elsif string == 'down' && i < @m-1
      select(i+1,j)
    end
    return nil
  end

  def won?
    @grid.all? do |row|
      row.all? do |tile|
        tile.bomb || tile.revealed
      end
    end
  end

end