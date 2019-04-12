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
    if params["password1"] == params["password2"]
    register(params["username"], params["password1"])
    end
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
    vote_value = prevoius_post_vote(params["id"], session[:user_id])
    if vote_value == 1
        vote_post(params["id"], session[:user_id], 0, -1)
    elsif vote_value == -1
        vote_post(params["id"], session[:user_id], 1, 2)
    else
        vote_post(params["id"], session[:user_id], 1, 1)
    end
    redirect('/')
end

get('/downvote_post/:id') do
    vote_value = prevoius_post_vote(params["id"], session[:user_id])
    if  vote_value == -1
        vote_post(params["id"], session[:user_id], 0, 1)
    elsif vote_value == 1
        vote_post(params["id"], session[:user_id], -1, -2)
    else
        vote_post(params["id"], session[:user_id], -1, -1)
    end
    redirect('/')
end

get('/post/:id') do
    post = fetch_1post(params["id"])
    if post.length == 0
        redirect('/')
    end
    # comments = fetch_commets(params["id"])
    slim(:post, locals:{
        post: post[0]
    })
end