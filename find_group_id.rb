require 'uri'
require 'net/http'
require 'json'
require 'dotenv/load'
require 'dotenv'

# EDIT: Enter the name of the group
group_name = ''

# EDIT: Choose whether to show all of your groups during search
show_groups = false

# Used for API calls
base_uri = "https://api.groupme.com/v3/groups"
uri = URI(base_uri)

# Loads the GroupMe token from the .env file
dotenv_path = '.env'
Dotenv.load(dotenv_path)
access_token = ENV['GROUPME_TOKEN']

# Get a page of up to 10 groups that you are in
def get_groups(uri, access_token, page_num)
  params = { token: access_token, omit: 'memberships', page: page_num }
  uri.query = URI.encode_www_form(params)

  # Make the API request to get the list groups you are in
  res = Net::HTTP.get_response(uri)

  if res.code == '401'
    puts 'Could not load groups. Make sure your GroupMe token is in a .env file'
    exit
  end

  # Parse the response
  JSON.parse(res.body)['response'].map{ |g| g.slice('id', 'name') }
end

# Find the group you are in with a specific name
def find_group(uri, access_token, group_name, show_groups)
  page_num = 1
  group = nil
  groups = get_groups(uri, access_token, page_num)

  while group.nil? && !groups.empty?
    groups = get_groups(uri, access_token, page_num)
    puts groups.map{ |g| "ID: #{g['id']} \tName: #{g['name']}"} if show_groups
    group = groups.find{ |g| g['name'] == group_name }
    page_num += 1
  end

  group
end

group = find_group(uri, access_token, group_name, show_groups)

if group.nil?
  puts 'Could not find group. Make sure the name is copied properly.'
else
  puts "Group ID: #{group['id']}"
end