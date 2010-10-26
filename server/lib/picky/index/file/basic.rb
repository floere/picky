module Index
  
  module File
    
    class Basic
      
      attr_reader :cache_path
      
      def initialize cache_path
        @cache_path = "#{cache_path}.#{extension}"
      end
      
      # Backup.
      #
      def backup
        prepare_backup backup_path
        FileUtils.cp cache_path, target, :verbose => true
      end
      def backup_path
        ::File.join ::File.dirname(cache_path), 'backup'
      end
      def prepare_backup target
        FileUtils.mkdir target unless Dir.exists?(target)
      end
      
      # Restore.
      #
      def restore
        FileUtils.cp backup_file_path_of(cache_path), cache_path, :verbose => true
      end
      def backup_file_path_of path
        dir, name = ::File.split path
        ::File.join dir, 'backup', name
      end
      
      # Delete.
      #
      def delete
        `rm -Rf #{cache_path}`
      end
      
      # Checks.
      #
      
      # Is the cache small?
      #
      def cache_small?
        size_of(cache_path) < 16
      end
      # Is the cache ok? I.e. larger than four Bytes in size.
      #
      def cache_ok?
        size_of(cache_path) > 0
      end
      def size_of path
        `ls -l #{path} | awk '{print $5}'`.to_i
      end
      
    end
    
  end
  
end