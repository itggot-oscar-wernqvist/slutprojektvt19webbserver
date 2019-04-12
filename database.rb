def login_check(username, password)
    db = SQLite3::Database.new("db/reddit.db")
    password_hash = db.execute("SELECT users.password_hash FROM users WHERE users.username = ?", username)
    if password_hash.length > 0 && BCrypt::Password.new(password_hash[0][0]).==(password)
        return true
    end
    return false
end

def get_user_id(username)
    db = SQLite3::Database.new("db/reddit.db")
    user_id = db.execute("SELECT users.user_id FROM users WHERE users.username = ?", username) 
    return user_id
end

def fetch_posts()
    db = SQLite3::Database.new("db/reddit.db")
    db.results_as_hash = true
    result = db.execute("SELECT posts.post_id, posts.title, posts.content, posts.timestamp, posts.user_id, users.username, posts.upvote_count, posts.image_link FROM posts INNER JOIN users ON users.user_id = posts.user_id").reverse
    return result
end

def register(username,password)
    db = SQLite3::Database.new("db/reddit.db")
    db.execute("INSERT INTO users (username, password_hash) VALUES (?, ?)", username, BCrypt::Password.create(password))
end

def post_post(title,content)
    db = SQLite3::Database.new("db/reddit.db")
    time = Time.now.asctime
    db.execute("INSERT INTO posts (title, content, user_id, timestamp, upvote_count) VALUES (?,?,?,?,?)", title, content, session[:user_id], time, 0)
end

def prevoius_post_vote(post_id, user_id)
    db = SQLite3::Database.new("db/reddit.db")
    db.results_as_hash = true
    result = db.execute("SELECT post_upvotes.post_id, post_upvotes.user_id, post_upvotes.value FROM post_upvotes WHERE post_upvotes.user_id = ? AND post_upvotes.post_id = ?", user_id, post_id) 
    if result.length > 0
        return value = result[0]["value"].to_i
    else
        return false
    end
end

def vote_post(post_id, user_id, value, count_change)
    db = SQLite3::Database.new("db/reddit.db")
    if prevoius_post_vote(post_id, user_id) == false
        db.execute("INSERT INTO post_upvotes (post_id, user_id, value) VALUES (?,?,?)", post_id, user_id, value)
    else
        db.execute("UPDATE post_upvotes SET value = ? WHERE post_id = ? AND user_id = ?", value, post_id, user_id)
    end
    upvote_count = db.execute("SELECT posts.upvote_count FROM posts WHERE posts.post_id = ?", post_id)[0][0].to_i
    db.execute("UPDATE posts SET upvote_count = ? WHERE post_id = ?", upvote_count + count_change, post_id)
end

def fetch_1post(id)
    db = SQLite3::Database.new("db/reddit.db")
    db.results_as_hash = true
    result = db.execute("SELECT posts.post_id, posts.title, posts.content, posts.timestamp, posts.user_id, users.username, posts.upvote_count, posts.image_link FROM posts INNER JOIN users ON users.user_id = posts.user_id WHERE posts.post_id = ?", id)
    return result
end