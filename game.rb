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
    puts " "
    puts String(@board.flag_count).colorize(:red) + " flags remaining"
    puts "Make your move!"
  end

  def parse_input(move)
    if move == '' || !['f','u','r','h'].include?(move[0].downcase)
      nil
    else
      if ['h','help','H','Help'].include?(move)
        return 'h'
      end
      action = move[0].downcase
      result = [action]
      coords = move.split(' ')[1..-1]
      coords.each do |coord|
        i = coord[0].downcase.ord - 97
        k = 1
        while !coord[k..-1].split('').all? { |ch|  ("0".."9").include?(ch) }
          k += 1
        end
        if k < coord.length
          j = Integer(coord[k..-1]) - 1
        else 
          return nil
        end
        result << [i,j]
      end
      result 
    end
  end

  def make_move(move)
    action = move[0]
    move[1..-1].each do |pos|
      i,j = pos
      if action == 'f'
        @board.flag(i,j)
      elsif action == 'u'
        @board.unflag(i,j)
      elsif action == 'r'
        if @board[i,j].bomb && !@board[i,j].flagged
          @game_over = true
        end
        @board.reveal(i,j)
      end
    end
  end

  def check_game_state
    @game_over = @game_over || @board.won?
  end

  def show_game_over_screen
    system('clear')
    if @board.won?
      @board.reveal_all
      @board.render
      puts "You won. Nice!"
    else
      @board.reveal_all
      @board.render
      puts "Bad luck!"
    end
  end

  def help_out
    puts "Valid action are [F]lag, [U]nflag, or [R]eveal."
    puts "Commands should be entered as action and coordinates,"
    puts "separated by a space. Note you can act on multiple "
    puts "coordinates at once.  Examples:"
    puts " >> flag E5"
    puts " >> Unflag G3"
    puts " >> r a5 b1 b2" 
  end

  def is_valid_move?(move)
    if !(move.is_a?(Array) && move.length > 0)
      return false
    elsif !(move[0].is_a?(String) && ['r','f','u'].include?(move[0]))
      return false
    elsif move[1..-1].any? do |pos|
        i,j = pos
        !( (i.between?(0,@m-1) && j.between?(0,@n-1)) ) \
         || ( move[0] == 'r' && (@board[i,j].flagged || @board[i,j].revealed) ) \
         || ( move[0] == 'f' && (@board[i,j].flagged || @board[i,j].revealed) ) \
         || ( move[0] == 'u' && !@board[i,j].flagged )
       end
      return false
    else
      return true
    end
  end

  def run
    while !@game_over
      prompt
      move = parse_input(gets.chomp)
      while move == nil || !is_valid_move?(move)
        if move == nil
          puts "Command not recognized. Please try again or enter H for help."
        elsif move[0].downcase == 'h'
          help_out
        else
          puts "That's not a legal move! Make sure you use legal coordinates,"
          puts "and aren't trying to reveal a flagged tile!"
          puts "Type H for help."
        end
        move = parse_input(gets.chomp)
      end
      make_move(move)
      check_game_state
    end
    show_game_over_screen
  end

  def self.valid_custom_config(string)
    begin
      coords = string.split(/\s|,/)
      coords.select! { |entry| entry.length > 0 }
      coords.map! { |entry| Integer(entry) }
    rescue
      puts "Invalid input! Please give numeric values."
      return false
    end
    h,w,b = coords
    if !h.between?(1,26) || !w.between?(1,100) || !b.between?(1,h*w-1)
      puts "Invalid choice (board can accept heights up to 26 and widths up to 100;"
      puts "there must be at least one bomb, and at least one empty space!"
      return false
    end
    true
  end

  def self.parse_custom_config(string)
    coords = string.split(/\s|,/)
    coords.select! { |entry| entry.length > 0 }
    coords.map! { |entry| Integer(entry) }
    coords
  end

  def self.opening_screen
    puts "==========================="
    puts "|  M I N E S W E E P E R  |"
    puts "==========================="
    puts "Select difficulty: [E]asy, [M]edium, [H]ard or [C]ustom."
  end

  def self.custom_game
      puts "Please enter desired height, width, and number of bombs (separated by commas)."
      custom = gets.chomp
      while !Game.valid_custom_config(custom)

        custom = gets.chomp
      end
      h,w,b = Game.parse_custom_config(custom)
      Game.new(h,w,b)
    end

  def self.select_difficulty
    difficulty = gets.chomp[0].downcase
    while !['e','m','h','c'].include?(difficulty)
      puts "Sorry, that's not a valid selection."
      puts "Please enter [E]asy, [M]edium, [H]ard or [C]ustom."
      difficulty = gets.chomp[0].downcase
    end

    if difficulty == 'e'
      g = Game.new
    elsif difficulty == 'm'
      g = Game.new(16,16,40)
    elsif difficulty == 'h'
      g = Game.new(16,30,99)
    else
      g = custom_game
    end

    return g
  end
end

Game.opening_screen
g = Game.select_difficulty
g.run