if !@post.nil?
  xml.post do
    xml.label @post.label
    xml.title @post.title
    xml.meta_description @post.meta_description
    xml.meta_keywords @post.meta_keywords
    xml.notes @post.notes
    xml.is_published @post.is_published
    xml.date_published @post.date_published
    xml.created_at @post.created_at
    xml.active @post.active
    
    xml.themes(:type => 'array') do
      @post.themes.each do |theme|
        xml.theme do
          xml.label theme['label']
          xml.name theme['name']
        end
      end
    end
    
    xml.issue do
      xml.month @post.display_issue[:month]
      xml.year @post.display_issue[:year]
      xml.label @post.display_issue[:label]
    end
  end
else
  xml.post do 
    'Not Found'
  end  
end
