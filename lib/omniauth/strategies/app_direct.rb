require 'omniauth'

module OmniAuth
  module Strategies
    class AppDirect < OmniAuth::Strategies::OpenID
      include OmniAuth::Strategy

      AX = {
        :email => 'http://axschema.org/contact/email',
        :name => 'http://axschema.org/namePerson',
        :nickname => 'http://axschema.org/namePerson/friendly',
        :first_name => 'http://axschema.org/namePerson/first',
        :last_name => 'http://axschema.org/namePerson/last',
        :city => 'http://axschema.org/contact/city/home',
        :state => 'http://axschema.org/contact/state/home',
        :website => 'http://axschema.org/contact/web/default',
        :image => 'http://axschema.org/media/image/aspect11', 
        :roles => 'https://www.appdirect.com/schema/user/roles'
      }

      option :name, :appdirect
      option :required, [AX[:email], AX[:name], AX[:first_name], AX[:last_name], 'email', 'fullname', AX[:roles] ]
      option :optional, [AX[:nickname], AX[:city], AX[:state], AX[:website], AX[:image], 'postcode', 'nickname']
      option :store, ::OpenID::Store::Memory.new
      option :identifier, nil
      option :identifier_param, 'openid_url'

      def identifier
        i = options.identifier || request.params[options.identifier_param.to_s]
        i = nil if i == ''
        i
      end
      
      def request_phase
        identifier ? start : get_identifier
      end

      def start
        openid = Rack::OpenID.new(dummy_app, options[:store])
        response = openid.call(env)
        case env['rack.openid.response']
        when Rack::OpenID::MissingResponse, Rack::OpenID::TimeoutResponse
          fail!(:connection_failed)
        else
          response
        end
      end

      def get_identifier
        f = OmniAuth::Form.new(:title => 'OpenID Authentication')
        f.label_field('OpenID Identifier', options.identifier_param)
        f.input_field('url', options.identifier_param)
        f.to_response
      end

      uid { openid_response.display_identifier }

      info do
        sreg_user_info.merge(ax_user_info)
      end

      extra do
        {'response' => openid_response}
      end

      def callback_phase
        return fail!(:invalid_credentials) unless openid_response && openid_response.status == :success
        super
      end

      def ax_user_info
        ax = ::OpenID::AX::FetchResponse.from_success_response(openid_response)
        super
      end
    end
  end
end

OmniAuth.config.add_camelization 'appdirect', 'AppDirect'
OmniAuth.config.add_camelization 'app_direct', 'AppDirect'
OmniAuth.config.add_camelization 'app-direct', 'AppDirect'

