lock "~> 3.11.0"

# Es el stage de la aplicación, obviamente producción
set :stage, 'production'
# Nombre de la aplicación
set :application, "test_capistrano"
# URL de la aplicación en git (github, bitbucket, etc). DEBE SER SSH
set :repo_url, "git@github.com:danielVargas/test-capistrano.git"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Indica el directorio donde se dejará la aplicación
set :deploy_to, "/var/www/html/test_capistrano"
# Variables de entorno necesarias para el despliegue con RVM
set :rvm_type, :user
set :rvm_ruby_version, '2.5.3'
set :rvm_binary, '~/.rvm/bin/rvm'
set :rvm_bin_path, "$HOME/bin"
set :default_env, { rvm_bin_path: '~/.rvm/bin' }
set :user, "ubuntu"
set :use_sudo, false
set :deploy_via, :copy
#############################################################

set :format, :pretty
set :rails_env, fetch(:stage)

# Default value for :pty is false
set :pty, false

# Número de releases de la aplicación que capistrano guardará como respaldo
set :keep_releases, 3

# Indica directorios de la aplicación que se deberán conservar con cada deploy nuevo
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

# Variables de entorno para passenger
set :passenger_environment_variables, { :path => '/usr/lib/ruby/vendor_ruby/phusion_passenger/bin:$PATH' }
set :passenger_restart_command, '/usr/lib/ruby/vendor_ruby/phusion_passenger/bin/passenger-config restart-app'

namespace :deploy do
  ## Tarea que pregunta por la rama desde la cúal se hará el despliegue
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  # Tarea que se ejecuta luego de el despliegue, para:
  # - Instalar gemas
  # - Dar permisos de directorios
  # - Crear bases de datos y correr migraciones
  # - Compilar los assets en producción
  # - Reiniciar el servidor
  # Toma en cuenta que aqui puedes correr practicamente cuaquier comando que se te ocurra
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle, 'install'
        execute :chmod, '777 '+release_path.join('tmp/cache/').to_s
        execute :chmod, '777 '+release_path.join('log/').to_s
        execute :rake, 'db:create RAILS_ENV=production'
        execute :rake, 'db:migrate RAILS_ENV=production'
        execute :rake, 'assets:precompile RAILS_ENV=production'
        execute 'sudo service apache2 restart'
      end
    end
  end
   
  ## Callbacks de las tareas definidas anteriormente
  before :starting,     :check_revision
  after  :finishing,    :restart
end
