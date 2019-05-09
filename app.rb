require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative('database.rb')
enable :sessions
include Model


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
    post_post(params["title"],params["content"],params["img"],session[:user_id])
    redirect('/')
end

get('/logout') do
    session.clear
    redirect('/')
end

get('/admin') do
    if session[:logged_in] == true
        posts = fetch_user_posts(session[:user_id])
        slim(:admin, locals:{
            posts: posts
        })
    else
        redirect('/')
    end
end

get('/upvote_post/:id') do
    vote_value = previous_post_vote(params["id"], session[:user_id])
    if vote_value == 1
        vote_post(params["id"], session[:user_id], 0, -1)
    elsif vote_value == -1
        vote_post(params["id"], session[:user_id], 1, 2)
    elsif session[:logged_in] == true
        vote_post(params["id"], session[:user_id], 1, 1)
    end
    redirect back
end

get('/downvote_post/:id') do
    vote_value = previous_post_vote(params["id"], session[:user_id])
    if  vote_value == -1
        vote_post(params["id"], session[:user_id], 0, 1)
    elsif vote_value == 1
        vote_post(params["id"], session[:user_id], -1, -2)
    elsif session[:logged_in] == true
        vote_post(params["id"], session[:user_id], -1, -1)
    end
    redirect back
end

get('/post/:id') do
    post = fetch_1post(params["id"])
    if post.length == 0
        redirect('/')
    end
    comments = fetch_comments(params["id"])
    slim(:post, locals:{
        post: post[0],
        comments: comments
    })
end

get('/user/:id') do
    posts = fetch_user_posts(params["id"])
    if posts.length == 0
        redirect('/')
    end
    slim(:user, locals:{
        posts: posts
    })
end

post('/delete_post') do
    if post_owner(params["post_id"], session[:user_id]) == true
        delete_post(params["post_id"])
    end
    redirect back
end

post('/comment_post') do
    if session[:logged_in] == true
        comment_post(params["post_id"], session[:user_id], params["comment"], session[:username])
    end
    redirect back
end

post('/delete_comment') do
    delete_comment(params["comment_id"].to_i)
    redirect back
end

get('/edit_post/:id') do 
    if post_owner(params["id"], session[:user_id]) == true
        result = fetch_1post(params["id"])
        slim(:edit_post, locals:{
            post: result[0]} )
    end
end

post('/edit_post_attempt') do
    if post_owner(params["post_id"], session[:user_id]) == true
        edit_post(params["post_id"], params["title"], params["content"])
    end
    redirect('/')
end