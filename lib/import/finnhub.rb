module Import
  class Finnhub < Base

    BASE_URL = 'https://finnhub.io/api/v1'
    FINNHUB_KEY = ENV['FINNHUB_KEY']

    def company(symbol)
      load_json(company_url(symbol))
    end

    def peers(symbol)
      load_json(peers_url(symbol))
    end

    private

    def company_url(symbol)
      "#{BASE_URL}/stock/profile2?symbol=#{symbol}&token=#{FINNHUB_KEY}"
    end

    def peers_url(symbol)
      "#{BASE_URL}/stock/peers?symbol=#{symbol}&token=#{FINNHUB_KEY}"
    end

  end
end