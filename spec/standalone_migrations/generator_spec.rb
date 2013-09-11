require 'spec_helper'
require 'rspec/mocks'
require 'rspec/mocks/standalone'

module StandaloneMigrations
  describe Generator do

    describe "moving migration file to database sub directory" do

      let(:test_migration_name) {'foo'}

      let(:test_migration_file) do
        "db/default/migrate/123_#{test_migration_name}.rb"
      end

      before do
        Generator.stub(:current_migration_dir).and_return('db/default/migrate')
        @directory_array = double
        @directory_array.stub(:each).and_yield(test_migration_file)
        Dir.stub(:glob).and_return(@directory_array)
        FileUtils.stub(:mv)
        FileUtils.stub(:rm_rf)
      end

      it "moves migrations when they don't already exist" do
        Generator.stub(:migration_exists?).
            with(test_migration_name, test_migration_file).
            and_return(false)
        Generator.send(:move_migration, test_migration_name)
      end

      it "raises an error when a migration already exists" do
        Generator.stub(:migration_exists?).
            with(test_migration_name, test_migration_file).
            and_return(true)
        -> {Generator.send(:move_migration, test_migration_name)}.
            should raise_error(RuntimeError)
      end

    end

  end
end