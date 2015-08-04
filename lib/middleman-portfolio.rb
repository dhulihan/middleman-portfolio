# Extension namespace
class Portfolio < ::Middleman::Extension
  TEMPLATES_DIR = File.expand_path('../template/source/', __FILE__)

  option :portfolio_dir, 'portfolio', 'Default portfolio directory inside your project'
  
  attr_accessor :sitemap
  #alias :included :registered

  def initialize(app, options_hash={}, &block)
    # Call super to build options from the options_hash
    super

    # Require libraries only when activated
    # require 'necessary/library'

    # set up your extension
  end

  def after_configuration
    register_extension_templates
  end

  # create a resource for each portfolio project
  def project_resources    
    projects.collect {|project| project_resource(project)}
  end 

  def project_resource(project)
    source_file = template('project.html.erb')

    Middleman::Sitemap::Resource.new(app.sitemap, project_resource_path(project), source_file).tap do |resource|
      resource.add_metadata(options: { layout: false }, locals: {name: project})
    end
  end  

  def register_extension_templates
    # We call reload_path to register the templates directory with Middleman.
    # The path given to app.files must be relative to the Middleman site's root.
    templates_dir_relative_from_root = Pathname(TEMPLATES_DIR).relative_path_from(Pathname(app.root))
    app.files.reload_path(templates_dir_relative_from_root)
  end

  def template(path)
    full_path = File.join(TEMPLATES_DIR, path)
    raise "Template #{full_path} not found" if !File.exist?(full_path)
    full_path
  end

  # A Sitemap Manipulator, methods called via `sitemap`
  def manipulate_resource_list(resources)
    resources << portfolio_index_resource
    resources += project_resources
    return resources
  end

  def portfolio_path
    File.join(app.source_dir, options.portfolio_dir) 
  end

  def portfolio_index_path
    "#{options.portfolio_dir}.html"
  end 

  def portfolio_index_resource
    source_file = template('index.html.erb')
    Middleman::Sitemap::Resource.new(app.sitemap, portfolio_index_path, source_file).tap do |resource|
      resource.add_metadata(options: { layout: false }, locals: {projects: projects})
    end
  end

  def project_dirs
    #debug "Looking in #{options.portfolio_dir} for project subdirectories"
    Dir.glob(File.join(portfolio_path, '*')).select {|f| File.directory? f}
  end 

  def projects
    # Look for project directories
    projects = project_dirs.collect {|d| File.basename(d) }    
  end 

  def project_resource_path(project)
    File.join(options.portfolio_dir, "#{project}.html")
  end

  def debug(str)
    puts str
  end

  helpers do
    def my_helper
      my_feature_setting.to_sentence
    end
  end
end

::Middleman::Extensions.register(:portfolio, Portfolio)
