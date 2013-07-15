require_relative 'router'

module UrlHelper
  def url_helpers
    Router.routes.each do |route|
      name = "#{route.controller_name}_#{route.action_name}_url".to_sym
      self.class.send(:define_method,name) do |*args|
        url = route.path
        args.each { |arg| url += "/#{arg}"}
        url
      end
    end
  end

  def link_to(name, url)
    "<a href=\"#{url}\">#{name}</a>"
  end

  def button_to(name, method, action_url)
    <<-ERB
      <form action="#{action_url}" method="post">
        <input type="hidden" name="_method" value="#{method}">
        <input type="submit" value="#{name}">
      </form>
    ERB
  end
end