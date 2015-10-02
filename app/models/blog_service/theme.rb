module BlogService
  class Theme
    include Mongoid::Document

    field :name, :type => String
    field :label, :type => String
    
    index [[:label, 1]] 
    index [[:name, 1]] 
    
    def self.search_by_name name
      where(:name => name)
    end

    def self.find_by_id_or_label(val)
      Mongoid.raise_not_found_error = false
      find(val) || by_label(:key => val).first
    end
    
    def self.count(view, options = {})
      self.send(view).count
    end
    
    def self.by_label(options = {})
      query = if options[:key]
                where(:label => options[:key])
              else
                order_by(:label, :asc)
              end
      query
    end
    MONGO_PARAMS = [:limit, :skip, :key, :startkey, :endkey, :descending] 
    
    def self.by_all(options = {})
      all(options)
    end  
    validates_presence_of :name, :label
    validates_uniqueness_of :label
    
    def children(options={})
      self.class.by_parent_label({:key => self.label}.merge(options))
    end
    

  end
end
