Capistrano::Configuration.instance(:must_exist).load do |configuration|

  _cset(:foreman_options, nil)
  _cset(:foreman_sudo, 'sudo')
  _cset(:foreman_upstart_path, '/etc/init/sites')
  _cset(:foreman_upstart_prefix, '')

  namespace :foreman do
    desc "Export the Procfile to Ubuntu's upstart scripts"
    task :export, roles: :app do
      run "if [[ -d #{foreman_upstart_path} ]]; then #{foreman_sudo} mkdir -p #{foreman_upstart_path}; fi"
      run "cd #{current_path} && #{foreman_sudo} bundle exec foreman export upstart #{foreman_upstart_path} -a #{service_name} -u #{user} -l #{shared_path}/log #{foreman_options_cli}"
    end

    desc "Start the application services"
    task :start, roles: :app do
      sudo "service #{service_name} start"
    end

    desc "Stop the application services"
    task :stop, roles: :app do
      sudo "service #{service_name} stop"
    end

    desc "Restart the application services"
    task :restart, roles: :app do
      run "sudo service #{service_name} start || sudo service #{service_name} restart"
    end
  end

  def foreman_options_cli
    if foreman_options
      opt = foreman_options.map {|opt, value| "--#{opt}=#{value}" }
      opt.join(' ')
    end
  end

  def service_name
    "#{foreman_upstart_prefix}#{application}"
  end
  
end
