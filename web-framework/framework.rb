class App
  def initialize(&block)
    @routes = RouteTable.new(block)
  end

  def call(env)
    request = Rack::Request.new(env)
    @routes.each do |route|
      content = route.match(request)
      return [200, { 'Content-Type' => 'text/plain' }, [content.to_s]] if content
    end
    [404, {}, ['Not found']]
  end

  class RouteTable
    def initialize(block)
      @routes = []
      instance_eval(&block)
    end

    def get(route_spec, &block)
      @routes << Route.new(route_spec, block)
    end

    def each(&block)
      @routes.each(&block)
    end
  end

  Route = Struct.new(:route_spec, :block) do
    def match(request)
      path_components = request.path.split('/')
      spec_components = route_spec.split('/')

      return unless path_components.length == spec_components.length
      params = {}

      path_components.zip(spec_components).each do |path_comp, spec_comp|
        is_var = spec_comp.start_with?(':')
        if is_var
          key = spec_comp.sub(/\A:/, '')
          params[key] = URI.decode(path_comp)
        else
          return unless path_comp == spec_comp
        end
      end

      block.call(params)
    end
  end
end
