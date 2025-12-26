require 'rake/clean'

CLEAN.include('*.gem', 'pkg')

desc 'Construir la gema'
task :build do
  sh 'gem build ongaku-player.gemspec'
end

desc 'Instalar la gema localmente'
task install: :build do
  gem_file = Dir['ongaku-player-*.gem'].first
  sh "gem install #{gem_file} --no-document"
  puts "\n✅ Ongaku Player instalado!"
  puts "Ejecuta: ongaku"
end

desc 'Desinstalar la gema'
task :uninstall do
  sh 'gem uninstall ongaku-player -x'
end

desc 'Ejecutar el reproductor en modo desarrollo'
task :run do
  sh 'ruby -Ilib bin/ongaku'
end

desc 'Ejecutar en modo demo'
task :demo do
  sh 'DEMO_MODE=1 ruby -Ilib bin/ongaku'
end

desc 'Probar búsqueda'
task :test_search do
  sh 'ruby test_search.rb'
end

desc 'Probar búsqueda por tags'
task :test_tags do
  sh 'ruby test_tags.rb'
end

desc 'Mostrar demo visual'
task :show_demo do
  sh 'ruby demo.rb'
end

desc 'Limpiar y reinstalar'
task reinstall: [:clean, :uninstall, :install]

task default: :run
