#!/usr/bin/env ruby -w

# Contact app. Example Sinatra application that you can use to test tourbus.
# 
# Pretty simple applet. You go to / and enter your contact
# information. When you click submit, it shows you your name in all
# caps. Okay, "pretty simple" was an understatement. I get that. Shut up.
require 'rubygems'
require 'sinatra'

get '/' do
  '<a href="/contacts">Enter Contact</a>'
end 

get '/contacts' do
  <<-eos
<html>
  <head>
    <title>Contact App</title>
  </head>
  <body>
    <h1>Contact Info:</h1>
    <form action="/contacts" method="POST">
      <p><label for="first_name"><b>First Name:</b></label> <input name="first_name" size="30"></p>
      <p><label for="last_name"><b>Last Name:</b></label> <input name="last_name" size="30"></p>
      <input type="submit">
    </form>
  </body>
</html>
eos
end

post '/contacts' do
  "<h1>#{params[:last_name]}, #{params[:first_name]}</h1>"
end 

