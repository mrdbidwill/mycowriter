# config valid for current version and patch releases of Capistrano
lock "~> 3.20.0"

set :application, "mycowriter"
set :repo_url, "git@github.com:mrdbidwill/mycowriter.git"

set :branch, ENV.fetch("BRANCH", "main")

# Default deploy_to directory
set :deploy_to, "/opt/mycowriter"

set :rbenv_type, :user
set :rbenv_ruby, "3.4.3"

# Puma configuration
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

# Linked files and directories
append :linked_files, "config/master.key", "config/credentials.yml.enc", ".env"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"

# Keep last 5 releases
set :keep_releases, 5

# Use systemd to restart Puma instead of capistrano-puma's restart
after "deploy:published", "systemd_puma:restart"

# Custom tasks to manage Puma via systemd
namespace :systemd_puma do
  desc 'Install Puma systemd service'
  task :install_service do
    on roles(:app) do
      execute :sudo, :cp, "#{release_path}/config/puma.service", "/etc/systemd/system/puma-mycowriter.service"
      execute :sudo, :systemctl, "daemon-reload"
      execute :sudo, :systemctl, "enable", "puma-mycowriter.service"
    end
  end

  desc 'Start Puma via systemd'
  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, "start", "puma-mycowriter.service"
    end
  end

  desc 'Stop Puma via systemd'
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, "stop", "puma-mycowriter.service"
    end
  end

  desc 'Restart Puma via systemd'
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, "restart", "puma-mycowriter.service"
    end
  end

  desc 'Check Puma systemd service status'
  task :status do
    on roles(:app) do
      execute :sudo, :systemctl, "status", "puma-mycowriter.service"
    end
  end

  desc 'Show Puma systemd service logs'
  task :logs do
    on roles(:app) do
      execute :sudo, :journalctl, "-xeu", "puma-mycowriter.service", "--no-pager", "-n", "50"
    end
  end

  desc 'Show Puma stderr log file'
  task :stderr do
    on roles(:app) do
      execute :tail, "-n", "50", "#{shared_path}/log/puma_stderr.log"
    end
  end

  desc 'Show Puma stdout log file'
  task :stdout do
    on roles(:app) do
      execute :tail, "-n", "50", "#{shared_path}/log/puma_stdout.log"
    end
  end

  desc 'Verify Puma is running and responding'
  task :verify do
    on roles(:app) do
      info "Waiting 10 seconds for Puma to fully start..."
      sleep 10

      info "Checking if Puma process is running..."
      execute "ps aux | grep '[p]uma' || (echo 'ERROR: Puma process not found' && exit 1)"

      info "Checking if Puma is responding to requests..."
      # Check the Unix socket directly with retry logic
      max_attempts = 3
      attempt = 0
      success = false

      max_attempts.times do |i|
        attempt = i + 1
        begin
          execute "curl --unix-socket #{shared_path}/tmp/sockets/puma.sock http://localhost/ -f -s -o /dev/null"
          success = true
          break
        rescue SSHKit::Command::Failed
          info "Attempt #{attempt} failed..."
          sleep 2 unless attempt == max_attempts
        end
      end

      unless success
        error "ERROR: Puma not responding on socket after #{max_attempts} attempts"
        exit 1
      end

      info "✓ Puma is running and responding successfully"
    end
  end
end

# Add verification after restart
after "systemd_puma:restart", "systemd_puma:verify"

# Override cleanup task to ignore permission errors on bootsnap cache files
Rake::Task["deploy:cleanup"].clear_actions
namespace :deploy do
  desc 'Clean up old releases (ignore permission errors)'
  task :cleanup do
    on release_roles :all do |host|
      releases = capture(:ls, '-xtr', releases_path).split
      if releases.count >= fetch(:keep_releases)
        info t(:keeping_releases, host: host.to_s, keep_releases: fetch(:keep_releases), releases: releases.count)
        directories = (releases - releases.last(fetch(:keep_releases)))
        if directories.any?
          directories.each do |release|
            # Delete each directory individually and ignore permission errors
            begin
              execute :rm, '-rf', releases_path.join(release)
            rescue SSHKit::Command::Failed => e
              # Silently ignore permission denied errors during cleanup
              warn "Some files in #{release} could not be deleted (permission denied), skipping..."
            end
          end
        else
          info t(:no_old_releases, host: host.to_s, keep_releases: fetch(:keep_releases))
        end
      end
    end
  end
end
