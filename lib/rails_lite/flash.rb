require 'json'
require 'webrick'

class Flash
  def initialize(req)
    req.cookies.each do |cookie|
      @flash = JSON.parse(cookie.value) if cookie.name == 'flash'
    end
    @flash ||= {}
    @new_flash = {}
  end

  def [](key)
    @flash[key]
  end

  def []=(key, val)
    @new_flash[key]=val
  end

  def store_flash(res)
    res.cookies << WEBrick::Cookie.new('flash', @new_flash.to_json)
  end
end

