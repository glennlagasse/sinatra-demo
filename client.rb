#!/usr/bin/env ruby

require 'http'
require 'thor'

class UserAPI
  def initialize
    @URL = "localhost:4567"
  end

  def get_users
    response = HTTP.get("http://#{@URL}/users")

    users = JSON.parse(response.body).sort_by{ |e| e['username'].to_s }
    users.each do |user|
      puts "Username: " + user['username']
      puts "  Id: " + user['_id']['$oid']
      puts "  Created at: " + user['created_at']
      puts "  Updated at: " + user['updated_at']
    end
  end

  def get_user(name)
    response = HTTP.get("http://#{@URL}/users/#{name}")

    re = JSON.parse(response.body)
    re.each do |resp|
      puts "username: " + resp['username']
      puts "  id: " + resp['_id']['$oid']
      puts "  created at: " + resp['created_at']
      puts "  updated at: " + resp['updated_at']
    end
  end

  def delete_user(name)
    response = HTTP.delete("http://#{@URL}/users/#{name}")

    unless response.code == 204
      resp = JSON.parse(response.body)
      puts resp
    end

    puts response.code if resp.nil?
  end

  def create_user(name)
    response = HTTP.post("http://#{@URL}/users", params: {username: "#{name}"})

    puts response.code

    resp = JSON.parse(response.body)
    puts resp
  end
end

class Commands < Thor
  desc "get_users", "Gets all users"
  def get_users
    UserAPI.new.get_users
  end

  desc "get_user", "Get a user by name"
  def get_user(name)
    UserAPI.new.get_user(name)
  end

  desc "delete_user", "Delete a user by name"
  def delete_user(name)
    UserAPI.new.delete_user(name)
  end

  desc "create_user", "Create a user"
  def create_user(name)
    UserAPI.new.create_user(name)
  end
end

Commands.start
