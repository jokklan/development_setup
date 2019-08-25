
namespace :heroku do
  namespace :db do
    desc 'Capture the database on heroku'
    task :capture do
      system('heroku pg:backups:capture --remote production')
    end

    desc 'Download the database from heroku'
    task :download do
      # Remove old db dump if it exists
      system('test -e latest.dump && rm -f latest.dump')
      system('heroku pg:backups:download --remote production')
    end

    desc 'Restore the downloaded dump locally'
    task :restore do
      ENV['RAILS_ENV'] = 'development'

      db_config = Rails.configuration.database_configuration['development']
      db_name = db_config['database']
      system(%(psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = current_database() AND pid <> pg_backend_pid();" -d '#{db_name}'))

      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke

      # Restore the latest.dump file to development database
      system("pg_restore --verbose --clean --no-acl --no-owner -h localhost -d #{db_name} latest.dump")

      Rake::Task['db:environment:set'].invoke
    end

    desc 'Restore the downloaded dump locally'
    task :download_and_restore, [:capture] do |_task, args|
      Rake::Task['heroku:db:capture'].invoke if args.capture.present?

      Rake::Task['heroku:db:download'].invoke
      Rake::Task['heroku:db:restore'].invoke
    end

    desc 'Transfer latest capture to staging'
    task :transfer_to_staging, [:capture] do |_task, args|
      Rake::Task['heroku:db:capture'].invoke if args.capture.present?

      system('heroku pg:backups restore $(heroku pg:backups public-url --remote production) DATABASE_URL --remote staging')
    end
  end
end
