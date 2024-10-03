module Compats
  class CheckUnchecked < Baseline::Service
    LIMIT = 10

    def call
      do_check
    end

    private

      def do_check
        count = 0

        RailsRelease
          .latest_major
          .reverse
          .each do |rails_release|

          rails_release
            .compats
            .unchecked
            .find_each do |compat|

            return unless count < LIMIT

            next if check_failed?(compat)

            begin
              Compats::Check.call compat
            rescue Compats::Check::Error => error
              ReportError.call error,
                compat_id: compat.id
              check_failed!(compat)
            else
              count += 1
            end
          end
        end
      end

      def check_failed_cache_key(compat)
        [
          :compat_check_failed,
          compat.id
        ].join(":")
      end

      def check_failed?(compat)
        Kredis.redis.exists? \
          check_failed_cache_key(compat)
      end

      def check_failed!(compat)
        Kredis.redis.setex \
          check_failed_cache_key(compat),
          1.week,
          nil
      end
  end
end
