if !@posts.empty?
  json.posts @posts
else
  json.array! @posts
end
