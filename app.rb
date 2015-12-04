require 'rubygems'
require 'sinatra'
require 'active_record'
require './models/gcm'
require 'json'
require 'rest-client'
require './config/environments'

class NotificationController < Sinatra::Base

  configure do
    set :GOOGLE_GCM_HTTP_URL, 'https://android.googleapis.com/gcm/send'
  end

  ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => 'gcm.db'
  )

  get '/mobile' do
    erb:form
  end

  get '/teste' do
    erb:hello
  end

  post '/mobile/send' do
    title = params['title']
    msg = params['message']

    registration_ids = Array.new
    GCM.all.each do |g|
      registration_ids.push(g.registration)
    end

    post_args = {
      :registration_ids => registration_ids,
      :data => {
        :title    => title,
        :message => msg
      }
    }
    # "#{post_args.to_json}"
    resp = RestClient.post settings.GOOGLE_GCM_HTTP_URL,
                          post_args.to_json,
                          :Authorization => 'key=' + GOOGLE_API_KEY,
                          :content_type => :json,
                          :accept => :json
    hash = JSON.parse resp

    @sucessCount = hash['success']
    @removedKeys = 0

    if hash['failure'] > 0
      resp += "<br>Deletados:"
      hash['results'].each_with_index do |registration, index|
        if registration['error'] == 'NotRegistered'
          GCM.where(registration: registration_ids[index]).first.delete
          removedKeys += 1
          resp += " <br> #{index}, "
        end
      end
    end

    if hash['canonical_ids'] > 0
      resp += "<br>Duplicados:"
      hash['results'].each_with_index do |registration, index|
        if registration['registration_id'] != ""
          GCM.where(registration: registration_ids[index]).first.delete
          removedKeys += 1
          resp += " <br> #{index}, "
        end
      end
    end

    erb:hello
  end

  post '/mobile/save' do
    # method = params['method']
    regId = params['reg-id']

    return if(GCM.exists?(:registration => regId.to_s))

    gcm = GCM.new(registration: regId)
    gcm.save
    "Salvou #{regId}"
    # "method = #{method}, reg-id = #{regId} , Constantes = #{settings.GOOGLE_GCM_HTTP_URL} , #{settings.GOOGLE_API_KEY}"
  end

end
