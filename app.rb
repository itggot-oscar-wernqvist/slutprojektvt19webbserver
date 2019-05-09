require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative('database.rb')
enable :sessions
include Model

# Display Landing Page
#
# @see Model#fetch_posts
get('/') do
    result = fetch_posts()
    slim(:index, locals:{
        posts: result
    })
end

# Handles a login request and redirects to '/'
#
# @param [String] username, the username
# @param [String] password, the password
#
# @see Model#login_check
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

# Handles a register request and redirects to '/'
#
# @param [String] username, the username
# @param [String] password1, the first password field
# @param [String] password2, the second password field
#
# @see Model#register
post('/register_attempt') do
    if params["password1"] == params["password2"]
    register(params["username"], params["password1"])
    end
    redirect('/')
end

# Creates a new post and redirects to '/'
#
# @param [String] title, The title of the article
# @param [String] content, The content of the article
# @param [String] img, A link to externally hosted image
#
# @see Model#post_post
post('/post_post') do
    post_post(params["title"],params["content"],params["img"],session[:user_id])
    redirect('/')
end

# Logs out user by deleting session
#
get('/logout') do
    session.clear
    redirect('/')
end

# Displays Admin page if user is logged in
# 
# @see Model#fetch_user_posts
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

# Upvotes a post depending on previous upvote value
#
# @param [Integer] :id, post_id to be upvoted
#
# @see Model#previos_post_vote
# @see MOdel#vote_post
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

# Downvotes a post depending on previous upvote value
#
# @param [Integer] :id, post_id to be downvoted
#
# @see Model#previos_post_vote
# @see Model#vote_post
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

# Display a sigle post with comments
#
# @param [Integer] :id, post_id to be displayed
#
# @see Model#fetch_1post
# @see Model#fetch_comments
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

# Display the posts of one specific user
#
# @param [Integer] :id, user_id of user to view
#
# @see Model#fetch_user_posts
get('/user/:id') do
    posts = fetch_user_posts(params["id"])
    if posts.length == 0
        redirect('/')
    end
    slim(:user, locals:{
        posts: posts
    })
end

# Deletes post if correct user is logged in
#
# @param [Integer] post_id, post_id of post to be deleted
#
# @see Model#post_owner
# @see Model#delete_post
post('/delete_post') do
    if post_owner(params["post_id"], session[:user_id]) == true
        delete_post(params["post_id"])
    end
    redirect back
end

# Comments a post
#
# @param [Integer] post_id, the id of the parent post of the comment
# @param [String] comment, the comment
#
# @see Model#comment_post
post('/comment_post') do
    if session[:logged_in] == true
        comment_post(params["post_id"], session[:user_id], params["comment"], session[:username])
    end
    redirect back
end

# Deletes comment
#
# @param [Integer] comment_id, id of comment to be deleted
#
# @see Model#delete_comment
post('/delete_comment') do
    delete_comment(params["comment_id"].to_i)
    redirect back
end

# Displays edit page if correct user is loged in
#
# @param [Integer] id, post_id of post to be edited
#
# @see Model#post_owner
# @see Model#fetch_1post
get('/edit_post/:id') do 
    if post_owner(params["id"], session[:user_id]) == true
        result = fetch_1post(params["id"])
        slim(:edit_post, locals:{
            post: result[0]} )
    end
end

# Edits a post if correct user is logged in
#
# @param [Integer] post_id, id of post to be edited
# @param [String] title, the new title of the post
# @param [String] content, the new content of the post
#
# @see Model#post_owner
# @see Model#edit_post
post('/edit_post_attempt') do
    if post_owner(params["post_id"], session[:user_id]) == true
        edit_post(params["post_id"], params["title"], params["content"])
    end
    redirect('/')
end