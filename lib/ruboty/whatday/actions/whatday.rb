require 'wikipedia'
require 'date'

module Ruboty
  module Whatday
    module Actions
      class Whatday < Ruboty::Actions::Base
        WIKIPEDIA_DOMAIN_JP = 'ja.wikipedia.org'
        WIKI_API_PARAMS = {
          format: 'json',
          action: 'query',
          prop: 'revisions',
          rvprop: 'content',
          titles: '',
        }

        SECTION = {
          event: 'できごと',
          birthday: '誕生日',
          death: '忌日',
          anniversary: '記念日',
          ceremony: '行事',
          other: 'その他'
        }

        def call
          message.reply(whatday)
        end

        private

        def whatday
          Wikipedia.configure {
            domain WIKIPEDIA_DOMAIN_JP
            path 'w/api.php'
          }

          yymm = to_search_keyword(message[:mmdd])
          if yymm.nil?
            message.reply '日付けが不正です。'
            return
          end
          puts yymm

          page = Wikipedia.find(yymm)
          if page.summary.nil?
            msg = "みつかりませんでした。"
          else
            content_h = parse_content(page.content)
            sections = target_sections(message[:keyword].chomp)
            pickup_content_h = pickup_content(content_h, sections)
            msg = format_msg(pickup_content_h)
          end
          message.reply msg
        end

        private

        def to_search_keyword(input_yymm)
          valid_date_str =
          case input_yymm
          when /\A[0-9]{4}\z/
            "2000-#{input_yymm[0...2]}-#{input_yymm[2...4]}"
          when /\A[0-9]{1,2}\/[0-9]{1,2}\z/
            "2000/#{input_yymm}"
          when /\A[0-9]{1,2}-[0-9]{1,2}\z/
            "2000-#{input_yymm}"
          else
            nil
          end

          Date.parse(valid_date_str).strftime('%-m月%-d日') rescue nil
        end

        def parse_content(content)
          h = {}
          key = ""
          content.each_line do |line|
            line.chomp!
            next if line.empty?
            if line.start_with?('==') && line.end_with?('==')
              key = line
              h[key] = []
            else
              h[key] << line if !key.empty? && line.start_with?('*')
            end
          end
          h
        end

        def target_sections(keyword)
          SECTION.select { |k,v| k.to_s.start_with?(keyword) }
        end

        def pickup_content(content_h, sections)
          return content_h if sections.empty?

          content_h.select { |k, _| sections.values.any? { |v| k.include?(v) } }
        end

        def format_msg(content_h)
          content_h.flatten.join("\n")
        end
      end
    end
  end
end
