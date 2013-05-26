module CouchbaseI18n
  class Translation
    class Records
      include Enumerable
      attr_reader :total_count, :current_page, :total_pages, :per_page
      def initialize(view, page: 1, per_page: 30, total_count: 0)
        @entries = view.entries
        @total_count = @entries.size
        @current_page = page 
        @total_pages = 1
        @per_page = per_page
      end

      delegate :[], to: :entries

      alias :limit_value :per_page

      def each
        @entries.each { |e| yield e }
      end

      def total_pages
        return 1 if total_count.zero?
        @total_pages ||= (total_count.to_f / per_page).ceil
      end

      def ==(other)
        other.is_a?(Array) ? entries == other : super
      end
    end
  end
end
