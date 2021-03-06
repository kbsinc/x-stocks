module Etl
  module Transform
    class Yahoo < Base

      def summary(stock, json)
        summary = json&.dig('context', 'dispatcher', 'stores')

        stock.outstanding_shares = summary&.dig('StreamDataStore', 'quoteData', stock.symbol, 'sharesOutstanding', 'raw')
        stock.payout_ratio = summary&.dig('QuoteSummaryStore', 'summaryDetail', 'payoutRatio', 'raw') * 100 rescue nil
        stock.yahoo_beta = summary&.dig('QuoteSummaryStore', 'defaultKeyStatistics', 'beta', 'raw')
        stock.yahoo_rec = summary&.dig('QuoteSummaryStore', 'financialData', 'recommendationMean', 'raw')
        stock.yahoo_rec_details = to_rec(summary&.dig('QuoteSummaryStore', 'recommendationTrend', 'trend'))
        stock.est_annual_dividend = summary&.dig('QuoteSummaryStore', 'summaryDetail', 'dividendRate', 'raw')
        stock.yahoo_discount = summary&.dig('ResearchPageStore', 'technicalInsights', stock.symbol, 'instrumentInfo', 'valuation', 'discount') rescue nil

        stock.update_dividends!
      end

      private

      def to_rec(data)
        return nil if data.blank?

        result = {}
        month = Date.today.at_beginning_of_month - 3.months
        data.reverse.each do |stat|
          result[month.to_s] = %w(strongBuy buy hold sell strongSell).map {|key| stat[key] }
          month += 1.month
        end

        result
      end

    end
  end
end
