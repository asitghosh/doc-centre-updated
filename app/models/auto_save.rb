class AutoSave < ActiveRecord::Base
  # We're using a separate table to save saves--auto and manually triggered. 
  # This follows pretty much the same pattern as paper_trail, but will store working versions of the object in question
  belongs_to :item, :polymorphic => true
  attr_accessible :item_type,
                  :item_id,
                  :event,
                  :object,
                  :whodunnit,
                  :object_changes
  validates_presence_of :event

  def self.with_item_keys(item_type, item_id)
    where :item_type => item_type, :item_id => item_id
  end

  def self.autosaves
    where :event => "autosave"
  end

  def self.manualsaves
    where :event => "manualsave"
  end

  def reify
    without_identity_map do
      unless object.nil?
        attrs = AutoSaveable::Serializers::Yaml.load object

        if item
          model = item
        else
          inheritance_column_name = item_type.constantize.inheritance_column
          class_name = attrs[inheritance_column_name].blank? ? item_type : attrs[inheritance_column_name]
          klass = class_name.constantize
          model = klass.new
        end

        model.class.unserialize_attributes_for_autosave attrs
        attrs.each do |k, v|
          if model.respond_to?("#{k}=")
            model[k.to_sym] = v
          else
            logger.warn "Attribute #{k} does not exist on #{item_type} (Autosave id: #{id})."
          end
        end

        model
      end
    end # /without_id_map
  end #/reify

  private

  def without_identity_map(&block)
    if defined?(ActiveRecord::IdentityMap) && ActiveRecord::IdentityMap.respond_to?(:without)
      ActiveRecord::IdentityMap.without(&block)
    else
      block.call
    end
  end

end