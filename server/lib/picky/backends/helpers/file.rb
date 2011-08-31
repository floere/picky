module Picky

  module Backends

    module Helpers

      # Common file helpers.
      #
      module File

        # The backup directory of this file.
        # Equal to the file's dirname plus /backup
        #
        def backup_directory path
          ::File.join ::File.dirname(path), 'backup'
        end

        # Prepares the backup directory for the file.
        #
        def prepare_backup target
          FileUtils.mkdir target unless Dir.exists?(target)
        end

        # The backup filename.
        #
        def backup_file_path_of path
          dir, name = ::File.split path
          ::File.join dir, 'backup', name
        end

        # Extracts the size of the file in Bytes.
        #
        def size_of path
          `ls -l #{path} | awk '{print $5}'`.to_i
        end

      end

    end

  end

end