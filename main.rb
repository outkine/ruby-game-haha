require "gosu"
require "ostruct"

class Thing
  attr_accessor :x, :y, :w, :h

  def initialize(x, y, w, h, c)
    @default_x = x
    @default_y = y
    @w = w
    @h = h
    @c = c

    reset
  end

  def draw
    Gosu.draw_rect @x, @y, @w, @h, @c
  end

  def update
  end

  def reset
    @x = @default_x
    @y = @default_y
  end
end

class Mob < Thing
  @@speed = 1

  def self.speed_up
    @@speed += 0.001
  end

  def initialize(x, y, w, h, c, direction)
    super x, y, w, h, c
    @direction = direction
  end

  def update
    case @direction
    when :up
      @y -= @@speed
    when :down
      @y += @@speed
    when :left
      @x -= @@speed
    when :right
      @x += @@speed
    end
  end
end

class Player < Thing
  @@speed = 1

  def self.speed_up
    @@speed += 0.001
  end

  def update
    if Gosu.button_down? Gosu::KB_D
      @x += @@speed
    elsif Gosu.button_down? Gosu::KB_A
      @x -= @@speed
    end
    if Gosu.button_down? Gosu::KB_S
      @y += @@speed
    elsif Gosu.button_down? Gosu::KB_W
      @y -= @@speed
    end

    if @x < 0
      @x = 0
    elsif @x >= Main::Width - 10
      @x = Main::Width - 10
    end
    if @y < 0
      @y = 0
    elsif @y >= Main::Height - 10
      @y = Main::Height - 10
    end
  end
end

class Main < Gosu::Window
  Width = 500
  Height = 500

  @@tick = 0

  def initialize
    super Width, Height
    @player = Player.new Width / 2 - 5, Height / 2 - 5, 10, 10, Gosu::Color::WHITE
    @mobs = []
    generate_prize
  end

  def generate_prize
    @prize = Thing.new Random.rand(Width), Random.rand(Height), 10, 10, Gosu::Color::RED
  end

  def update
    @player.update
    if collided @player, @prize
      generate_prize
    end

    @mobs.each do |mob|
      mob.update
      if collided mob, @player
        reset
      elsif not collided mob, OpenStruct.new( x: 0, y: 0, w: Width, h: Height )
        @mobs.delete mob
      end
    end

    Mob::speed_up
    Player::speed_up

    if @@tick % 10 == 0
      @mobs.push generate_mob
    end

    @@tick += 1
  end

  def draw
    @player.draw
    @mobs.each { |mob| mob.draw }
    @prize.draw
  end

  def reset
    @player.reset
    @mobs = []
    generate_prize
  end

  def generate_mob
    direction = [:up, :down, :left, :right].sample
    case direction
    when :right
      x = -10
      y = Random.rand(Height)
    when :down
      x = Random.rand(Width)
      y = -10
    when :left
      x = Width
      y = Random.rand(Height)
    when :up
      x = Random.rand(Width)
      y = Height
    end
    return Mob.new(
      x, y,
      10, 10, random_color(),
      direction
    )
  end
end

def random_color()
  return Gosu::Color.new(255, Random.rand(255), Random.rand(255), Random.rand(255))
end

def collided(thing1, thing2)
  return (thing1.x < thing2.x + thing2.w and
          thing2.x < thing1.x + thing1.w and
          thing1.y < thing2.y + thing2.h and
          thing2.y < thing1.y + thing1.h)
end

Main.new.show
