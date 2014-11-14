module VIM
  class << self
    def evaluate(*args)
      # no need to work in test
    end

    def command(*args)
      # no need to work in test
    end
  end
end

require "pry"
require_relative "../plugin/github_url"
