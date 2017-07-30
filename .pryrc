require 'colorize'

def colorized_stack_trace( stack, base_dir )
  separator = File::SEPARATOR
  longest = stack.max_by(&:length).length
  number_of_colors = 5
  color_length = 5
  column_width = longest + number_of_colors * color_length

  stack.each do |line|
    # Example stack trace line for reference:
    # /path/to/file/file.rb:10000:in `some_function_name'
    file_path, line_number, location = line.split(':')
    pn = Pathname.new(file_path)
    path = pn.dirname.to_s.sub( base_dir, '' )
    file = pn.basename.to_s

    printf "    %-#{column_width}s %s\n",
      "#{path.light_red}#{separator.light_red}#{file.light_magenta}#{':'.green}#{line_number.cyan}",
      location
  end
end

def filtered_stack_trace( stack, filter )
  filtered = stack.grep( filter )
  if filtered.empty?
    puts "#{'The current stack trace doesn\'t contain any lines matching'.red} #{filter.to_s.light_red}#{'.'.red}"
    puts 'Type `sa` to see a full colorized stack trace, or `caller` to see the vanilla ruby full stack trace.'.red
    return
  end
  colorized_stack_trace( filtered, filter )
end

Pry::Commands.block_command "s", "Application stack trace" do
  separator = File::SEPARATOR
  pwd = Dir.pwd
  dir = /#{Regexp.escape( pwd )}#{Regexp.escape(separator)}?/
  filtered_stack_trace( caller, dir )
end

Pry::Commands.block_command "sa", "Application stack trace" do
  filtered_stack_trace( caller, /./ )
end

Pry::Commands.block_command "pbcopy", "Copy input to clipboard" do |input|
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  str
end

def h_o(input)
  f = Tempfile.new(['foo', '.html'])
  f.write(input)
  f.close
  `open #{f.path}`
end

def showme
  h_o(page.body)
end