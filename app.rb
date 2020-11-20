#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'klanj.db'
	@db.results_as_hash = true
end

before do
	init_db
end

def zaebca
	init_db
	post_id = params[:post_id]
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[0]

	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]
end

configure do
	init_db
	@db.execute 'CREATE TABLE if not exists "Posts" (
		"id"	INTEGER,
		"created_date"	DATE,
		"content"	TEXT,
		"username" TEXT,
		PRIMARY KEY("id" AUTOINCREMENT)
	);'

	@db.execute 'CREATE TABLE if not exists "Comments" (
		"id"	INTEGER,
		"created_date"	DATE,
		"comment"	TEXT,
		"post_id" INTEGER,
		PRIMARY KEY("id" AUTOINCREMENT)
	);'
end

get '/' do
	
	@results = @db.execute 'select * from Posts order by id desc'
	
	erb :index			
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]
	username = params[:username]

	errors = {
		:content => 'Type post text',
		:username => 'Type your Name'
	}

	@error = errors.select { |key, _| params[key] == '' }.values.join(", ")
	if @error != ''
		return erb :new
	end

	@db.execute 'insert into Posts (content, username, created_date) values (?, ?, datetime());', [content, username]

	redirect to '/'
	erb "You typed: -- #{content} --"
end

get '/details/:post_id' do
	post_id = params[:post_id]

	zaebca

	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
	comment = params[:comment]

	zaebca

	if comment.size <= 0 
		@error = 'Type your comment'
		return erb :details
	end

	@db.execute 'insert into Comments (comment, created_date, post_id) values (?, datetime(), ?);', [comment, post_id]

	redirect to ('/details/' + post_id)
end