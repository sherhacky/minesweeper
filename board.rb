require_relative "tile.rb"

class Board

  def initialize(height = 9, width = 9)
    @grid = Array.new(height) { Array.new(width) }
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

end