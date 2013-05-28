require 'sinatra'
require 'open-uri'
require 'cgi'
require 'kramdown'
require 'rexml/document'

TUMBLR_HOST = "http://realbusinessmen.tumblr.com"
IMAGE_CROPPER = "http://images.weserv.nl/"

configure :production do
  require 'newrelic_rpm'
end

configure do
  set :posts, []
  set :last_refresh, Time.now
  set :crop_cache, {}
end

before do
  logger.info("Post count is: #{settings.posts.size}, Last Refresh at: #{settings.last_refresh}, Crop cache size is: #{settings.crop_cache.size}")
  @size = params[:size] || params[:s] || "80"
end

get '/' do
  markdown File.read(File.join(settings.root, 'README.md'))
end

get '/avatar' do
  response = crop_image(find_nearest_size(@size.to_i), @size)

  status response.status.first
  content_type response.content_type
  response
end

get '/avatar/:hash' do
  index = params[:hash].hash % (settings.posts.size.zero? ? 50 : settings.posts.size)
  response = crop_image nearest_size_from_hash(@size.to_i, tumblr_fetch[index]), @size

  status response.status.first
  content_type response.content_type
  response
end

get '/refresh' do
  size_before_refresh = settings.posts.size
  refresh
  size_after_refresh = settings.posts.size
  "Found #{size_after_refresh - size_before_refresh} new photos"
end

def crop_image(url, size)
  hash = { url: ::CGI.escape(url.split("://").last), h: size, w: size, t: 'square', a: 't' }
  settings.crop_cache.fetch(hash) do |h|
    image_crop = URI(IMAGE_CROPPER)
    image_crop.query = h.to_a.map{|pair| pair.join('=') }.join('&')
    logger.info "Cropping image #{h.inspect}"
    response = image_crop.normalize.read
    settings.crop_cache[h] = response if (200...300).include?(response.status.first.to_i)
    response
  end
end

def find_nearest_size(size_as_int)
  nearest_size_from_hash(size_as_int, tumblr_fetch.sample)
end

def nearest_size_from_hash(size_as_int, tumblr_post_hash)
  tumblr_post_hash.reverse_each.find {|k,v| size_as_int <= k.to_i }.last
end

def tumblr_fetch
  return settings.posts unless (minutes_since_last_refresh >= 60) or settings.posts.empty?
  refresh
end

def tumblr_elements_to_hash(*tumblr_posts)
  tumblr_posts.map {|post| Hash[ post.map {|p| [p.attribute('max-width').value, p.text] if p.has_attributes? }.compact ] }
end

def refresh
  logger.info "Fetching new posts from Tumblr"
  t1 = Time.now
  response = tumblr_url.open
  t2 = Time.now
  logger.info "Tumblr fetch completed in #{t2 - t1} seconds."
  posts = REXML::Document.new(response).elements["tumblr/posts"]
  settings.posts |= tumblr_elements_to_hash(*posts.to_a)
  settings.last_refresh = Time.now
  settings.posts
end


def minutes_since_last_refresh
  distance = Time.now - settings.last_refresh
  distance / 60
end

def tumblr_url
  return @url unless @url.nil?
  url = URI(TUMBLR_HOST)
  url.path = "/api/read"
  url.query = "type=photo&num=50"
  @url = url.normalize
end
