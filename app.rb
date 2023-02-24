# frozen_string_literal: true

require 'sinatra'
require 'mongoid'

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

# User Class
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String

  validates :username, presence: true
  index({ username: 'text'}, { unique: true})

  validates_uniqueness_of :username

  scope :username, -> (username) { where(username: username) }
end

# TODO: Implement update/patch route

get '/health' do
  content_type :json
  { healthy: true }.to_json
end

get '/users' do
  content_type :json
  User.all.to_json
end

post '/users' do
  content_type :json

  user = User.where(username: params[:username])

  if user.length == 0
    user = User.create!(params)
    status 201
  else
    status 200
  end

  user.to_json
end

get '/users/:username' do |username|
  content_type :json

  user = User.where(username: username)

  halt(404, { message:'User Not Found'}.to_json) unless user

  user.to_json
end

delete '/users/:username' do |username|
  content_type :json

  User.where(username: username).delete

  status 204
end
