#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/followings'
require 'atig/db/statuses'
require 'atig/db/lists'
require 'atig/util'
require 'thread'
require 'set'
require 'fileutils'

module Atig
  module Db
    class Db
      include Util
      attr_reader :followings, :statuses, :dms, :lists
      attr_accessor :me
      VERSION = 1

      def initialize(context, opt={})
        @log        = context.log
        @me         = opt[:me]
        @followings = Followings.new
        FileUtils.mkdir_p "cache/#{@me.screen_name}/"
        @statuses   = Statuses.new "cache/#{@me.screen_name}/status.#{VERSION}.db"
        @dms        = Statuses.new "cache/#{@me.screen_name}/dm.#{VERSION}.db"
        @lists      = Lists.new


        log :info, "initialize"

        @queue = SizedQueue.new 10
        daemon do
          f = @queue.pop
          log :debug, "transaction is poped"

          f.call self

          log :debug, "transaction is finished"
        end
      end

      def transaction(&f)
        log :debug, "transaction is registered"
        @queue.push f
      end
    end
  end
end
