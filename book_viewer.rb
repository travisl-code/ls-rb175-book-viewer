require "sinatra"
require "sinatra/reloader" # if development?
require 'tilt/erubis'

before do
  @chapters = File.readlines 'data/toc.txt'
end

helpers do
  def in_paragraphs(ch_content)
    html_content = ""
    ch_array = ch_content.split("\n\n")
    ch_array.each_with_index do |para, idx|
      html_content << "<p id=\"#{idx}\">#{para}</p>\n\n"
    end
    html_content
  end

  def strong_search(search_text, search_string)
    search_text.gsub(/#{search_string}/, "<strong>#{search_string}</strong>")
  end
end

get "/" do
  # File.read "public/template.html"
  @title = "The Adventures of Sherlock Holmes"
  # @chapters = File.readlines 'data/toc.txt' # Moved to `before` filter
  erb :home
end

# get /\/chapters\/(\d[0-2]?)/ do
#   ch_match = params['captures'].first

#   @title = "Chapter #{ch_match}"
#   @chapters = File.readlines 'data/toc.txt'
#   @ch_content = File.readlines "data/chp#{ch_match}.txt", sep="\n\n"

#   erb :chapter
# end

get '/chapters/:number' do
  number = params[:number].to_i
  chapter_name = @chapters[number - 1]

  redirect "/" unless (1..@chapters.size).cover?(number)

  # @chapters = File.readlines "data/toc.txt" 3 moved to `before` filter
  @title = "Chapter #{number}: #{chapter_name}"
  # @ch_content = File.readlines "data/chp#{number}.txt", sep="\n\n" # moved to view helper
  @ch_content = File.read "data/chp#{number}.txt"

  erb :chapter
end

get '/show/:name' do
  params[:name]
end

=begin
First iteration...

See if query text was input
- if yes, loop through each chapter in 'data' directory
  - Initialize empty results array
  - Get chapter name and number
  - Load chapter text
  - Search chapter text for query text. If found, add chapter name to results
  - Evaluate if results array is empty...
    - If yes, display default value (nothing found)
    - If no, format results of results array into HTML

get '/search' do
  @query_text = params[:query]

  if @query_text
    @results = []

    if @query_text.size > 0
      1.upto(@chapters.size) do |ch_num|
        ch_name = @chapters[ch_num - 1]
        f = File.read "data/chp#{ch_num}.txt"

        @results << {ch_name: ch_name, ch_num: ch_num} if f.include?(@query_text)
      end
    end
  end

  erb :search
end
=end

=begin
Second iteration, to display the paragraph

Overview...
1) Update `<p>` elements to include an `id` in `views/chapter.erb`
2) Update code to display more info:
  - Display chapter name
  - Display paragraph where search text is found
  - Link to the paragraph using anchors + id

Iterate through each chapter, 1 - end. Each ch...
- Store the chapter number (for URL)
- Store the chapter name (for display)
- Load the chapter data from file read
- Initialize hash to contain data
- See if the chapter contains the query string...
  - if YES...
    - split the actual chapter data into paragraphs. Each para...
    - Store the index of the paragraph as the ID
    - Store the text of the paragraph as TEXT
    - Add the hash into the results array
  - if NO... skip
=end
def search_match(query)
   results = []

   return results if !query || query.empty?

   1.upto(@chapters.size) do |ch_num|
    ch_name = @chapters[ch_num - 1]
    f = File.read "data/chp#{ch_num}.txt"
    ch_hash = {ch_num: ch_num, ch_name: ch_name, para: []}

    if f.include?(query)
      f.split("\n\n").each_with_index do |para,idx|
        next unless para.include?(query)

        ch_hash[:para] << {text: para, id: idx}
      end

      results << ch_hash
    end
   end
   
   results
end

get '/search' do
  if params[:query]
    @results = search_match(params[:query])
  end

  erb :search
end

not_found do
  redirect "/"
end