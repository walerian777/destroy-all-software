#!/usr/bin/env ruby

require 'io/console'

class Editor
  def initialize
    lines = File.readlines('test.txt').map do |line|
      line.sub(/\n$/, '')
    end
    p lines
  end

  def run
    IO.console.raw do
      loop do
        render
        handle_input
      end
    end
  end

  private

  def render
    clear_screen
    move_cursor(0, 0)
  end

  def handle_input
    char = $stdin.getc
    case char
    when "\C-q" then exit(0)
    end
  end

  def clear_screen
  end

  def move_cursor(x, y)
  end
end

class Buffer
end

class Cursor
end

Editor.new.run
