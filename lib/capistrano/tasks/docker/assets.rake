namespace :docker do
  namespace :assets do
    task :precompile do
      next unless fetch(:docker_assets_precompile)

      on roles(fetch(:docker_role)) do
        execute :docker, task_command(fetch(:docker_assets_precompile_command))
      end
    end

    task :copy_to_host do
      next unless fetch(:docker_assets_copy_to_host)

      on roles(fetch(:docker_role)) do
        cmd = ["cp"]
        cmd << "#{fetch(:docker_current_container)}:#{fetch(:docker_rails_root)}/public"
        cmd << "#{shared_path}"
        execute :docker, cmd.join(" ")
      end
    end

    task :symlink_from_shared_to_public do
      on roles(fetch(:docker_role)) do
        fetch(:docker_symlink_from_shared_to_public).each do |dir|
          execute :ln, "-sf", "#{shared_path}/#{dir}", "#{shared_path}/public"
        end
      end
    end
  end
end

before "docker:deploy:default:run", "docker:assets:precompile"
after "docker:deploy:default:run", "docker:assets:copy_to_host"
after "docker:assets:copy_to_host", "docker:assets:symlink_from_shared_to_public"
