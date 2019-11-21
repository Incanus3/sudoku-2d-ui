require 'json'
require 'faraday'
require 'core'

module Sudoku
  class Client
    attr_reader :base_url

    def initialize(base_url)
      @base_url = base_url
    end

    def create_game
      response = Faraday.post "#{base_url}/games"
      id       = JSON.parse(response.body)['id']

      get_game(id)
    end

    def get_game(id)
      response = Faraday.get "#{base_url}/games/#{id}"
      matrix   = JSON.parse(response.body)['grid']

      Sudoku::Game.new(id, Sudoku::Puzzle.new(matrix))
    end
  end
end
