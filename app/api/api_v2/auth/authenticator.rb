module APIv2
  module Auth
    class Authenticator

      def initialize(request, params)
        @request = request
        @params  = params
      end

      def authentic?
        token && signature_match? && fresh?
      end

      def token
        @token ||= APIToken.where(access_key: @params[:access_key]).first
      end

      def signature_match?
        @params[:signature] == Utils.hmac_signature(token.secret_key, payload)
      end

      def fresh?
        timestamp = Time.at(@params[:tonce].to_i / 1000.0)
        timestamp > 5.minutes.ago
      end

      def payload
        hash = @params.select {|k,v| !%w(route_info signature).include?(k) }
        URI.unescape(hash.to_param)
      end

    end
  end
end