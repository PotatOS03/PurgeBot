# Purge Bot

Created by A. Clemens

## Description

This tool, intended for use by the OSU Running Club Archivist, helps the user manage members in a GroupMe group chat in which they are an admin.
The purge removes members according to a list of who can stay. Anyone currently in the group but not on the list gets removed.

## Installation instructions

### Required versions

- [Ruby 3.4.5](https://www.ruby-lang.org/en/downloads/)

### Downloading

- Clone this repository
- Open the code in your preferred code editor

### Configuration

- Obtain your GroupMe API token by logging in and following the tutorial at <https://dev.groupme.com>
- Rename or copy **.env.template** to **.env** and paste your token where it says **AUTHORIZATION_TOKEN**
- In the terminal, from the purge_bot repository, run `bundle install`

## Setup

### Obtaining group ID

- Open **find_group_id.rb**
- Copy the name of the GroupMe group you are purging
- On line 8, paste the name into the *group_name* string
- In the terminal, run `ruby find_group_id.rb`
- If the group is found, its ID will be printed in the terminal
- Optional: If no group is found, you may change *show_groups* on line 11 to true
- Open **purge.rb**
- Paste the group ID into the *group_id* string on line 8

### Listing members

- Get the list of full names of people who are allowed to stay in the group. Include preferred names as well
- Open **purge.rb**
- Format the list and paste it into *raw_names* on line 13 as described in the code

### Preparing for the purge

- Ensure that the `res = Net::HTTP.post(uri, nil)` line on line 98 is commented (has a # at the beginning)
- In the terminal, run `ruby purge.rb`
- Once the code has run, check the report printed in the terminal for any wrongly removed members or other discrepancies
- If there are wrongly removed members, fix this by editing the `accepted_names.map! do |name|` code block starting at line 20 to include those members' GroupMe names
- Keep repeating the previous 3 steps until you are satisfied with the results of the purge

## Executing the purge

- In **purge.rb**, uncomment the `res = Net::HTTP.post(uri, nil)` line
- In the terminal, run `ruby purge.rb`
