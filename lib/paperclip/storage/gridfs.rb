module Paperclip
  module Storage
    # MongoDB's GridFS storage system (http://www.mongodb.org/display/DOCS/GridFS) uses
    # a chunking strategy to store files in a mongodb database.
    # Specific options for GridFS:
    # * +gridfs_credentials+: Similar to +s3_credentials+, this can be a path, a File, or
    #   a Hash. Keys are as follows:
    #   * +database+: the name of the MongoDB database to connect to. This can also be
    #     a +Mongo::DB+ object, in which case that connection will be used, and other
    #     credentials will be ignored.
    #   * +host+: defaults to +localhost+
    #   * +username+ and +password+: optional authentication for the database server.
    #
    # Note that, because files stored using the +:gridfs+ storage module are stored
    # within the database rather than the file system, you'll need to work out a method
    # to extract the file data to serve it over HTTP. This is pretty trivial using
    # Rails Metal.

    module Gridfs
      def self.extended base
        begin
          require 'mongo'
        rescue LoadError => e
          e.message << " (You may need to install the mongo gem)"
          raise e
        end
                
        base.instance_eval do
          @gridfs_options = parse_credentials(@options[:gridfs])
          @gridfs_db      = Paperclip::Storage::Gridfs.gridfs_connections(@gridfs_options)
        end
      end
      
      def self.gridfs_connections creds
        @connections ||= {}
        @connections[creds] ||= get_database_connection(creds)
      end
      
      def connection
        @gridfs_db
      end
      
      def parse_credentials creds
        creds = find_credentials(creds).stringify_keys
        env = Object.const_defined?(:Rails) ? Rails.env : nil
        (creds[env] || creds).symbolize_keys
      end
      
      def exists?(style = default_style)
        if original_filename
          @gridfs = Mongo::GridFileSystem.new(connection)
          val = @gridfs.open(path(style), "r") rescue nil
          !val.nil?
        else
          false
        end
      end
          
      # Returns representation of the data of the file assigned to the given
      # style, in the format most representative of the current storage.
      def to_file style = default_style
        @queued_for_write[style] || (Mongo::GridFileSystem.open(connection, path(style), 'rb') if exists?(style))
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|          
          log("saving #{path(style)}")
          puts "Test #{connection.inspect} #{style.inspect}"
          @gridfs = Mongo::GridFileSystem.new(connection)
          @gridfs.open(path(style), 'w', {
              :content_type => content_type,
              :metadata => { 'instance_id' => instance.id },
              :chunk_size => 4.kilobytes
            }) { |f|
            f.write file.read
          }
          file.close
          File.unlink(file.path)
        end
        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          begin
            log("deleting #{path}")
            @gridfs = Mongo::GridFileSystem.new(connection)
            val = @gridfs.open(path, "r") rescue nil
            if !val.nil?
              @gridfs.delete(path)
            end
          rescue Errno::ENOENT => e
            # ignore file-not-found, let everything else pass
          end
        end
        @queued_for_delete = []
      end
      
      def self.get_database_connection creds
        case creds[:database]
        when Mongo::DB then creds[:database]
        else
          returning Mongo::Connection.new(creds[:host] || "localhost", creds[:port] || Mongo::Connection::DEFAULT_PORT).db(creds[:database]) do |db|
            if creds[:username] && creds[:password]
              auth = db.authenticate creds[:username], creds[:password]
            end
          end
        end
      end

      def find_credentials creds
        case creds
        when File
          YAML::load(ERB.new(File.read(creds.path)).result)
        when String
          YAML::load(ERB.new(File.read(creds)).result)
        when Hash
          creds
        else
          raise ArgumentError, "Credentials are not a path, file or hash."
        end
      end
      private :find_credentials
    end
  end
end
