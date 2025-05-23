SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_filter '/.kitchen/'
  add_filter '/test/'
  add_group 'Libraries', 'libraries'
  add_group 'Resources', 'resources'
  add_group 'Recipes', 'recipes'
  minimum_coverage 80
  
  # Use HTML formatter for better readability
  formatter SimpleCov::Formatter::HTMLFormatter
end

