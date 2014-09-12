require "sinatra"
require "data_mapper"

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/todo.db")

class Todo
  include DataMapper::Resource  
  property :id,           Serial
  property :content,      String
  property :done,         Boolean,  :default => false
  property :completed_at, DateTime
  property :created_at,   DateTime
end  

DataMapper.finalize
Todo.auto_upgrade!


  get "/?" do
    redirect "/todos"
  end

  get "/todos/?" do
    logger.debug "Calling the index page"
    @todos = Todo.all(:order => :created_at.desc)
    erb :"todo/index"
  end

  get "/todos/new/?" do
    logger.info "Creating new todo item"
    @title = "New To Do"
    erb :"/todo/new"
  end

  post "/todos/?" do
    logger.info "New todo item created: " + params[:content]
    todo = Todo.new
    Todo.create(:content => params[:content], :created_at => Time.now)
    redirect '/todos'
  end
   
  get "/todos/:id/?" do
    #@todo = Todo.first(:id => params[:id])
    @todo = Todo.get(params[:id])
    @title = "test"
    erb :"todo/show"
  end
   
  get "/todos/edit/:id/?" do
    #@todo = Todo.first(:id => params[:id])
    @todo = Todo.get(params[:id])
    @title = "Edit Form"
    erb :"todo/edit"
  end

  put "/todos/:id/?" do
    todo = Todo.get(params[:id])
    todo.update(:content => params[:content], :done => params[:done], :completed_at => params[:done] ?  Time.now : nil)
    redirect "/todos"
  end
   
  get '/todos/delete/:id/?' do
    @todo = Todo.get(params[:id])
    erb :"todo/delete"
  end


  delete '/todos/delete/:id/?' do
    Todo.get(params[:id]).destroy
    redirect '/todos'  
  end 

helpers do
  # If @title is assigned, add it to the page's title.
  def title
    if @title
      "#{@title} -- My Blog"
    else
      "This is a to do app"
    end
  end
 
  def pretty_date(time)
   time.strftime("%d %b %Y") unless time==nil
  end

 def logger
      log_file = File.open('logs/my_app.log', 'a+')
      log_file.sync = true
      logger = Logger.new(log_file)
 end
  

end



