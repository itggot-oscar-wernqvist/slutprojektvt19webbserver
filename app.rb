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
        session[:username] = params["username"]
        session[:user_id] = get_user_id(params["username"])
        redirect('/')
    else
        session[:logged_in] = false
        redirect('/')
    end    
end

post('/register_attempt') do
    register(params["username"], params["password"])
    redirect('/')
end

post('/post_post') do
    post_post(params["title"],params["content"])
    redirect('/')
end

get('/logout') do
    session.clear
    redirect('/')
end

get('/create_post') do
    if session[:logged_in] == true
        slim(:create)
    else
        redirect('/')
    end
end

get('/upvote_post/:id') do
    if prevoius_post_vote(params["id"], session[:user_id]) == false
        vote_post(params["id"], session[:user_id], 1)
        redirect('/')
    else
        redirect('/')
    end
end

get('/downvote_post/:id') do
    if prevoius_post_vote(params["id"], session[:user_id]) == false
        vote_post(params["id"], session[:user_id], -1)
        redirect('/')
    else
        redirect('/')
    end
end