# these generators are backed by rails' generators
require "rails/generators"
require "standalone_migrations/configurator"

module StandaloneMigrations
  class Generator
    def self.migration(name, options="")
      generator_params = [name] + options.split(" ")
      Rails::Generators.invoke "active_record:migration", generator_params,
        :destination_root => Rails.root
      move_migration name
    end

    def self.move_migration(name)
      default_migrate_dir = 'db/migrate'
      return if current_migration_dir == default_migrate_dir

      Dir.glob("#{default_migrate_dir}/*_#{name}.rb").each do |migration|
        new_path = File.join(current_migration_dir, migration)
        begin
          if migration_exists?(name, new_path)
            raise "A migration already exists by the name of #{name}"+
                      " for the DB source #{ENV['SOURCE']}"
          else
            FileUtils.mv migration, new_path
          end
        ensure
          FileUtils.rm_rf default_migrate_dir
        end
      end
    end
    private_class_method :move_migration

    def self.current_migration_dir
      begin
        Configurator.new.migrate_dir
      rescue
        'db/migrate'
      end
    end
    private_class_method :current_migration_dir

    def self.migration_exists?(name, path)
      Dir.glob("#{File.dirname(path)}/*_#{name}.rb").each do |existing_file|
        if File.basename(existing_file) =~ /^\d+_#{name}.rb$/
          return true
        end
      end
      false
    end
    private_class_method :migration_exists?
  end
end
