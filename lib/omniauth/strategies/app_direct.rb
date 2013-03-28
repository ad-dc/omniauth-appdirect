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

      attr_reader :access_token

      option :name, :appdirect
      option :required, [AX[:email], AX[:name], AX[:first_name], AX[:last_name], 'email', 'fullname', AX[:roles] ]
      option :optional, [AX[:nickname], AX[:city], AX[:state], AX[:website], AX[:image], 'postcode', 'nickname']
      option :store, ::OpenID::Store::Memory.new
      option :identifier, nil
      option :identifier_param, 'openid_url'

      def identifier
        i = 'https://www.appdirect.com/openid/id'
        i = env['rack.session']['openid_url'] if env && env['rack.session'] && env['rack.session']['openid_url']
        i
      end
      
      def get_identifier
        env['rack.session']['openid_url'] || 'https://www.appdirect.com/openid/id'
      end

      def callback_phase
        return fail!(:invalid_credentials) unless openid_response && openid_response.status == :success
        super
      end

      def ax_user_info
        ax = ::OpenID::AX::FetchResponse.from_success_response(openid_response)
        super
      end

      def get_appdirect_attr(attribute)
        openid_response.message.get_arg('http://openid.net/srv/ax/1.0', attribute)
      end

      # Parsing the roles out of the return schema. 
      # Roles might be in the value.ext4 field if there is only one, 
      # or possibly in the value.ext4.N fields if there are many. 
      # Assume the worst: check both places  and reject any nils from the result.
      def roles
        [get_appdirect_attr('value.ext4')].tap do |roles|     # Roles array starts with one value: value.ext4 (possibly nil)
          get_appdirect_attr('count.ext4').to_i.times do |i|  # Then we use the roles count to cycle through each role variable 
            roles << get_appdirect_attr("value.ext4.#{i+1}")  # And shift it into the array
          end
        end.reject {|v| !v } # remove nils 
      end

      extra do          
        { :roles => roles }
      end

    end
  end
end

OmniAuth.config.add_camelization 'appdirect', 'AppDirect'
OmniAuth.config.add_camelization 'app_direct', 'AppDirect'
OmniAuth.config.add_camelization 'app-direct', 'AppDirect'

