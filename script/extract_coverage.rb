#!/usr/bin/env ruby
require 'json'

# Read coverage report from xcov
coverage_file = './coverage_output/report.json'

if File.exist?(coverage_file)
  begin
    data = JSON.parse(File.read(coverage_file))
    
    # Extract overall coverage percentage
    coverage_percentage = data['coverage'] ? (data['coverage'] * 100).round(1) : 0.0
    
    # Determine badge color based on coverage
    color = case coverage_percentage
            when 0...60 then 'red'
            when 60...80 then 'yellow'  
            when 80..100 then 'green'
            else 'lightgrey'
            end
    
    puts "Coverage: #{coverage_percentage}%"
    puts "Color: #{color}"
    
    # Output for GitHub Actions
    puts "::set-output name=coverage::#{coverage_percentage}%"
    puts "::set-output name=color::#{color}"
    
    # Save coverage for reference
    File.write('coverage.txt', "#{coverage_percentage}%")
    
  rescue JSON::ParserError => e
    puts "Error parsing coverage report: #{e.message}"
    puts "::set-output name=coverage::unknown"
    puts "::set-output name=color::lightgrey"
    File.write('coverage.txt', "unknown")
  end
else
  puts "Coverage report not found at: #{coverage_file}"
  puts "::set-output name=coverage::unknown"
  puts "::set-output name=color::lightgrey"
  File.write('coverage.txt', "unknown")
end