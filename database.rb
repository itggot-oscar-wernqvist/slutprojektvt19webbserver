# Module for everything
module Model

    # Checks if a username and password are correct with BCrypt
    #
    # @param [String] username, username
    # @param [String] password, password
    #
    # @return [Boolean] true if login is correct
    def login_check(username, password)
        db = SQLite3::Database.new("db/reddit.db")
        password_hash = db.execute("SELECT users.password_hash FROM users WHERE users.username = ?", username)
        if password_hash.length > 0 && BCrypt::Password.new(password_hash[0][0]).==(password)
            return true
        end
        return false
    end

    # Gets a user_id from a username by checking database
    #
    # @param [String] username, username
    #
    # @return [Integer] the user id
    def get_user_id(username)
        db = SQLite3::Database.new("db/reddit.db")
        user_id = db.execute("SELECT users.user_id FROM users WHERE users.username = ?", username) 
        return user_id
    end

    # Gets all posts in database
    #
    # @return [Hash] returns all posts
    def fetch_posts()
        db = SQLite3::Database.new("db/reddit.db")
        db.results_as_hash = true
        result = db.execute("SELECT posts.post_id, posts.title, posts.timestamp, posts.user_id, users.username, posts.upvote_count, posts.image_link FROM posts INNER JOIN users ON users.user_id = posts.user_id").reverse
        return result
    end

    # Gets one post by post id
    #
    # @param [String] id, post id
    #
    # @return [Hash] returns the post
    def fetch_1post(id)
        db = SQLite3::Database.new("db/reddit.db")
        db.results_as_hash = true
        result = db.execute("SELECT posts.post_id, posts.title, posts.content, posts.timestamp, posts.user_id, users.username, posts.upvote_count, posts.image_link FROM posts INNER JOIN users ON users.user_id = posts.user_id WHERE posts.post_id = ?", id)
        return result
    end

    # Gets all posts by one user
    #
    # @param [String] id, user id
    #
    # @return [Hash] returns the posts
    def fetch_user_posts(id)
        db = SQLite3::Database.new("db/reddit.db")
        db.results_as_hash = true
        result = db.execute("SELECT posts.post_id, posts.title, posts.content, posts.timestamp, posts.user_id, users.username, posts.upvote_count, posts.image_link FROM posts INNER JOIN users ON users.user_id = posts.user_id WHERE posts.user_id = ?", id)
        return result
    end

    # Registers user with username and password with Bcrypt
    #
    # @param [String] username
    # @param [String] password
    def register(username,password)
        db = SQLite3::Database.new("db/reddit.db")
        db.execute("INSERT INTO users (username, password_hash) VALUES (?, ?)", username, BCrypt::Password.create(password))
    end

    # Adds a post to database
    #
    # @param [String] title, title of post
    # @param [String] content, content of post
    # @param [String] image_link, link to external image
    # @param [Integer] user_id, user_id
    def post_post(title,content,image_link,user_id)
        db = SQLite3::Database.new("db/reddit.db")
        time = Time.now.asctime
        db.execute("INSERT INTO posts (title, content, user_id, timestamp, upvote_count, image_link) VALUES (?,?,?,?,?,?)", title, content, user_id, time, 0, image_link)
    end

    # Reads upvote table and previous vote value/ if it exists
    #
    # @param [Integer] post_id
    # @param [Integer] user_id
    #
    # @return [Integer] returns vote value if value exist, else false
    def previous_post_vote(post_id, user_id)
        db = SQLite3::Database.new("db/reddit.db")
        db.results_as_hash = true
        result = db.execute("SELECT post_upvotes.post_id, post_upvotes.user_id, post_upvotes.value FROM post_upvotes WHERE post_upvotes.user_id = ? AND post_upvotes.post_id = ?", user_id, post_id) 
        if result.length > 0
            return value = result[0]["value"].to_i
        else
            return false
        end
    end

    # Votes on a post
    #
    # @param [Integer] post_id
    # @param [Integer] user_id
    # @param [Integer] value, value of upvote 
    # @param [Integer] count_change, value to be changed in posts table
    def vote_post(post_id, user_id, value, count_change)
        db = SQLite3::Database.new("db/reddit.db")
        if previous_post_vote(post_id, user_id) == false
            db.execute("INSERT INTO post_upvotes (post_id, user_id, value) VALUES (?,?,?)", post_id, user_id, value)
        else
            db.execute("UPDATE post_upvotes SET value = ? WHERE post_id = ? AND user_id = ?", value, post_id, user_id)
        end
        upvote_count = db.execute("SELECT posts.upvote_count FROM posts WHERE posts.post_id = ?", post_id)[0][0].to_i
        db.execute("UPDATE posts SET upvote_count = ? WHERE post_id = ?", upvote_count + count_change, post_id)
    end

    # Checks if a post is owned by a user
    #
    # @param [Integer] post_id
    # @param [Integer] user_id
    #
    # @return [Boolean] returns true if post is owned by user
    def post_owner(post_id, user_id)
        db = SQLite3::Database.new("db/reddit.db")
        if user_id == db.execute("SELECT posts.user_id FROM posts WHERE posts.post_id = ?", post_id)
            return true
        end
        return false
    end

    # Deletes a post
    #
    # @param [Integer] post_id
    def delete_post(post_id)
        db = SQLite3::Database.new("db/reddit.db")
        db.execute("DELETE FROM posts WHERE post_id = ?", post_id)
    end

    # Adds a comment to a post
    #
    # @param [Integer] post_id, the id of the parent post of the comment
    # @param [Integer] user_id, the user making the comment
    # @param [String] content, the comment
    # @param [String] username, the user making the comment
    def comment_post(post_id, user_id, content, username)
        db = SQLite3::Database.new("db/reddit.db")
        time = Time.now.asctime
        db.execute("INSERT INTO comments (post_id, user_id, content, timestamp, upvote_count, username) VALUES (?,?,?,?,?,?)", post_id, user_id, content, time, 0, username)
    end

    # Deletes a comment
    #
    # @param [Integer] comment_id, the id of the comment to be removed
    def delete_comment(comment_id)
        db = SQLite3::Database.new("db/reddit.db")
        db.execute("DELETE FROM comments WHERE comment_id = ?", comment_id)
    end

    # Gets all comments on a specific post
    #
    # @param [Integer] post_id, the post_id
    #
    # @return [Hash] a hash of all comments on the post
    def fetch_comments(post_id) 
        db = SQLite3::Database.new("db/reddit.db")
        db.results_as_hash = true
        result = db.execute("SELECT comments.comment_id, comments.username, comments.user_id, comments.content, comments.timestamp FROM comments WHERE comments.post_id = ?", post_id)
    end

    # Edits a post
    #
    # @param [Integer] post_id
    # @param [String] title, title of post
    # @param [String] content, content of post
    def edit_post(post_id, title, content)
        db = SQLite3::Database.new("db/reddit.db")
        time = Time.now.asctime
        db.execute("UPDATE posts SET title = ?, content = ?, timestamp = ? WHERE post_id = ?", title, content, time, post_id)
    end

end