module Jokklan
  module DevelopmentSetup
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/heroku/database.rake'
      end
    end
  end
end
