module Etl
  class DataRefresh

    def company_data?(stock)
      return true if stock.saved_change_to_symbol?
      return false unless stock.saved_change_to_updated_at?
      prev_updated_at = stock.saved_change_to_updated_at.first
      prev_updated_at.nil? || prev_updated_at < 7.days.ago
    end

    def company_data!(stock)
      json = Etl::Extract::Iexapis.new.company(stock.symbol)
      Etl::Transform::Iexapis::new.company(stock, json)

      json = Etl::Extract::Finnhub.new.company(stock.symbol)
      Etl::Transform::Finnhub::new.company(stock, json)

      json = Etl::Extract::Finnhub.new.peers(stock.symbol)
      Etl::Transform::Finnhub::new.peers(stock, json)

      yahoo_data!(stock)
      finnhub_data!(stock)
      financial_data!(stock)
    end

    def company_data(stock)
      company_data!(stock) if company_data?(stock)
    end

    def financial_data!(stock)
      json = Etl::Extract::Finnhub.new.quote(stock.symbol)
      Etl::Transform::Finnhub::new.quote(stock, json)
    end

    def all_financial_data?
      updated_at = Config[:stock_price_updated_at]
      updated_at.nil? || updated_at < 1.hour.ago
    end

    def all_financial_data
      all_financial_data! if all_financial_data?
    end

    def all_financial_data!
      Stock.all.each do |stock|
        financial_data!(stock)
        sleep(1.0/30) # Limit up to 30 requests per second
      end
      Config[:stock_price_updated_at] = DateTime.now
    end

    def all_yahoo_data?
      updated_at = Config[:yahoo_updated_at]
      updated_at.nil? || updated_at < 1.day.ago
    end

    def all_yahoo_data
      all_yahoo_data! if all_yahoo_data?
    end

    def all_yahoo_data!
      Stock.all.each do |stock|
        yahoo_data!(stock)
        sleep(1.0) # Limit up to 1 requests per second
      end
      Config[:yahoo_updated_at] = DateTime.now
    end

    def yahoo_data!(stock)
      json = Etl::Extract::Yahoo.new.statistics(stock.symbol)
      Etl::Transform::Yahoo::new.statistics(stock, json)
    end

    def all_finnhub_data?
      updated_at = Config[:finnhub_updated_at]
      updated_at.nil? || updated_at < 1.day.ago
    end

    def all_finnhub_data
      all_finnhub_data! if all_finnhub_data?
    end

    def all_finnhub_data!
      Stock.all.each do |stock|
        finnhub_data!(stock)
        sleep(1.0) # Limit up to 1 requests per second
      end
      Config[:finnhub_updated_at] = DateTime.now
    end

    def finnhub_data!(stock)
      json = Etl::Extract::Finnhub.new.recommendation(stock.symbol)
      Etl::Transform::Finnhub::new.recommendation(stock, json)
    end

  end
end
