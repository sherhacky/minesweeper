require_relative "board.rb"
require_relative "tile.rb"

#note classic minesweeper: the game ends when
#all bomb-free tiles have been revealed

class Game
  def initialize(height=9, width=9, bombs=10)
    @m = height
    @n = width
    @board = Board.new(height, width)
    @board.populate(bombs)
    @game_over = false
  end

  def prompt
    system('clear')
    @board.render
    puts "Make your move!"
  end

  def parse_input(move)
    if !['f','u','r'].include?(move[0].downcase)
      nil
    else
      action = move[0].downcase
      coord = move.split(' ')[1]
      j = coord[0].downcase.ord - 97
      k = 1
      while !coord[k..-1].split('').all? { |ch|  ("0".."9").include?(ch) }
        k += 1
      end
      if k < coord.length
        i = Integer(coord[k..-1])
      else 
        return nil
      end
      if !(i.between?(0,@m-1) && j.between?(0,@n-1))
        nil
      else
        [action, i, j]
      end
    end
  end

  def make_move(move)
    action = move[0]
    i = move[1]
    j = move[2]
    if action == 'f'
      @board.flag(i,j)
    elsif action == 'u'
      @board.unflag(i,j)
    elsif action == 'r'
      if @board[i,j].bomb
        @game_over = true
      end
      @board.reveal(i,j)
    end
  end

  def check_game_state
    @game_over = @game_over || @board.won?
  end

  def show_game_over_screen
    system('clear')
    if @board.won?
      @board.render
      puts "Nice!"
    else
      @board.reveal_all
      @board.render
      puts "Bad luck!"
    end
  end

  def run
    while !@game_over
      prompt
      move = gets.chomp
      while parse_input(move) == nil
        puts "Command not recognized, please try again."
        move = gets.chomp
      end
      make_move(parse_input(move))
      check_game_state
    end
    show_game_over_screen
  end
end