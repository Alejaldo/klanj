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

configure do
	init_db
	@db.execute 'CREATE TABLE if not exists "Posts" (
		"id"	INTEGER,
		"created_date"	DATE,
		"content"	TEXT,
		PRIMARY KEY("id" AUTOINCREMENT)
	);'
end

get '/' do
	erb :index			
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]

	if content.size <= 0 
		@error = 'Type post text'
		return erb :new
	end

	#save to DB
	@db.execute 'insert into Posts (content, created_date) values (?, datetime());', [content]

	erb "You typed: -- #{content} --"
end