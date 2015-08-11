# middleman-portfolio

A low-drama portfolio generator for your [middleman](https://github.com/middleman/middleman) site. Place images in `source/portfolio/[project]/` directory, and build. That's it.

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
  
  # css class added to thumbnail img tag
  f.thumbnail_class, "portfolio-thumbnail"
end
```

## Additional Notes

* You can mix and match image types (`.jpg`, `.png`, `.gif`)
* [minimagick](https://github.com/minimagick/minimagick) is used for thumbnail generation. Make sure imagemagick is installed on your machine.


## TODO

* Custom templates
* Page content from `data/`
* Non-project images (stored directly in portfolio/)