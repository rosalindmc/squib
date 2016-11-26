require 'json'
require 'forwardable'

module Squib
  class DataFrame
    include Enumerable

    def initialize(hash = {}, def_columns = true)
      @hash = hash
      columns.each { |col| def_column(col) } if def_columns
    end

    def def_column(col)
      raise "Column #{col} - does not exist" unless @hash.key? col
      method_name = snake_case(col)
      return if self.class.method_defined?(method_name) #warn people? or skip?
      define_singleton_method method_name do
        @hash[col]
      end
    end

    def each(&block)
      @hash.each(&block)
    end

    def [](i)
      @hash[i]
    end

    def []=(i, v)
      @hash[i] = v
    end

    def columns
      @hash.keys
    end

    def ncolumns
      @hash.keys.size
    end

    def col?(col)
      @hash.key? col
    end

    def row(i)
      @hash.inject(Hash.new) { |ret, (name, arr)| ret[name] = arr[i]; ret }
    end

    def nrows
      @hash.inject(0) { |max, (_n, col)| col.size > max ? col.size : max }
    end

    def to_json
      @hash.to_json
    end

    def to_pretty_json
      JSON.pretty_generate(@hash)
    end

    def to_h
      @hash
    end

    private

    def snake_case(str)
      str.strip.
          gsub(/\s+/,'_').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z]+)([A-Z])/,'\1_\2').
          downcase.
          to_sym
    end

  end
end