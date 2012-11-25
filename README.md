paperclip-gridfs
================

A fork of gmontard/paperclip-gridfs (which was apparently a fork of kristianmandrup/paperclip), however no fork reference was wanted to thoughtbot/paperclip

## Usage

There are two ways of configuring the GridFS connection. Either you create a connection or you reuse an existing connection.

Creating a connection looks something like this:

    class User
      include MongoMapper::Document
      include Paperclip::Glue

      key :avatar_file_name, String
      key :avatar_content_type, String
      has_attached_file :avatar, :storage => :gridfs, :gridfs => {:database => 'avatars'}, :path => "avatars/:style/:filename", :url => "/avatars/:style/:filename"
    end

When you already have a Mongo connection object (for example through Mongoid or MongoMapper) you can also reuse this connection:

    class User
      include MongoMapper::Document
      include Paperclip::Glue

      key :avatar_file_name, String
      key :avatar_content_type, String
      has_attached_file :avatar, :storage => :gridfs, :gridfs => {:database => MongoMapper.database}, :path => "avatars/:style/:filename", :url => "/avatars/:style/:filename"
    end

However, one then needs to also tie the URL's inside the app with the GridFS attachments (which can be viewed with `.to_file(style)`, outputting the binary contents, same as File.read). An example done in Sinatra, for the above class:

    # Get user avatar
    get '/avatars/:style/:id.:extension' do
      if params[:id] != 'missing'
        u = User.first(:id => params[:id])
        content_type u.avatar.content_type
        u.avatar.to_file(params[:style])
      else
        content_type 'image/png'
        File.open('public/avatars/missing.png').read #haxx
      end
    end

