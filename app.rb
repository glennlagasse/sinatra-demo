# frozen_string_literal: true

require 'sinatra'
require 'mongoid'

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

# User Class
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String

  validates_uniqueness_of :username
end

get '/health' do
  content_type :json
  { healthy: true }.to_json
end

get '/users' do
  User.all.to_json
end

post '/users' do
  # user = User.create!(params[:user])
  user = User.find_by(username: params[:user][:username])
  if user.nil?
    User.create!(params[:user])
    status 201
  else
    status 200
  end
  # user = User.find_or_create_by(username: params[:user][:username])
  user.to_json
end

get '/users/:id' do
  user = User.find(params[:id])
  user.to_json
end

delete '/users/:id' do
  user = User.find(params[:id]).delete
  user.to_json
end
