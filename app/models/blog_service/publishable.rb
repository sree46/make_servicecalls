module Publishable
  extend ActiveSupport::Concern
  
  included do
    field :published_attributes
    field :date_published, :type => Time
    
    class_attribute :_unpublished_attributes
    self._unpublished_attributes = [:published_attributes]
  end
  
  module ClassMethods
    def non_published_attributes(*attrs)
      self._unpublished_attributes += attrs.flatten
    end
  end
  
  module InstanceMethods
    def publish
      self.published_attributes = self.attributes.clone.except(*self.class._unpublished_attributes)
      self.date_published = Time.now # .strftime("%Y-%m-%d")
    end
    
    def publish!
      self.publish
      self.save
    end
    
    def unpublish!
      self.published_attributes = nil
      self.date_published = nil
      save
    end
    
    def published?
      !self.published_attributes.blank?
    end
    
    def dirty?
      self.published_attributes != self.attributes.clone.except(*self.class._unpublished_attributes)
     end
    
    def draft?
      self.dirty?
    end
    
    def published
      self.published_attributes and self.class.new(self.published_attributes)
    end

    def previously_published?
      not self.published_attributes.empty?
    end  
     
    def revert_to_published
      if published?
        self.attributes = self.published_attributes
        self
      else
        raise "This document has never been published. If we discard the current draft, then we'd end up in an existential conundrum."
      end
    end
    
    def revert_to_published!
      revert_to_published
      self.save
    end
    
    def discard_draft
      revert_to_published
      self.date_published = nil
    end
    
    def discard_draft!
      discard_draft
      self.save
    end
  end
end
