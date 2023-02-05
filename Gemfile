source "https://rubygems.org"

ruby File.read('./.ruby-version').strip.split('-').last

gem "sinatra", "~>1.4.7"
gem "sinatra-contrib"
gem "erubis"

group :production do
  gem "puma"
end