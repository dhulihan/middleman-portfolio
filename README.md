# middleman-portfolio

A low-drama portfolio generator for your site. Place images in `source/portfolio/[project]` directory, and build. That's it.

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

[`http://localhost:4567/portfolio`](http://localhost:4567/portfolio) (if you're using `directory_indexes`)

[`http://localhost:4567/portfolio/index.html`](http://localhost:4567/portfolio/index.html) (vanilla middleman)


## Configuration (optional)

```rb
activate :portfolio do |f|
  # Looks in source/portfolio/ for projects and builds to build/portfolio/
  f.portfolio_dir = 'portfolio'

  f.thumbnail_width = 200
  f.thumbnail_height =150
  
  # css class added to thumbnails
  f.thumbnail_class, "portfolio-thumbnail"
end
```

## TODO

* Non-project images (stored directly in portfolio/)