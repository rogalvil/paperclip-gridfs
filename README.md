paperclip-gridfs
================

A rewrite of gmontard/paperclip-gridfs, made to work as a real plugin, packaged as a gem and updated to work with the current mongo gem version. It brings GridFS support to [Paperclip](https://github.com/thoughtbot/paperclip) and supports plain Mongo, but it can also be used in complement with any ORM gem, like MongoMapper or Mongoid.

## Usage

The following examples are for MongoMapper, but the procedure should be similar to any other mongo ORM gem.

There are two ways of configuring the GridFS connection. Either you create a connection or you reuse an existing connection.

Creating a connection looks something like this: you pass in `:storage => :gridfs`, along with a `:gridfs => {}` hash which includes the options.

    class User
      include MongoMapper::Document
      include Paperclip::Glue

      key :avatar_file_name, String
      key :avatar_content_type, String
      has_attached_file :avatar, :storage => :gridfs, :gridfs => {:database => 'avatars', :host => 'test.com'}, :path => "avatars/:style/:filename", :url => "/avatars/:style/:filename"
    end

You can pass in the host, port, database, username and password settings for MongoDB, but the only required value is the database name. Any values you don't set will just get filled in with MongoDB's defaults. If you optionally pass in the username and password keys, the connection will also get authenticated. 

When you already have a Mongo connection object (for example through Mongoid or MongoMapper) you can also just reuse this connection:

    class User
      include MongoMapper::Document
      include Paperclip::Glue

      key :avatar_file_name, String
      key :avatar_content_type, String
      has_attached_file :avatar, :storage => :gridfs, :gridfs => {:database => MongoMapper.database}, :path => "avatars/:style/:filename", :url => "/avatars/:style/:filename"
    end

However, as the files stored inside GridFS are stored in a database, rather than the filesystem, you will need to work out a way to serve these files over HTTP. You can use a helper method, `.to_file(style)`, which returns the attachment0s binary contents. An example solution, done in Sinatra, for the above examples:

    # Get user avatar
    get '/avatars/:style/:id.:extension' do
      user = User.first(:id => params[:id])
      content_type user.avatar.content_type
      user.avatar.to_file(params[:style])
    end