# middleman-portfolio

A low-drama portfolio generator for your site. Place images in a `portfolio/` or `portfolio/[project]` directory, and build. That's it.

1. Copy your images to `portfolio/[project]`.
2. Number the images numerically. `portfolio/foo/1.jpg`
3. Behold your new portfolio page at [http://localhost:4567/portfolio](http://localhost:4567/portfolio)

## Setup

```rb
activate :portfolio
```

## Advanced Configuration

```rb
activate :portfolio do |f|
  # builds to portfolio.html and projects to portfolio/[project].html 
  f.portfolio_dir = 'portfolio'
end
```