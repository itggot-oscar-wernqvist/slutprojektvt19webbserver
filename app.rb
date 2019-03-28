require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative('database.rb')
enable :sessions

get('/') do
    result = fetch_posts()
    slim(:index, locals:{
        posts: result
    })
end

post('/login_attempt') do
    if login_check(params["username"], params["password"]) == true
        session[:logged_in] = true
        session[:username] = get_user_id(params["username"])
        session[:user_id] = user_id
        redirect('/admin')
    else
        session[:logged_in] = false
        redirect('/login')
    end    
end

