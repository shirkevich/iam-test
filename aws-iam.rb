require 'rubygems'
require 'bundler/setup'
require 'optparse'
require 'aws-sdk'
require 'json'

iam = Aws::IAM::Client.new(:region => 'eu-west-1')

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: aws-iam.rb [options]"

  opts.on('-o', '--omit', 'Omit users without keys') { |v| options[:omit] = v }
end.parse!

users = {}
iam.list_users.users.each do |user|
  keys = []
  iam.list_access_keys({user_name: user.user_name}).access_key_metadata.each do |key|
    keys << key.access_key_id
  end
  users[user.user_name] = keys unless options[:omit] && keys.empty?
end

puts JSON.generate(users)

