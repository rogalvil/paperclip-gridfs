paperclip-gridfs
================

A fork of gmontard/paperclip-gridfs, however no fork reference was wanted to thoughtbot/paperclip

## Usage

There are two ways of configuring the GridFS connection. Either you create a connection or you reuse an existing connection.

Creating a connection looks something like this:

class User
  include MongoMapper::Document
  include Paperclip::Glue

  key :avatar_file_name, String
  has_attached_file :avatar, :storage => :gridfs, :database => 'avatars'
end

When you already have a Mongo connection object (for example through Mongoid or MongoMapper) you can also reuse this connection:

class User
  include MongoMapper::Document
  include Paperclip::Glue

  key :avatar_file_name, String
  has_attached_file :avatar, :storage => :gridfs, :database => MongoMapper.database
end