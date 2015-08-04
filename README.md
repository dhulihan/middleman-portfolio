# middleman-portfolio

A low-drama portfolio generator for your site. Place images in a `portfolio/` folder, then build. 

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
  f.portfolio_dir = 'whatever'
  f.bar = 'something else'
end
```