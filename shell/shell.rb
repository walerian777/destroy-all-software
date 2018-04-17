#!/usr/bin/env ruby

require 'readline'
require 'parslet'

def main
  loop do
    cmdline = Readline.readline('> ', true)
    tree = parse_cmdline(cmdline)
    pids = tree.execute($stdin.fileno, $stdout.fileno)
    pids.each do |pid|
      Process.wait(pid)
    end
  end
end

def parse_cmdline(cmdline)
  raw_tree = Parser.new.parse(cmdline)
  Transform.new.apply(raw_tree)
end

class Parser < Parslet::Parser
  root(:cmdline)

  rule(:cmdline) { pipeline | command }
  rule(:pipeline) { command.as(:left) >> pipe.as(:pipe) >> cmdline.as(:right) }
  rule(:command) { arg.as(:arg).repeat(1).as(:command) }
  rule(:arg) { unquoted_arg | single_quoted_arg }
  rule(:unquoted_arg) { match[%q(^\s'|)].repeat(1) >> space? }
  rule(:single_quoted_arg) { str("'").ignore >> match["^'"].repeat(0) >> str("'").ignore >> space? }
  rule(:pipe) { str('|') >> space? }

  rule(:space) { match[%q(\s)].repeat(1).ignore }
  rule(:space?) { space.maybe }
end

class Transform < Parslet::Transform
  rule(left: subtree(:left), pipe: '|', right: subtree(:right)) { Pipeline.new(left, right) }
  rule(command: sequence(:args)) { Command.new(args) }
  rule(arg: simple(:arg)) { arg }
end

class Pipeline
  def initialize(left, right)
    @left = left
    @right = right
  end

  def execute(stdin, stdout)
    reader, writer = IO.pipe
    pids = @left.execute(stdin, writer.fileno) + @right.execute(reader.fileno, stdout)
    reader.close
    writer.close
    pids
  end
end

class Command
  def initialize(args)
    @args = args
  end

  def execute(stdin, stdout)
    [spawn(*@args, 0 => stdin, 1 => stdout)]
  end
end

main
