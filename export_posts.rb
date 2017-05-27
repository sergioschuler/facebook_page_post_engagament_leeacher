require 'csv'
require 'koala'

#CHANGE ME
url = 'NovoFloripa/posts' 
graph_api_token = 'add your open graph api token'

page_name = url[0,url.rindex("/")]
timestamp = Time.now.to_s[0,10]
csv_name = "#{page_name}--#{timestamp}.csv"

CSV.open("csv/#{csv_name}", "a") do |output|
  koala = Koala::Facebook::API.new graph_api_token
  posts = koala.get_object(url,
                           fields: 'actions,message,created_time,likes.limit(1).summary(true),comments.limit(1).summary(true)')

  output << %w'created_time message link likes comments'
  count = 1

  begin  
    posts.each do |post|
      puts "Writting line #{count}: #{csv_name}"
      count = count+1
      begin
        output << [
            post['created_time'],
            post['message'],
            post['actions'][0]['link'],
            post['likes']['summary']['total_count'],
            post['comments']['summary']['total_count']
        ]
      rescue NoMethodError
      end
    end
    posts = posts.next_page
  end until posts.empty?
end