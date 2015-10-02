module BlogService
  class Issue
    include Mongoid::Document
    embedded_in :post, :class_name => "BlogService::Post"
    
    field :month, :type => Integer
    field :year, :type => Integer
    field :label, :type => String
    
    def lbl
      if month && year
        self['label'] ||= "#{month}-#{year}".downcase
      else
        self['label']
      end
    end
  end
end
