namespace :docker do
  namespace :compose do
    namespace :whenever do
      task :update, :service do |_, args|
        on roles(fetch(:docker_role)) do
          execute fetch(:docker_command), "exec", container_id(args[:service]), "bundle exec whenever --update-crontab"
          execute fetch(:docker_command), "exec", container_id(args[:service]), "service cron restart"
        end
      end

      task :logs, :service do |_, args|
        on roles(fetch(:docker_role)) do
          execute fetch(:docker_command), "exec", container_id(args[:service]), "cat #{File.join(fetch(:docker_rails_root), "log", "cron.log")}"
        end
      end
    end
  end
end

after "docker:deploy:compose:start", "docker:compose:whenever:update"
