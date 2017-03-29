class AppSettings < ActiveRecord::Base
  # yes, this would be an awesome nosql table.
  # we didn't want to segment our data across multiple db systems
  attr_accessible :key,
                  :value

end