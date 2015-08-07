# Extension namespace
class Portfolio < ::Middleman::Extension
  TEMPLATES_DIR = File.expand_path('../template/source/', __FILE__)

  option :portfolio_dir, 'portfolio', 'Default portfolio directory inside your project'
  option :generate_thumbnails, true, 'Do you want thumbnails?'
  option :thumbnail_width, 200, "Width (in px) for thumbnails"
  option :thumbnail_height, 150,  "Height (in px) for thumbnails"

  attr_accessor :sitemap
  #alias :included :registered

  class << self
    def cleanup
      # Delete tmp files
      tmp_files = Dir.glob(File.join(tmp_dir, "*")).select {|f| File.file?(f)}
      tmp_files.each {|f| 
        File.delete(f)
        debug "#{f} not deleted" if File.exist?(f)
      }
      Dir.rmdir(tmp_dir)
    end

    # path to temp dir for storing intermediate files
    def tmp_dir
      File.join(Dir.tmpdir, "middleman-portfolio")
    end
  end 

  def initialize(app, options_hash={}, &block)
    # Call super to build options from the options_hash
    super

    # Create tmp dir
    Dir.mkdir(Portfolio.tmp_dir) unless Dir.exist?(Portfolio.tmp_dir)

    # Require libraries only when activated
    # require 'necessary/library'

    # set up your extension
    app.after_build do
      Portfolio.cleanup
    end 
  end

  def after_configuration
    register_extension_templates
  end


  # generate thumbnail OUTSIDE of build dir
  def generate_thumbnail(image)
    img = ::MiniMagick::Image.open(image)
    img.resize "#{options.thumbnail_width}x#{options.thumbnail_height}"
    dst = File.join(Portfolio.tmp_dir, thumbnail_name(image))
    img.write(dst)
    raise "Thumbnail not generated at #{dst}" unless File.exist?(dst)
    return dst
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

  def manipulate_resource_list(resources)
    # Load in reverse order for easier building
    resources += project_thumbnail_resources
    resources += project_resources
    resources << portfolio_index_resource
    return resources
  end

  # get abs path to portfolio dir
  def portfolio_path
    File.join(app.source_dir, options.portfolio_dir) 
  end

  def portfolio_index_path
    "#{options.portfolio_dir}.html"
  end 

  def portfolio_index_resource
    source_file = template('index.html.erb')
    Middleman::Sitemap::Resource.new(app.sitemap, portfolio_index_path, source_file).tap do |resource|
      resource.add_metadata(
        # options: { layout: false }, 
        locals: {
          projects: projects,
          project_resources: project_resources 
        }
      )
    end
  end

  # get absolute path to project directory, eg: /path/to/site/portfolio/example-project/
  def project_dir(project)
    File.join(portfolio_path, project)
  end 

  # array of images for a project
  def project_images(project)
    Dir.glob(File.join(project_dir(project), '*'))
  end

  # Get all projects located in options.portfolio_dir
  def project_dirs
    #debug "Looking in #{options.portfolio_dir} for project subdirectories"
    Dir.glob(File.join(portfolio_path, '*')).select {|f| File.directory? f}
  end 

  def projects
    # Look for project directories
    projects = project_dirs.collect {|d| File.basename(d) }    
  end 

  # portfolio/example-project.html
  def project_resource_path(project)
    File.join(options.portfolio_dir, "#{project}.html")
  end

  # create a resource for each portfolio project
  def project_resources    
    projects.collect {|project| project_resource(project)}
  end 

  def project_resource(project)
    source_file = template('project.html.erb')

    Middleman::Sitemap::Resource.new(app.sitemap, project_resource_path(project), source_file).tap do |resource|
      resource.add_metadata(
        locals: {
          name: project,
          images: project_images(project)
        }
      )
    end
  end

  # get array of project thumbnail resources
  def project_resources    
    projects.collect {|project| project_resource(project)}
  end 

  # generate thumbnail resource for each image in project dir
  def project_thumbnail_resources()
    resources = Array.new
    
    for project in projects
      for image in project_images(project)
        resources << project_thumbnail_resource(project, image)
      end 
    end

    return resources
  end

  def project_thumbnail_resource(project, image)
    debug "Generating thumbnail of #{project}/#{image}"
    tmp_image = generate_thumbnail(image)

    # Add image to sitemap
    Middleman::Sitemap::Resource.new(app.sitemap, project_thumbnail_resource_path(project, File.basename(tmp_image)), tmp_image)    
  end

  # Generate resource path to project thumbnail, eg: "portfolio/example-project/1-thumbnail.jpg"
  def project_thumbnail_resource_path(project, thumbnail)
    File.join(options.portfolio_dir, project, thumbnail)
  end

  # thumbnail_name("1.jpg") => "1-200x150.jpg"
  def thumbnail_name(image)
    "#{File.basename(image, '.*')}-#{options.thumbnail_width}x#{options.thumbnail_height}#{File.extname(image)}"
  end

  def debug(str)
    puts str
  end

  helpers do
    def project_dir(project)

    end

    def thumbnails
    end

    def thumbnail(image)
    end

    # Get uri to main thumbnail for a project
    def project_thumbnail(project)
      images
    end

    # get uri to project
    def project_path(project)
    end
  end
end

::Middleman::Extensions.register(:portfolio, Portfolio)
