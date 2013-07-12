require 'erb'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req,route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    @response_built || @already_rendered
  end

  def redirect_to(url)
    @res.status = 302
    @res["location"] = url
    @response_built = true
    session.store_session(@res)
  end

  def render_content(body, content_type)
    @res.content_type = content_type
    @res.body = body
    @already_rendered = true
    session.store_session(@res)
  end

  def render(action_name)
    file_name = "views/#{self.class.to_s.underscore}/#{action_name}.html.erb"
    template = ERB.new(File.read(file_name)).result(binding)
    render_content(template, "html")
  end

  def invoke_action(action_name)
    send(action_name)
    render(action_name) unless already_rendered?
  end
end
