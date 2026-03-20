namespace :load_test do
  desc "Create N confirmed test users and output their magic link tokens as JSON"
  task :generate_users, [:count] => :environment do |_, args|
    count = (args[:count] || 10).to_i
    users = []

    count.times do |i|
      email = "loadtest+#{i}@example.com"
      user = User.find_or_initialize_by(email: email)

      if user.new_record?
        profile = Profile.new
        user.main_profile = profile
        user.skip_confirmation!
        user.save!
      elsif user.confirmed_at.nil?
        user.skip_confirmation!
        user.save!
      end

      token = user.encode_passwordless_token
      users << { email: email, token: token }
    end

    puts JSON.generate(users)
  end

  desc "Run generate_users on the server via Kamal and save tokens to load_tests/users.json"
  task :fetch_users, [:count] => [] do |_, args|
    count = (args[:count] || 10).to_i
    output_path = File.expand_path("../../load_tests/users.json", __dir__)
    json = `kamal app exec --reuse 'rails load_test:generate_users[#{count}]'`
    # kamal may print non-JSON lines (progress output) before the actual JSON
    json_line = json.lines.find { |l| l.strip.start_with?("[") }
    abort "ERROR: could not find JSON in kamal output:\n#{json}" unless json_line
    File.write(output_path, json_line.strip)
    puts "Saved #{count} users to #{output_path}"
  end

  desc "Destroy all load test users (emails matching loadtest+*@example.com)"
  task cleanup: :environment do
    deleted = User.where("email LIKE ?", "loadtest+%@example.com").destroy_all
    puts "Deleted #{deleted.count} load test users."
  end
end
