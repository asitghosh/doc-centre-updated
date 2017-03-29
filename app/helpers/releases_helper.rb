module ReleasesHelper
  def group_by_type(releases)
    ofthejedi = {}
    releases.map do |release|
      ofthejedi[release.release_type] ||= []
      ofthejedi[release.release_type] << release
    end
    return ofthejedi #GETIT?!?!
  end

  def list?
    params[:view] == "list" || cookies.signed[:r_format] == "list"
  end

  def cache_key_for_collection(collection)
    count                     = collection.count
    max_updated_at            = collection.maximum(:updated_at).try(:utc)
    int_max_updated_at        = cache_key_for_utc(max_updated_at)
    "#{collection.first.class.name.downcase}-#{count}-#{int_max_updated_at}"
  end

  def cache_key_for_record(record)
    "#{record.release_type}#{cache_key_for_utc(record.updated_at.try(:utc))}"
  end

  def cache_key_for_utc(time)
    "#{time.try(:to_s, :number)}#{time.try(:nsec)}"
  end


  def release_unread_digest
    releases_string = cache_key_for_collection @releases
    unread_string   = cache_key_for_collection Release.unread_by(current_user)
    # puts Digest::MD5.hexdigest("#{releases_string}-#{unread_string}")
    Digest::MD5.hexdigest("#{releases_string}-#{unread_string}")
  end
end
