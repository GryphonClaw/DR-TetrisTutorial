$gtk.reset #This should only be used during testing, not during a production build.

class TetrisGame
  @@DEFULAT_BLOCK_SPEED = 30

  @@BOX_SIZE = 30
  def initialize args
    @args = args
    @next_piece = nil
    @hold_piece = nil
    @next_move = @@DEFULAT_BLOCK_SPEED
    @score = 0

    #FIXME: Maybe combine these as a state utilizing symbols
    #game mode vars, shoudl probably be a symbol such as :gameover and :paused
    @gameover = false
    @paused = false
    
    @grid_w = 10
    @grid_h = 20

    @current_piece_x = 5
    @current_piece_y = 0

    @grid = [] #set the intial grid to zeros ( 0 )
    for x in 0..@grid_w-1 do
      @grid[x] = []
      for y in 0..@grid_h-1 do
        @grid[x][y] = 0
      end
    end

    @color_index = [
      {r: 0, g: 0, b: 0, a: 255}, #black
      {r: 255, g: 0, b: 0, a: 255}, #red
      {r: 0, g: 255, b: 0, a: 255}, #green
      {r: 0, g: 0, b: 255, a: 255}, #blue
      {r: 255, g: 255, b: 0, a: 255}, #yellow
      {r: 255, g: 0, b: 255, a: 255}, #magenta
      {r: 0, g: 255, b: 255, a: 255}, #cyan
      {r: 127, g: 127, b: 127, a: 255}, #grey
    ]

    select_next_piece #selects the inital block
    select_next_piece #selects the next block

    @piece_just_held = false
  end

  def render_cube x, y, color, boxsize = @@BOX_SIZE
    grid_x = (1280 - (@grid_w * boxsize)) / 2
    grid_y = (720 - ((@grid_h-2) * boxsize)) / 2

    current_color = @color_index[color]
    @args.outputs.solids << {x: grid_x + (x * boxsize), y: (720 - grid_y) - (y * boxsize), w: boxsize, h: boxsize,
      **current_color
    }
    @args.outputs.borders << {x: grid_x + (x * boxsize), y: (720 - grid_y) - (y * boxsize), w: boxsize, h: boxsize,
      r: 255, g: 255, b: 255, a: 255
    }
  end

  def render_grid

    for x in 0..@grid_w-1 do
      for y in 0..@grid_h-1 do
        render_cube x, y, @grid[x][y]  if @grid[x][y] != 0
      end
    end
  end

  def render_grid_border x, y, w, h
    color_index = 7
    for i in x..(x+w)-1 do
      render_cube i, y, color_index
      render_cube i, (y + h) - 1, color_index
    end

    for i in y..(y+h)-1 do
      render_cube x, i, color_index
      render_cube (x + w)-1, i, color_index
    end
  end

  def render_background
    @args.outputs.solids << {x: 0, y: 0, w: 1280, h: 720, r: 0, g: 0, b: 0, a: 255}
    render_grid_border -1, -1, @grid_w + 2, @grid_h + 2
  end

  def render_piece piece, piece_x, piece_y
    color = [0, 128, 0, 255]
    for x in 0..(piece.length - 1) do
      for y in 0..(piece[x].length - 1) do
        render_cube( piece_x + x, piece_y + y, piece[x][y]) if piece[x][y] != 0
      end
    end
  end

  def render_current_piece
    render_piece @current_piece, @current_piece_x, @current_piece_y
  end
  
  def render_next_piece
    #FIXME: !!! don't hardcode these numbers.
    render_grid_border 13, 2, 8, 8
    center_x = (8 - @next_piece.length) / 2
    center_y = (8 - @next_piece[0].length) / 2
    
    render_piece @next_piece, 13 + center_x, 2 + center_y if !@paused #only render the next piece if we are actively playing
    @args.outputs.labels << {x: (720 / 2 ) + (21 * 30) + center_x, y: 720 - (3 * 30) + 24, text: "Next Piece", size_px: 48, r: 255, g: 255, b: 255, a: 255, alignment_enum: 1}

  end

  def render_hold_piece
    render_grid_border -13, 2, 8, 8

    if @hold_piece
      center_x = (-44 - @hold_piece.length) / 2
      center_y = (8 - @hold_piece[0].length) / 2

      render_piece @hold_piece, 13 + center_x, 2 + center_y
    end

    @args.outputs.labels << {x: (1280 / 2) - (14 * @@BOX_SIZE) , y: 720 - (3 * @@BOX_SIZE) + 24, text: "Hold", size_px: 48, r: 255, g: 255, b: 255, a: 255, alignment_enum: 1}
  end

  def render_score
    @args.outputs.labels << {x: 75, y: 75, text: "Score #{@score}", size_enum: 10, r: 255, g: 255, b: 255, a: 255}
    #Only draw Paused if the game is pasued, draw it twice to give a small "offset" effect
    @args.outputs.labels << {x: 642, y: 448, text: "PAUSED", size_enum: 100, alignment_enum: 1, r: 200, g: 200, b: 200, a: 255} if @paused
    @args.outputs.labels << {x: 640, y: 450, text: "PAUSED", size_enum: 100, alignment_enum: 1, r: 255, g: 255, b: 255, a: 255} if @paused
    #Only draw Game Over if the game is over, draw it twice to give a small "offset" effect
    @args.outputs.labels << {x: 640, y: 445, text: "GAME OVER", size_enum: 100, alignment_enum: 1, r: 245, g: 245, b: 245, a: 255} if @gameover
    @args.outputs.labels << {x: 640, y: 450, text: "GAME OVER", size_enum: 100, alignment_enum: 1, r: 255, g: 255, b: 255, a: 255} if @gameover
  end

  def render
    render_background
    render_grid if !@paused #only render the grid if we are actively playing
    render_next_piece
    render_current_piece if !@paused #only render the current piece if we are actively playing
    render_hold_piece
    render_score
  end

  def current_piece_colliding
    for x in 0..@current_piece.length-1 do
      for y  in 0..@current_piece[x].length-1 do
        if (@current_piece[x][y] != 0)
           if @current_piece_y + y >= @grid_h
            return true
           elsif (@grid[@current_piece_x + x][@current_piece_y + y + 1] != 0)
            return true
           end
        end
      end
    end
    return false
  end

  def select_next_piece
    @current_piece = @next_piece
    X = rand(7) + 1
    @next_piece = case X
      when 1 then [[0, X],[0, X], [X,X]] 
      when 2 then [[X, X],[0, X], [0,X]]
      when 3 then [[X], [X], [X], [X]]
      when 4 then [[X, 0],[X, X], [0, X]]
      when 5 then [[X, X],[X, X]]
      when 6 then [[0, X],[X, X],[0, X]]
      when 7 then [[0, X],[X, X], [X, 0]]
    end

    set_current_piece_position 5, 0
  end

  def set_current_piece_position x = 5, y = 0
    @current_piece_x  = x
    @current_piece_y  = y
  end

  def plant_current_piece
    for x in 0..@current_piece.length-1 do
      for y  in 0..@current_piece[x].length-1 do
        if @current_piece[x][y] != 0
          @grid[@current_piece_x + x][@current_piece_y + y] = @current_piece[x][y]
        end
      end
    end
    set_current_piece_position

    for y in 0..@grid_h-1 # see if any rows need to be cleared out
      row_full = true
      for x in 0..@grid_w-1
        if @grid[x][y] == 0
          row_full = false
          break
        end
      end
      
      if row_full #no empty space in the row
        @score += 1
        for i in y.downto(1) do
          for j in 0..@grid_w - 1
            @grid[j][i] = @grid[j][i - 1]
          end
        end
        for i in 0..@grid_w-1
          @grid[i][0] = 0
        end
      end
    end
    
    select_next_piece

    @piece_just_held = false

    if current_piece_colliding
      @gameover = true
    end
  end

  def swap_hold_piece
    @piece_just_held = true
    if @hold_piece
      temp_piece = @current_piece
      @current_piece = @hold_piece
      @hold_piece = temp_piece
      set_current_piece_position
    else
      @hold_piece = @current_piece
      select_next_piece
    end
  end

  def rotate_current_piece_left
    @current_piece = @current_piece.transpose.map(&:reverse)
    if (@current_piece_x + @current_piece.length) >= @grid_w
      @current_piece_x = @grid_w - @current_piece.length
    end
  end
  
  def rotate_current_piece_right
    3.times do #rotate left 3 times to get a right rotated block
      rotate_current_piece_left
    end
  end

  def toggle_paused
    @paused = !@paused
  end

  def iterate
    kb = @args.inputs.keyboard
    cn = @args.inputs.controller_one

    if (kb.key_down.p || cn.key_down.select) && !@gameover
      toggle_paused
    end

    return if @paused

    if @gameover
      if kb.key_down.space || cn.key_down.start
        $gtk.reset_next_tick
      end
      return #dont allow any other processing if we are in the gameover state
    end

    if (kb.key_down.left) || (cn.key_down.left)
      if @current_piece_x > 0
        @current_piece_x -= 1
      end
    end
    if (kb.key_down.right) || (cn.key_down.right)
      if (@current_piece_x + @current_piece.length) <= @grid_w-1
        @current_piece_x += 1
      end
    end

    if kb.key_down.a || cn.key_down.a
      rotate_current_piece_left
    end
    if kb.key_down.f || cn.key_down.b
      rotate_current_piece_right
    end

    if (kb.key_down.down || kb.key_held.down) || (cn.key_down.down || cn.key_held.down)
      @next_move -= 10
    end

    if ((kb.key_down.q) || cn.key_down.select) && !@piece_just_held
      puts "Should hold piece"
      swap_hold_piece
    end

    @next_move -= 1
    if @next_move <= 0
      if current_piece_colliding
        plant_current_piece
      else
        @current_piece_y += 1
      end
      @next_move = @@DEFULAT_BLOCK_SPEED
    end
  end

  def tick
    iterate
    render
  end
end

def tick args
  args.state.game ||= TetrisGame.new(args)
  args.state.game.tick

  args.outputs.labels << {x: 10, y: 690, text: "DragonRuby Version: #{$gtk.version}", r: 255, g: 255, b: 255, a: 255}
end
