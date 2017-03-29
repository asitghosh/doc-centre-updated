  module S3Utils
    def s3bucket
      @s3bucket ||= AWS::S3.new.buckets[ENV['S3_BUCKET']]
    end

    def save_to_s3(options={ file: temp_file, merge: false })
      if options[:merge]
        s3object = s3bucket.objects["#{path}/#{merged_filename}"]
      else
        s3object = s3bucket.objects["#{path}/#{filename}"]
      end
      #stream the local object to s3 write(file, acl => public to read)
      file = s3object.write(Pathname.new(options[:file]), :acl => :private)
      file.key
    end

    def plural_class_name
      @plural_class_name ||= @resource.class.name.pluralize 
    end

    def channel_partner_name
      @channel_partner_name  ||= @channel_partner["name"]
    end

    def filename(extension = :pdf)
      extension ? "AppDirect #{@resource.class.name} #{@resource.title}.#{extension}".pathsafe  : 
                                "AppDirect #{@resource.class.name} #{@resource.title}".pathsafe 
    end

    def merged_filename(extension = :pdf)
      extension ?  "all-#{plural_class_name}-for-#{channel_partner_name}.#{extension}".pathsafe  : 
                                        "all-#{plural_class_name}-for-#{channel_partner_name}".pathsafe
    end

    def path
      @path ||= "pdf/#{channel_partner_name}/#{plural_class_name}".pathsafe
    end

    def temp_root
      @temp_root ||= "#{Rails.root}/tmp"
    end

    def temp_dir
      @temp_dir ||= "#{temp_root}/#{path}"
    end

    def temp_file(extension = :pdf)
      "#{temp_dir}/#{filename(extension)}"
    end

    def temp_merged_file(extension = :pdf)
      "#{temp_dir}/#{merged_filename(extension)}"
    end

  end