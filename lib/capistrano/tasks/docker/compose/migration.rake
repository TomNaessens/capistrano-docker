namespace :docker do
  namespace :compose do
    namespace :db do
      desc "migrates"
      task :migrate, :service do |_, args|
        on roles(fetch(:docker_role)) do
          service = args[:service] || fetch(:docker_compose_migrate_service)

          execute fetch(:docker_command), "exec", container_id(service), "bundle exec", fetch(:docker_migrate_command)
        end
      end
    end
  end
end

after "docker:deploy:compose:start", "docker:compose:db:migrate"
