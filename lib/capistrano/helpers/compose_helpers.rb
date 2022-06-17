def container_id(service=fetch(:docker_compose_default_service))
  service = fetch(:docker_compose_default_service) if service.nil?

  id = capture fetch(:docker_command), "ps", "-a", "--filter 'name=#{fetch(:docker_compose_project_name)}.*#{service}'", "--format='{{.ID}}'"

  raise "No container found in #{fetch(:docker_compose_project_name)} for service #{service}. Specify a specific service using `bundle exec cap production 'task[service_name]`." if id == ""

  id
end
