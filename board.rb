require_relative "tile.rb"

class Board

  def initialize(height = 9, width = 9)
    @grid = Array.new(height) { Array.new(width) }
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
  end

  def render
    puts "  " + ('A'..'Z').to_a[0...@grid[0].length].join(" ")
    @grid.each_with_index do |row,i|
      row_rendered = String(i)
      row.each { |tile| row_rendered << " " + tile.to_s }
      puts row_rendered
    end
    nil
  end

  def reveal(*pos)
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
      true
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
    if self[*pos].revealed
      return false
    end
    self[*pos].flag
    true
  end

  def unflag(*pos)
    if self[*pos].revealed
      return false
    end
    self[*pos].unflag
    true
  end

  def reveal_neighbors(*pos)
    neighbors(*pos).each do |nbr|
      if !self[*nbr].revealed
        reveal(*nbr)
      end
    end
  end

  def count_adjacent_bombs(*pos)
    count = 0
    neighbors(*pos).each do |nbr|
      count += 1 if self[*nbr].bomb
    end
    count
  end

  def won?
    @grid.all? do |row|
      row.all? do |tile|
        tile.bomb || tile.revealed
      end
    end
  end

end