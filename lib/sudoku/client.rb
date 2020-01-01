require 'json'
require 'faraday'
require 'sudoku/core'

module Sudoku
  class Client
    attr_reader :base_url

    def initialize(base_url)
      @base_url = base_url
    end

    def create_game(grid = nil)
      headers  = grid ? { 'Content-Type' => 'application/json' } : {}
      data     = grid ? { grid: grid } : nil
      response = request(:post, '/games', data, headers)

      game_from(response)
    end

    def get_game(id)
      response = request(:get, "/games/#{id}")
      matrix   = JSON.parse(response.body)['grid']

      Sudoku::Game.new(id, Sudoku::Puzzle.new(matrix))
    end

    def fill_cell(game, cell, number)
      data = { row: cell.row, column: cell.column, number: number }

      response = request(:patch, "/games/#{game.id}/fill_cell", data,
                         'Content-Type' => 'application/json')

      game_from(response)
    end

    private

    def request(method, path, data = nil, headers = {})
      url = base_url + path

      puts <<~REQUEST
        #{'=' * 80}
        request:
          #{method.upcase} #{url}
          body: #{data}
          headers: #{headers}
      REQUEST

      response = Faraday.send(method.downcase, url, data && JSON.dump(data), headers)

      puts <<~RESPONSE
        response:
          status: #{response.status}
          body: #{response.body.empty? ? nil : JSON.parse(response.body)}
      RESPONSE

      response
    end

    def game_from(response)
      data = JSON.parse(response.body)

      Sudoku::Game.new(data['id'], Sudoku::Puzzle.new(data['grid']))
    end
  end
end
