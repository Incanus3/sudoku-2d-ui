require 'json'
require 'faraday'
require 'dry-monads'
require 'sudoku/core'

module Sudoku
  class Client
    include Dry::Monads[:result]

    class UnexpectedResponse < RuntimeError
      attr_reader :response

      def initialize(response)
        super('Received unexpected response from server')

        @response = response
      end
    end

    attr_reader :base_url

    def initialize(base_url)
      @base_url = base_url
    end

    def create_game(grid = nil)
      headers  = grid ? { 'Content-Type' => 'application/json' } : {}
      data     = grid ? { grid: grid }                           : nil

      response = request(:post, '/games', data, headers)

      result_from(response)
    end

    def get_game(id)
      response = request(:get, "/games/#{id}")

      result_from(response)
    end

    def fill_cell(game, cell, number)
      data = { row: cell.row, column: cell.column, number: number }

      response = request(:patch, "/games/#{game.id}/fill_cell", data,
                         'Content-Type' => 'application/json')

      result_from(response)
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

      response = Faraday.public_send(method.downcase, url, data && JSON.dump(data), headers)

      puts <<~RESPONSE
        response:
          status: #{response.status}
          body: #{response.body.empty? ? nil : JSON.parse(response.body)}
      RESPONSE

      response
    end

    def result_from(response)
      case response.status
      when 200, 201
        data = JSON.parse(response.body)
        id, grid, finished = data.values_at('id', 'grid', 'finished')

        Success([Sudoku::Game.new(id, grid), finished])
      when 400
        Failure(JSON.parse(response.body)['error'])
      else
        raise UnexpectedResponse.new(response)
      end
    end
  end
end
