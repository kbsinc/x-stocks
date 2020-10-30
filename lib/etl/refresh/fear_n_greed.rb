module Etl
  module Refresh
    class FearNGreed

      def image_url(logger = nil)
        Config.cached(:fear_n_greed_image_url, 1.hours) do
          Etl::Extract::FearNGreed.new(logger: logger).image_url
        end
      end

    end
  end
end