require 'sinatra'
require 'open-uri'

TUMBLR_HOST = "http://realbusinessmen.tumblr.com"
IMAGE_CROPPER = "http://images.weserv.nl/"

get '/' do
  size = params[:size] || params[:s] || "80"
  crop_image(find_nearest_size(size.to_i), size).to_s
end

get '/avatar' do
  size = params[:size] || params[:s] || "80"
  response = crop_image(find_nearest_size(size.to_i), size).open
  status response.status.first
  content_type response.content_type
  response.read
end

def crop_image(url, size)
  image_crop = URI(IMAGE_CROPPER)
  hash = { url: CGI.escape(url.split("://").last), h: size, w: size, t: 'square', a: 't' }
  image_crop.query = hash.to_a.map{|pair| pair.join('=') }.join('&')
  image_crop.normalize
end

def find_nearest_size(size_as_int)
  tumblr_photo_urls_by_size.reverse_each.find {|k,v| size_as_int <= k.to_i }.last
end

def tumblr_photo_urls_by_size
  Hash[
    random_tumblr_post_element.map {|p| [p.attribute('max-width').value, p.text]}
  ]
end

def random_tumblr_post_element
  tumblr_fetch.to_a.shuffle.pop
end

def tumblr_fetch
  require 'rexml/document'
  response = tumblr_url.open
  REXML::Document.new(response).elements["tumblr/posts"]
end

def tumblr_url
  return @url unless @url.nil?
  url = URI(TUMBLR_HOST)
  url.path = "/api/read"
  url.query = "type=photo&num=50"
  @url = url.normalize
end
