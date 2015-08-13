# middleman-portfolio

A low-drama portfolio generator for your [middleman](https://github.com/middleman/middleman) site. Place images in `source/portfolio/[project]/`, and build. That's it.

![Screenshot](https://raw.githubusercontent.com/dhulihan/middleman-portfolio/master/screenshot.jpg)

## Setup

Add this to `Gemfile`

```rb
gem "middleman-portfolio"
```

and

```sh
bundle install
```

Add to `config.rb`

```rb
activate :portfolio
```

Add projects to portfolio dir

```sh
cp -r project-a/ source/portfolio/ 
cp -r project-b/ source/portfolio/ 
```

Run `middleman server`

* [`http://localhost:4567/portfolio`](http://localhost:4567/portfolio) (if you're using `directory_indexes`)

* [`http://localhost:4567/portfolio/index.html`](http://localhost:4567/portfolio/index.html) (vanilla middleman)

or `middleman build` if you're ready to roll.


## Configuration (optional)

```rb
activate :portfolio do |f|
  # Looks in source/portfolio/ for projects and builds to build/portfolio/
  f.portfolio_dir = 'portfolio'

  # thumbnail width (px)
  f.thumbnail_width  = 200 

  # thumbnail height (px)
  f.thumbnail_height = 150
  
  # class added to thumbnail <img> tag
  f.thumbnail_class, "thumbnail"

  # class added to thumbnail <a> tag
  f.thumbnail_link_class ""

  # override default portfolio template (must be located in source/)
  f.portfolio_template "portfolio.html.erb"

  # override default project template (also must be in source/)
  f.project_template "project.html.erb"
end
```

### Custom Templates

You can create your own custom portfolio and project template pages by using the `portfolio_template` or `project_tamplate` options (see above).

Place your template anywhere in your `source/` dir. Take a look at the default [portfolio](https://github.com/dhulihan/middleman-portfolio/blob/master/lib/template/source/portfolio.html.erb) or [project](https://github.com/dhulihan/middleman-portfolio/blob/master/lib/template/source/project.html.erb) template for a good starting point. Here's an example portfolio page:

```rb
<!-- source/portfolio.html.erb -->
<% for project in project_resources %>
	<% link_to project.path, class: "thumbnail" do %>
		<%= image_tag project.metadata[:locals][:thumbnail_resources].first.path %>	
	<% end %>
<% end %>
```

## Additional Notes

* You can mix and match image types (`.jpg`, `.png`, `.gif`)
* [minimagick](https://github.com/minimagick/minimagick) is used for thumbnail generation. Make sure imagemagick is installed on your machine.


## TODO

* Page content from `data/`
* Non-project images (stored directly in portfolio/)
* FileWatcher monitor for new images