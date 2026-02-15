namespace :db do
  desc "Import mb_lists data from mrdbid database"
  task import_mb_lists: :environment do
    puts "Using direct SQL dump approach for faster import..."

    # Get credentials from environment
    username = ENV['MYSQL_USER'] || 'mrdbid_user'
    password = ENV['MYSQL_PASSWORD']
    host = ENV['DB_HOST'] || '127.0.0.1'

    puts "Dumping mb_lists table from mrdbid_development..."
    dump_file = Rails.root.join('tmp', 'mb_lists_dump.sql')

    # Dump only the data (no structure) from mrdbid database
    dump_cmd = "mysqldump -u #{username} -p'#{password}' -h #{host} " \
               "--no-create-info --skip-triggers --compact " \
               "mrdbid_development mb_lists > #{dump_file}"

    system(dump_cmd)

    if File.exist?(dump_file)
      puts "Import file created: #{dump_file}"
      puts "File size: #{File.size(dump_file) / 1024 / 1024}MB"

      puts "Importing into mycowriter_development..."
      import_cmd = "mysql -u #{username} -p'#{password}' -h #{host} " \
                   "mycowriter_development < #{dump_file}"

      system(import_cmd)

      puts "Cleaning up dump file..."
      File.delete(dump_file)

      puts "Import complete!"
      puts "Record count: #{MbList.count}"
    else
      puts "ERROR: Dump file was not created. Check mysqldump command."
    end
  end
end
