class Portfolio < ::Middleman::Extension
  TEMPLATES_DIR = File.expand_path('../template/source/', __FILE__)

  option :portfolio_dir, 'portfolio', 'Default portfolio directory inside your source'
  option :generate_thumbnails, true, 'Do you want thumbnails?'
  option :thumbnail_width, 200, "Width (in px) for thumbnails"
  option :thumbnail_height, 150,  "Height (in px) for thumbnails"
  option :thumbnail_class, "thumbnail", "class for thumbnail <img>"
  option :thumbnail_link_class, "", "class for thumbnail <a> "
  option :portfolio_template, nil, "path to portfolio index page template"
  option :project_template, nil, "path to portfolio project page template"

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
    debug "Generating thumbnail of #{image}"
    dst = File.join(Portfolio.tmp_dir, thumbnail_name(image))
    if !File.exist?(dst)
      img = ::MiniMagick::Image.open(image)
      #img.resize "#{options.thumbnail_width}x#{options.thumbnail_height}"
      img = resize_to_fill(img, options.thumbnail_width, options.thumbnail_height)
      img.write(dst)
      raise "Thumbnail not generated at #{dst}" unless File.exist?(dst)
    else
      debug "#{dst} already exists"
    end 
    return dst
  end

  # Resize to fill target dims. Crop any excess. Will upscale.
  def resize_to_fill(img, width, height, gravity = 'Center')
    cols, rows = img[:dimensions]
    img.combine_options do |cmd|
      if width != cols || height != rows
        scale_x = width/cols.to_f
        scale_y = height/rows.to_f
        if scale_x >= scale_y
          cols = (scale_x * (cols + 0.5)).round
          rows = (scale_x * (rows + 0.5)).round
          cmd.resize "#{cols}"
        else
          cols = (scale_y * (cols + 0.5)).round
          rows = (scale_y * (rows + 0.5)).round
          cmd.resize "x#{rows}"
        end
      end
      cmd.gravity gravity
      cmd.background "rgba(255,255,255,0.0)"
      cmd.extent "#{width}x#{height}" if cols != width || rows != height
    end
    img = yield(img) if block_given?
    img
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
    proj_resources = projects.collect {|project|
      thumbs = project_thumbnail_resources(project)
      resources += thumbs
      project_resource(project, thumbs)
    }

    # Add project resources to main array
    resources += proj_resources
    # resources += project_thumbnail_resources(project)  
    resources << portfolio_index_resource(proj_resources)
    return resources
  end

  # get abs path to portfolio dir
  def portfolio_path
    File.join(app.source_dir, options.portfolio_dir) 
  end
  
  def portfolio_index_path
    "#{options.portfolio_dir}.html"
  end 

  def portfolio_index_resource(project_resources) 
    Middleman::Sitemap::Resource.new(app.sitemap, portfolio_index_path, source_file(:portfolio)).tap do |resource|
      resource.add_metadata(
        # options: { layout: false }, 
        locals: {
          projects: projects,
          options: options,
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

  # project_resource_path("/path/to/image.png") => "portfolio/project/image.png"
  def project_image_resource_path(project, image)
    File.join(options.portfolio_dir, project, File.basename(image))
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

  def project_resource(project, thumbnail_resources)
 
    Middleman::Sitemap::Resource.new(app.sitemap, project_resource_path(project), source_file(:project)).tap do |resource|
      resource.add_metadata(
        locals: {
          name: project,
          options: options,
          thumbnail_resources: thumbnail_resources,
        }
      )
    end
  end

  # create a resource for each portfolio project
  def project_resources(thumbnail_resources)
    projects.collect {|project| project_resource(project, thumbnail_resources)}
  end 

  # generate thumbnail and resource for an image in a project
  def project_thumbnail_resource(project, image)
    debug "Generating thumbnail of #{project}/#{image}"
    tmp_image = generate_thumbnail(image)

    # Add image to sitemap
    path = project_thumbnail_resource_path(project, File.basename(tmp_image))
    debug "Adding #{path} to #{project}"
    Middleman::Sitemap::Resource.new(app.sitemap, path, tmp_image).tap do |resource|
      resource.add_metadata(
        locals: {
          project: project,
          image: File.basename(image)
        }
      )
    end    
  end

  # generate thumbnail resource for each image in project dir
  def project_thumbnail_resources(project)
    resources = Array.new
    for image in project_images(project)
      resources << project_thumbnail_resource(project, image)
    end 

    return resources
  end

  # Generate resource path to project thumbnail, eg: "portfolio/example-project/1-thumbnail.jpg"
  def project_thumbnail_resource_path(project, thumbnail)
    File.join(options.portfolio_dir, project, thumbnail)
  end

  # get path to source file for page, use default if not set, freak out if missing 
  def source_file(page)
    # Load custom template or default
    opt = options.send("#{page}_template")

    if opt
      path = File.join(app.source_dir, opt)  
      raise "#{path} doesn't exist" unless File.exist?(path)
      return path 
    else
      return template("#{page}.html.erb") 
    end
  end

  # thumbnail_name("1.jpg") => "1-200x150.jpg"
  def thumbnail_name(image)
    name = "#{File.basename(image, '.*')}-#{options.thumbnail_width}x#{options.thumbnail_height}#{File.extname(image)}"
    name.gsub!(/ /, "-")
    return name
  end

  def debug(str)
    #puts str
  end

  helpers do
  end
end

::Middleman::Extensions.register(:portfolio, Portfolio)
