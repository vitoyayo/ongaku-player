require 'rake/clean'

CLEAN.include('*.gem', 'pkg')

desc 'Build the gem'
task :build do
  sh 'gem build ongaku-player.gemspec'
end

desc 'Install the gem locally'
task install: :build do
  gem_file = Dir['ongaku-player-*.gem'].first
  sh "gem install #{gem_file} --no-document"
  puts "\n✅ Ongaku Player installed!"
  puts "Run: ongaku"
end

desc 'Uninstall the gem'
task :uninstall do
  sh 'gem uninstall ongaku-player -x'
end

desc 'Run the player in development mode'
task :run do
  sh 'ruby -Ilib bin/ongaku'
end

desc 'Run in demo mode'
task :demo do
  sh 'DEMO_MODE=1 ruby -Ilib bin/ongaku'
end

desc 'Test search'
task :test_search do
  sh 'ruby test_search.rb'
end

desc 'Test tag search'
task :test_tags do
  sh 'ruby test_tags.rb'
end

desc 'Show visual demo'
task :show_demo do
  sh 'ruby demo.rb'
end

desc 'Clean and reinstall'
task reinstall: [:clean, :uninstall, :install]

task default: :run
