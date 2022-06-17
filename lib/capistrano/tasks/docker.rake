namespace :docker do
  task :deploy do
    invoke 'docker:prepare_environment'

    if fetch(:docker_compose) == true
      invoke 'docker:deploy:compose'
    else
      invoke 'docker:deploy:default'
    end
  end

  task :prepare_environment do
    env = {}

    fetch(:docker_pass_env).each do |env_key|
      env[env_key] = ENV[env_key]
    end

    SSHKit.config.default_env.merge! env
  end

  task :current_revision do
    invoke "deploy:set_current_revision" unless fetch(:current_revision)
  end

  def build_command
    cmd = ["build"]
    cmd << "-t #{fetch(:docker_image_full)}"
    cmd << "-f `pwd -P`/#{fetch(:docker_dockerfile)}"
    cmd << "--pull" if fetch(:docker_pull) == true
    cmd << fetch(:docker_buildpath)

    cmd.join(" ")
  end

  def task_command(command)
    cmd = ["run"]

    # attach volumes
    fetch(:docker_volumes).each do |volume|
      cmd << "-v #{volume}"
    end

    # attach shared volumes
    fetch(:docker_shared_volumes).each do |volume|
      cmd << "-v #{File.join(shared_path, volume)}:#{File.join(fetch(:docker_rails_root), volume)}"
    end

    # attach shared to /shared
    cmd << "-v #{shared_path}:#{fetch(:docker_shared_path)}" if fetch(:docker_shared_path)

    # attach links
    fetch(:docker_links).each do |link|
      cmd << "--link #{link}"
    end

    # set custom apparmor profile
    cmd << "--security-opt apparmor:#{fetch(:docker_apparmor_profile)}" unless fetch(:docker_apparmor_profile).nil?

    cmd << "--env-file #{fetch(:docker_env_file)}" if fetch(:docker_env_file)
    cmd << fetch(:docker_additional_options)
    cmd << fetch(:docker_image_full)

    cmd << command

    cmd.join(" ")
  end
end

namespace :load do
  task :defaults do
    set :docker_current_container,    -> { "#{fetch(:application)}_#{fetch(:current_revision)}" }
    set :docker_previous_container,   -> { "#{fetch(:application)}_#{fetch(:previous_revision)}" }
    set :docker_role,                 -> { :web }
    set :docker_pull,                 -> { false }
    set :docker_dockerfile,           -> { "Dockerfile" }
    set :docker_buildpath,            -> { "." }
    set :docker_detach,               -> { true }
    set :docker_volumes,              -> { [] }
    set :docker_restart_policy,       -> { "unless-stopped" }
    set :docker_links,                -> { [] }
    set :docker_labels,               -> { [] }
    set :docker_image,                -> { "#{fetch(:application)}_#{fetch(:stage)}" }
    set :docker_image_full,           -> { [fetch(:docker_image), fetch(:current_revision)].join(":") }
    set :docker_apparmor_profile,     -> { nil }
    set :docker_additional_options,   -> { "" }
    set :docker_copy_data,            -> { [] }
    set :docker_pass_env,             -> { [] }
    set :docker_cpu_quota,            -> { nil }
    set :docker_clean_before_run,     -> { false }
    set :docker_env_file,             -> { nil }
    set :docker_command,              -> { "docker" }

    set :docker_compose_path,               -> { nil }
    set :docker_compose,                    -> { false }
    set :docker_compose_project_name,       -> { nil }
    set :docker_compose_remove_after_stop,  -> { true }
    set :docker_compose_remove_volumes,     -> { true }
    set :docker_compose_build_services,     -> { nil }
    set :docker_compose_command,            -> { "docker-compose" }
    set :docker_compose_default_service,    -> { "web" }
    set :docker_compose_migrate_service,    -> { fetch(:docker_compose_default_service) }

    # assets
    set :docker_rails_root,                    -> { ENV.fetch("RAILS_ROOT", "/app") }
    set :docker_shared_path,                   -> { ENV.fetch("DOCKER_SHARED_PATH", "/shared") }
    set :docker_assets_precompile,             -> { false }
    set :docker_assets_precompile_command,     -> { "rails assets:precompile" }
    set :docker_assets_copy_to_host,           -> { true }
    set :docker_symlink_from_shared_to_public, -> { [] }

    # migration
    set :docker_migrate_command,           -> { "rake db:migrate" }
    set :docker_db_create_command,         -> { "rake db:create" }

    # npm
    set :docker_npm_install_command,       -> { "npm install --production --no-spin"}

    # bower
    set :docker_bower_install_command,     -> { "bower install --production" }
  end
end
