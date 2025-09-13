require 'uri'
require 'net/http'
require 'json'
require 'dotenv/load'
require 'dotenv'

# EDIT: Paste the GroupMe ID for the group you are purging from
group_id = ''

# EDIT: List of names of GroupMe members that are allowed to stay in the group
# If a member's name or nickname is not in this list, they will be removed
# String should be formatted with each name separated by a comma. Case-insensitive, trailing comma allowed
raw_names = ""

accepted_names = raw_names.split(',').map(&:downcase)

# EDIT: If someone's "raw name" is spelled in a different way than their GroupMe name or nickname,
# you can fix it here as long as you know who is who.
# This often happens if someone doesn't use their full name in GroupMe
accepted_names.map! do |name|
  case name
  when 'raw name'
    'groupme name'
  when 'another incorrect raw name'
    'their groupme name'
  # Continue the pattern for as many names as you need to fix

  # Make sure this stays at the end:
  else
    name
  end
end

# Print the number of accepted names
puts "Accepted names: #{accepted_names.length}"

# Used for API calls
base_uri = "https://api.groupme.com/v3/groups/#{group_id}"
uri = URI(base_uri)

# Load the GroupMe token from the .env file
dotenv_path = '.env'
Dotenv.load(dotenv_path)
groupme_token = ENV['GROUPME_TOKEN']

params = { token: groupme_token }
uri.query = URI.encode_www_form(params)

# Make the API request to get the list of members in the group
res = Net::HTTP.get_response(uri)

if res.code == '401'
  puts 'Could not load members. Make sure your GroupMe token is in a .env file.'
  exit
elsif res.code == '500'
  puts 'Could not find group. Make sure the group ID is pasted in group_id at the top of this code.'
  exit
end

# Parse the response and get the list of members
members = JSON.parse(res.body)['response']['members']

# Track the number of removed members and those who are kept
total_members = members.length
removed_members = 0
kept_names = []

puts "Total members: #{total_members}"

# Iterate through the list of members
members.each do |member|
  nickname = member['nickname'].downcase
  username = member['name'].downcase

  # Skip members that are in the accepted_names list
  if accepted_names.include?(nickname)
    kept_names << nickname
    next
  end

  if accepted_names.include?(username)
    kept_names << username
    next
  end

  # Only consider members with the role 'user'
  next unless member['roles'] == ['user']

  name = username
  name = "#{name} / #{nickname}" if nickname != name

  # Remove the member from the group
  member_id = member['id']
  uri = URI("#{base_uri}/members/#{member_id}/remove")
  uri.query = URI.encode_www_form(params)

  # EDIT: Uncomment this next line to actually remove the member. Do not do this until you have tested and everything works!
  # res = Net::HTTP.post(uri, nil)

  puts "Removed: #{name}"
  removed_members += 1
end

puts "\n\n"
puts "Total members before removal: #{total_members}"
puts "Removed members: #{removed_members}"
puts "Remaining members: #{total_members - removed_members}"
puts "Accepted names: #{accepted_names.length}"
puts "#{accepted_names.length - total_members + removed_members} members were wrongly removed? Double check:\n"
puts accepted_names - kept_names
