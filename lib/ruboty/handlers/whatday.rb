require "ruboty/whatday/actions/whatday"

module Ruboty
  module Handlers
    class Whatday < Base
      on(
        /(date) (?<mmdd>.+) (?<keyword>.+)*/,
        name: 'whatday',
        description: 'output what day'
      )

      def whatday(message)
        Ruboty::Whatday::Actions::Whatday.new(message).call
      end
    end
  end
end
