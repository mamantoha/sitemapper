require "xml"
require "./sitemapper/config"
require "./sitemapper/video_map"
require "./sitemapper/image_map"
require "./sitemapper/sitemap_options"
require "./sitemapper/paginator"
require "./sitemapper/builder"
require "./sitemapper/storage"
require "./sitemapper/ping_bot"

module Sitemapper
  VERSION = "0.5.0"
  @@configuration = Config.new

  def self.configure
    yield(@@configuration)
    @@configuration
  end

  def self.config
    @@configuration
  end

  def self.build
    builder = Sitemapper::Builder.new(config.host, config.max_urls, config.use_index)
    # The following two lines are duplicated from self.build with a block, since
    # the "with builder yield" is not working when just delegating and passing
    # the block
    with builder yield
    builder.generate
  end

  def self.build(host : String, max_urls : Int32, use_index : Bool)
    builder = Sitemapper::Builder.new(host, max_urls, use_index)
    with builder yield
    builder.generate
  end

  def self.store(sitemaps, path)
    storage = Sitemapper::Storage.init(sitemaps, config.storage.as(Symbol))
    storage.save(path)
  end

  def self.ping_search_engines(sitemap_url, **additional_engines)
    bot = Sitemapper::PingBot.new(sitemap_url)
    bot.ping(**additional_engines)
  end
end
