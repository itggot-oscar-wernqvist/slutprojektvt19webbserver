require 'slim'
require 'sqlite3'
require 'bcrypt'

def login_check(username, password)
    db = SQLite3::Database.new("db/blog.db")
    password_hash = db.execute("SELECT users.password_hash FROM users WHERE users.username = ?", username)
    if password_hash.length > 0 && BCrypt::Password.new(password_hash[0][0]).==(password)
        return true
    else
        return false
    end
end

def get_user_id(username)
    user_id = db.execute("SELECT users.user_id FROM users WHERE users.username = ?", username) 
    return user_id
end