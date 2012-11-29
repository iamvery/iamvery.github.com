# Based on http://mikeferrier.com/2011/04/29/blogging-with-jekyll-haml-sass-and-jammit/
desc 'Parse haml layouts'
task :haml do
  puts 'Parsing Haml layouts...'
  system(%{
    cd _layouts/ && 
    for f in *.haml; do [ -e $f ] && haml $f ${f%.haml}.html; done
  })
  puts 'done.'
end

desc 'Launch jekyll preview'
task :preview => :haml do
  system 'jekyll --auto --server'
end

desc 'Build site'
task :build => :haml do
  system './build.sh'
end