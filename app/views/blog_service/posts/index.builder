if !@posts.empty?
  xml.posts(:type => 'array') do
    @posts.each do |r|
      xml.post do
        xml.label r.label
        xml.title r.title
        xml.meta_description r.meta_description
        xml.meta_keywords r.meta_keywords
        xml.notes r.notes
        xml.is_published r.is_published
        xml.date_published r.date_published
        xml.created_at r.created_at
        xml.active r.active

        xml.themes(:type => 'array') do
          r.themes.each do |theme|
            xml.theme do
              xml.label theme['label']
              xml.name theme['name']
            end
          end
        end

        xml.issue do
          xml.month r.display_issue[:month]
          xml.year r.display_issue[:year]
          xml.label r.display_issue[:label]
        end
      end
    end
  end
else
 xml.posts(:type => 'array')
end
