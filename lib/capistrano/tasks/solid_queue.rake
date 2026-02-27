# frozen_string_literal: true

namespace :solid_queue do
  desc 'Restart SolidQueue'
  task :restart do
    on roles :app do
      execute :sudo, :systemctl, :restart, 'solid_queue.service'
    end
  end
end
