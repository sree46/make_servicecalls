module BlogService
  class BlogsController < ApplicationController

    def count
      view, options = 
        if params[:theme]
          [:by_theme, {:key => params[:theme]}]
        elsif params[:post_id] 
          [:by_post, {:key => params[:post_id]}]  
        else
          [:by_all, {}]
        end

      options.merge!
      
      count = BlogService::Post.count view, options

      respond_to do |format|
        format.json {render :json => {:count => count}  }
        format.xml  {render :xml => {:count => count}   }
      end
    end


    def publish
      @post = BlogService::Post.find_by_id_or_label params[:id]
      
      respond_to do |format|
        if @post.nil?
          format.xml { render :xml => {:error => "unknown"}, :status => 404}
          format.json { render :json => {:error => "unknown"}, :status => 404}
        else
          @post.publish!
          format.xml { render :xml => @post, :status => 201}
          format.json { render :json => @post.json, :status => 201}
        end
      end
    end

    def discard_draft
      @post = BlogService::POst.find_by_id_or_label params[:id]
      respond_to do |format|
        if @post.nil?
          format.xml { render :xml => {:error => "unknown"}, :status => 404}
          format.json { render :json => {:error => "unknown"}, :status => 404}
        else
          begin
            @post.discard_draft!
            format.xml { render :xml => @post.xml, :status => 201}
            format.json { render :json => @post.json, :status => 201}
          rescue Exception => e
            format.xml { render :xml => {:errors => [{:state => e.to_s}]}, :status => :unprocessable_entity }
            format.json { render :json => {:errors => [{:state => e.to_s}]}.to_json, :status => :unprocessable_entity }
          end
        end
      end
    end
   
    def published
      options = {}
      offset = (params[:offset] || 0).to_i
      limit = (params[:limit] || 10).to_i
      if params['since']
        view = :by_published
        options[:key] = Time.parse(params['since'].gsub('-','/')).strftime("%Y-%m-%d %H:%M:%S %z")
      elsif params["theme"]
        view = :by_theme
        options[:key] = params["theme"] 
      else
       view = :by_published 
      end  
      
      count = Post.count view
      options.merge! :limit => limit, :skip => offset
      respond_to do |format|
        if offset <= count 
          format.xml { render :xml => Post.send(view, options).map(&:prep_for_export), :root => :posts }
          format.json  { render :json => Post.send(view, options).map(&:prep_for_export) }
        else
          format.xml { render :xml => "error",:status => 422 }
          format.json  { render :json => "error",:status => 422 }
        end
      end
    end 
    
    def published_count
      view, options = 
        if params['since']
          [:by_published, {:key => Time.parse(params['since'].gsub('-','/')).strftime("%Y-%m-%d %H:%M:%S %z")}]
        elsif params['theme']
          [:by_theme, {:key => params['theme']}]
        else
          [:by_published, {}]
        end
      
      options.merge!
      count = Post.count view, options

      respond_to do |format|
        format.json {render :json => {:count => count}  }
        format.xml  {render :xml => {:count => count}   }
      end
    end


    def index
      options = {}
      offset = (params[:offset] || 0).to_i
      limit = (params[:limit] || 10).to_i
      if params[:theme]
        if params[:sort] == "alpha"
          view = :by_theme_and_title
          options.merge!(:key => params[:theme])
        else
          view = :by_theme_and_issue
          
          options.merge!(:descending => true,
                         :key => params[:theme])
        end
      elsif params["issue_id"]
        view = :by_issue
        options[:key] = params["issue_id"]
      elsif params["featured"]
        view = :by_featured
      else
        view = :by_all
      end
      
      count = BlogService::Post.send(view, options).size
      options.merge! :limit => limit, :skip => offset

      respond_to do |format|
        if offset <= count 
          if params['issue_id']
            results =  BlogService::Post.send(view, options)
            blogs = []
            results.each {|blog| posts << post }
            format.xml { render :xml => posts, :root => :posts }
            format.json  { render :json => posts }
          else
            format.xml { 
              @posts = BlogService::Post.send(view, options) 
              render :layout => false 
              }
            format.json { 
              @posts = BlogService::Post.send(view, options) 
              render :layout => false 
              }
          end
        else
          format.xml { render :xml => "error",:status => 422 }
          format.json  { render :json => "error",:status => 422 }
        end
      end
    end

    def show
      @post = BlogService::Post.find_by_id_or_label params[:id]
      @post = @post.published if @post and !in_preview? 
      
      respond_to do |format|
        if @post
          format.xml {render :template => 'blog_service/posts/show.builder', :layout => false}
          format.json {render :template => 'blog_service/posts/show.json.jbuilder', :layout => false}
        else
          format.xml  { render :xml =>  {:error => "not found"}.to_xml,   :status => 404  }
          format.json { render :json => {:error => "not found"}.to_json,  :status => 404  }
        end
      end
    end

    def create
      @post = BlogService::Post.new params[:post] 
    
      respond_to do |format|
        if @post.save
          format.xml  { render :xml => @post, :status => :created}
          format.json { render :json => @post, :status => :created}
        else
          format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
          format.json { render :json => {:errors => @post.errors.to_a}.to_json, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /your_model/1.xml
    # PUT /your_model/1.json
    def update
      @post = BlogService::Post.find_by_id_or_label CGI.unescape(params[:id]) 
    
      respond_to do |format|
        if @post.update_attributes params[:post]
          format.xml  { head :ok }
          format.json { head :ok }
        else
          format.xml  { render :xml  => @post.errors, :status => :unprocessable_entity }
          format.json { render :json => {:errors => @post.errors.to_a}.to_json, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /your_model/1.xml
    # DELETE /your_model/1.json
    def destroy
      @post = BlogService::Post.find_by_id_or_label params[:id]
      @post.destroy
    
      respond_to do |format|
        format.xml  { head :ok }
        format.json { head :ok }
      end
    end
  end
end
