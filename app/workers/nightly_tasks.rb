class NightlyTasks
  @queue = :nightly_tasks
  include HTTParty

  def self.perform
    Release.cleanup_read_marks!
    Page.cleanup_read_marks!
    Feature.cleanup_read_marks!

    OpenID::Store::ActiveRecord.new.cleanup

    #check_indices
  end

  def self.check_indices
    searchable_resources = %w(Release Support Manual Faq Roadmap)
    updated_resources = []
    searchable_resources.each do |resource|
      r = resource.camelize.constantize

      case r.name
      when "Page", "Support", "Manual"
        db_count = r.printable.count
      when "Roadmap"
        db_count = r.published.no_redirect.count
      when "Release"
        db_count = r.published.count
      else
        db_count = r.count
      end

      es_count = count_records_for(r.searchkick_index.name)
      if db_count > es_count
        updated_resources.push(r.name)
        r.reindex
      end
    end

    puts "Updated #{updated_resources.empty? ? "no" : updated_resources.join(",")} indices"
  end

  def self.count_records_for(index_name)
    base_url = ENV['BONSAI_URL'] || "http://localhost:9200"
    response = HTTParty.get("#{base_url}/#{index_name}/_count")
    return response["count"]
  end

end
