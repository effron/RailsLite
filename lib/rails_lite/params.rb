require 'uri'

class Params
  def initialize(req, route_params)
    @req = req
    parse_www_encoded_form(req.query_string) if req.query_string
    @params||={}
    @params.merge!(route_params)
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_json.to_s
  end

  private

  def parse_www_encoded_form(www_encoded_form)
    @params = hash_tree
    URI.decode_www_form(www_encoded_form).each do |key,value|
      keys = parse_key(key)
      string = ""
      keys.length.times do |i|
        string += "[keys[#{i}]]"
      end

      eval "@params#{string} = value"
    end
  end

  def parse_key(key)
    m = /(?<head>.*)\[(?<rest>.*)\]/.match(key)
    if m.nil?
      return [key]
    else
      parse_key(m[:head]) + [m[:rest]]
    end
  end

  def hash_tree
    Hash.new do |hash, key|
      hash[key] = hash_tree
    end
  end
end
