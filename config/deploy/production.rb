# Production server configuration
server "85.31.233.192", user: "deploy", roles: %w[app db web]

# Enable SSH agent forwarding so deploy user can use your local SSH keys to access GitHub
set :ssh_options, {
  forward_agent: true,
  auth_methods: %w[publickey]
}
