require_relative "board.rb"
require_relative "tile.rb"
require "remedy"
require "yaml"
include Remedy
#note that in classic minesweeper, the game ends when
#all bomb-free tiles have been revealed.

class Game
  @@continuing = true
  def initialize(height=9, width=9, bombs=10)
    @m = height
    @n = width
    @bombs = bombs
    @board = Board.new(height, width)
    @board.populate(bombs)
    @board.select(0,0)
    @game_over = false
    @keys = {'up' => Key.new("\e[A"), 
             'down' => Key.new("\e[B"), 
             'left' => Key.new("\e[D"), 
             'right' => Key.new("\e[C"), 
             ' ' => Key.new(" "), 
             'f' => Key.new("f"), 
             'ctrl-s' => Key.new("\u0013"), 
             'ctrl-c' => Key.new("\u0003"), 
             'h' => Key.new("h")}
    @commands = @keys.invert
  end

  def restart
    @board = Board.new(@m,@n)
    @board.populate(@bombs)
    @board.select(0,0)
    @game_over = false
  end

  def self.continuing
    @@continuing
  end

  def self.discontinue
    @@continuing = false
  end
  
  def act_on_input
    move = @commands[Keyboard.get]
    if ['up','down','left','right'].include?(move)
      @board.move_cursor(move)
    elsif move == ' '
      @game_over = @board.reveal_selected
      check_game_state
    elsif move == 'f'
      @board.toggle_flag
    elsif move == 'ctrl-s'
      # save_file = File.open("saves.txt")
      time = Time.new.inspect[0..18]
      new_save = self.to_yaml
      # puts new_save
      File.write("saves.txt", time + "BREAK_PLACEHOLDER" + new_save)
      puts "Game saved."
      sleep(2)
    elsif move == 'ctrl-c'
      puts "Are you sure you want to quit? (y/n)"
      puts "Any unsaved data will be lost."
      # could also say the time last saved here or something nice
      if gets.chomp == 'y'
        Game.discontinue
      end
    end
  end


  def prompt
    system('clear')
    @board.render
    puts " "
    puts String(@board.flag_count).colorize(:red) + " flags remaining"
  end

  def check_game_state
    @game_over = @game_over || @board.won?
  end

  def show_game_over_screen
    system('clear')
    if @board.won?
      @board.reveal_all
      @board.render
      puts "\n   " +  " You won. Nice! ".black.on_yellow + "\n  "
    else
      @board.reveal_all
      @board.render
      puts "\n   " + " Bad luck! ".black.on_red + "\n  "
    end
    puts "[T]itle"
    puts "[Q]uit"
    puts "[P]lay again"
    cmd = ''
    while !['t','q','p'].include?(cmd)
      cmd = Keyboard.get.seq
    end
    if cmd == 'q'
      @@continuing = false
    elsif cmd == 'p'
      restart
    end
    nil
  end

  def run
    while !@game_over
      while @@continuing && !@game_over
        prompt
        act_on_input
      end
      if @@continuing
        show_game_over_screen
      else
        return
      end
    end
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
    if !h.between?(1,100) || !w.between?(1,100) || !b.between?(1,h*w-1)
      puts "Invalid choice (board can accept heights and widths up to 100;"
      puts "and there must be at least one bomb, and at least one empty space!)"
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
    system('clear')
    puts " ==========================="
    puts " |  M I N E S W E E P E R  |"
    puts " ==========================="
    puts "    [N]ew game start"
    puts "    [L]oad existing game"
    puts "    [H]elp"
    puts "    [Q]uit"
  end

  def self.opening_input
    cmd = ''
    while !['n','l','h','q'].include?(cmd)
      cmd = Keyboard.get.seq
    end
    cmd
  end

  def self.help_screen
    system('clear')
    puts "Move the cursor with arrow keys."
    puts "Reveal a square with spacebar."
    puts "Toggle flag with F key."
    puts "Save a game in progress by pressing Ctrl+S."
    puts "Press any key to continue."
    Keyboard.get
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
    puts "Select difficulty: [E]asy, [M]edium, [H]ard or [C]ustom."
    difficulty = Keyboard.get.seq
    until ['e','m','h','c'].include?(difficulty)
      #puts "Sorry, that's not a valid selection."
      #puts "Please choose [E]asy, [M]edium, [H]ard or [C]ustom."
      difficulty = Keyboard.get.seq
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

  def self.view_saves
    #format - time last played, time spent playing, difficulty/custom grid setting, percentage complete?
    system('clear')
    puts "Select a saved game:"
    save_file = File.open("saves.txt")
    save_data = save_file.read.split("BREAK_PLACEHOLDER")
    # save_data.each.with_index do |save,i|
    #   save_data[i] = process_saved_game(save)
    #   puts String(i) + " - game saved " + save[0]
    # end
    puts "last played " + save_data[0]
    puts "enter 0 to start"
    indices = ('0'...String(save_data.length)).to_a
    while !indices.include?(gets.chomp)
    end
    load_game = YAML::load(save_data[1])
    load_game.run
  end

end

while Game.continuing
  Game.opening_screen
  mode = Game.opening_input
  if mode == 'n'
    g = Game.select_difficulty
    g.run
  elsif mode == 'h'
    Game.help_screen
  elsif mode == 'q'
    Game.discontinue
  elsif mode == 'l'
    Game.view_saves
  end
end