class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.request_method.downcase.to_sym == @http_method &&
    req.request_uri.path =~ @pattern
  end

  def run(req, res, params)
    $testcontroller = controller_class.new(req,res,params)
    $testcontroller.invoke_action(action_name)
  end

  def path
    "/#{controller_name}/#{@action_name}"
  end

  def controller_name
    @controller_class.to_s[0...-10].downcase
  end
end

class Router

  @@routes = []

  def self.routes
    @@routes
  end

  def initialize
    @@routes = []
  end

  def routes
    @@routes
  end

  def add_route(pattern, method, controller_class, action_name)
    @@routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      @@routes << Route.new(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @@routes.each do |route|
      return route if route.matches?(req)
    end

    nil
  end

  def run(req, res)
    route = match(req)

    return res.status = 404 unless route

    m = route.pattern.match(req.request_uri.path)
    params = {}

    m.names.each do |name|
      params[name] = m[name]
    end

    route.run(req, res, params)
  end

end
