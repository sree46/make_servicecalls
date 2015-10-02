
module BlogService
  class Post
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Timestamps::Updated
    include Publishable
    

    field :title, :type => String
    field :label, :type => String
    field :meta_description, :type => String, :default => ""
    field :meta_keywords, :type => String, :default => ""
    field :notes, :type => String, :default => ""
    field :is_published, :type => Boolean, :default => false
    field :active, :type => Boolean, :default => true
    field :themes, :type => Array, :default => [] 
    
    belongs_to :blog, :class_name => "BlogService::Blog"
    has_many :articles, :class_name => "BlogService::Blog"
    
    embeds_one :issue, :class_name => "BlogService::Issue"
     
    validates_format_of :label, :with => /^[\w\d-]*$/, :message => "may contain only letters, numbers, and hyphens"
    validates_presence_of :title, :label
    validates_uniqueness_of :label
        
    index [[:label, 1]] 
    index [[:created_at, -1]]
    index [[:updated_at, -1]]
    index [[:is_published, 1]]
    index "issue.label"
    index "themes.parent"
    
    
    def self.find_by_id_or_label(val)
      Mongoid.raise_not_found_error = false
      find(val) || by_label(:key => val).first
    end

    def self.get val
      self.find_by_id_or_label val
    end  

    def self.by_label(options = {})
      query = if options[:key]
                where(:label => options[:key])
              else
                order_by(:label, :asc)
              end
      query
    end
        
    def self.by_all(options = {})
      all.limit(options[:limit])
    end
    
    def self.by_theme(options={})
      where({"themes.label" => options[:key]}).limit(options[:limit])
    end
    
    def self.by_theme_and_title(options={})
      where({'is_published' => true}).and({'themes.label' => options[:key]}).limit(options[:limit]).asc(:title)
    end
    
    def self.by_theme_and_issue(options = {})
      where({"themes.label" => options[:key]}).and(:issue.ne => "", :issue.exists => true).limit(options[:limit]).descending(:true)
    end
        
    def self.by_issue(options = {})
      r = where({'issue.label' => options[:key]}).limit(options[:limit])
    end
    
    def self.by_published(options={})
      time = options[:key].instance_of?(String) ? Time.parse(options[:key]) : options[:key]
      posts = where(:is_published => true)
      if !time.nil?
        posts = posts.any_of({:created_at.gte => time}, {:updated_at.gte => time}).limit(options[:limit])
      end
      posts
    end
    
    def self.by_published_theme(options={})
      where(:is_published => true).and({'themes.label' => options[:key]}).limit(options[:limit])
    end
    
    def self.count(view, options = {})
      self.send(view).count
    end
  end
end
