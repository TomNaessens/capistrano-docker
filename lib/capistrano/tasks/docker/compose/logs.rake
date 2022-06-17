namespace :docker do
  namespace :compose do
    namespace :logs do
      desc "logs"
      task :all, :service do |_, args|
        on roles(fetch(:docker_role)) do
          execute fetch(:docker_command), "logs", container_id(args[:service])
        end
      end

      task :tail, :service do |_, args|
        on roles(fetch(:docker_role)) do
          execute fetch(:docker_command), "logs", "--tail=50", container_id(args[:service])
        end
      end

      desc "follow logs"
      task :follow, :service do |_, args|
        on roles(fetch(:docker_role)) do
          execute fetch(:docker_command), "logs", "--follow", container_id(args[:service])
        end
      end
    end
  end
end

