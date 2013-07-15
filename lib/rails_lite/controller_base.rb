require 'erb'
require_relative 'params'
require_relative 'session'
require_relative 'flash'
require_relative 'url_helper'
require 'active_support/core_ext'

class ControllerBase
  include UrlHelper

  attr_reader :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req,route_params)
    url_helpers
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def already_rendered?
    @response_built || @already_rendered
  end

  def redirect_to(url)
    store_data(@res)
    @res.status = 302
    @res["location"] = url
    @response_built = true
  end

  def render_content(body, content_type)
    @res.content_type = content_type
    @res.body = body
    @already_rendered = true
    store_data(@res)
  end

  def render(action_name = nil, options={})
    file_name = "views/#{self.class.to_s.underscore}/#{action_name}.html.erb"

    if options[:partial]
      path = options[:partial]
      file_name = "views/#{self.class.to_s.underscore}/#{path}.html.erb"
    end

    if options[:locals]
      options[:locals].each do |k, v|
        instance_variable_set(k, v)
      end
    end

    template = ERB.new(File.read(file_name)).result(binding)
    if options[:partial]
      return template
    end
    render_content(template, "html")
  end

  def invoke_action(action_name)
    send(action_name)
    render(action_name) unless already_rendered?
  end

  def store_data(res)
    session.store_session(res)
    flash.store_flash(res)
  end
end
