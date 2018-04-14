#!/usr/bin/env ruby

require 'io/console'

class Editor
  def initialize
    lines = File.readlines('test.txt').map do |line|
      line.sub(/\n$/, '')
    end
    @buffer = Buffer.new(lines)
    @cursor = Cursor.new
  end

  def run
    IO.console.raw do
      loop do
        render
        handle_input
      end
    end
  rescue
    50.times { puts }
    raise
  end

  private

  def render
    ANSI.clear_screen
    ANSI.move_cursor(0, 0)
    @buffer.render
    ANSI.move_cursor(@cursor.row, @cursor.column)
  end

  def handle_input
    char = $stdin.getc
    case char
    when "\C-q" then exit(0)
    when "\C-p" then @cursor = @cursor.up(@buffer)
    when "\C-n" then @cursor = @cursor.down(@buffer)
    when "\C-b" then @cursor = @cursor.left(@buffer)
    when "\C-f" then @cursor = @cursor.right(@buffer)
    when "\r"
      @buffer.split_line(@cursor.row, @cursor.column)
      @cursor = @cursor.down(@buffer).move_to_column(0)
    when 127.chr
      if @cursor.column > 0
        @buffer = @buffer.delete(@cursor.row, @cursor.column - 1)
        @cursor = @cursor.left(@buffer)
      end
    else
      @buffer = @buffer.insert(char, @cursor.row, @cursor.column)
      @cursor = @cursor.right(@buffer)
    end
  end
end

class Buffer
  def initialize(lines)
    @lines = lines
  end

  def insert(char, row, column)
    lines = @lines.map(&:dup)
    lines.fetch(row).insert(column, char)
    Buffer.new(lines)
  end

  def delete(row, column)
    lines = @lines.map(&:dup)
    lines.fetch(row).slice!(column)
    Buffer.new(lines)
  end

  def split_line(row, column)
    lines = @lines.map(&:dup)
    line = lines.fetch(row)
    lines[row..row] = [line[0...column], line[column..-1]]
    Buffer.new(lines)
  end

  def render
    @lines.each do |line|
      $stdout.write("#{line}\r\n")
    end
  end

  def lines_count
    @lines.count
  end

  def line_length(row)
    @lines.fetch(row).length
  end
end

class Cursor
  attr_reader :row, :column

  def initialize(row = 0, column = 0)
    @row = row
    @column = column
  end

  def up(buffer)
    Cursor.new(row - 1, column).clamp(buffer)
  end

  def down(buffer)
    Cursor.new(row + 1, column).clamp(buffer)
  end

  def left(buffer)
    Cursor.new(row, column - 1).clamp(buffer)
  end

  def right(buffer)
    Cursor.new(row, column + 1).clamp(buffer)
  end

  def move_to_column(new_column)
    Cursor.new(row, new_column)
  end

  protected

  def clamp(buffer)
    clamped_row = row.clamp(0, buffer.lines_count - 1)
    clamped_column = column.clamp(0, buffer.line_length(clamped_row))
    Cursor.new(clamped_row, clamped_column)
  end
end

class ANSI
  def self.clear_screen
    $stdout.write("\e[2J")
  end

  def self.move_cursor(row, column)
    $stdout.write("\e[#{row + 1};#{column + 1}H")
  end
end

Editor.new.run
