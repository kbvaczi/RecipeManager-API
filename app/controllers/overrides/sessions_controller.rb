module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController

    def create
      # Check

      # field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first
      # Override: look for model by uid instead of by email
      field = (resource_params.keys.map(&:to_sym) & [:uid]).first

      @resource = nil
      if field
        q_value = resource_params[field]

        if resource_class.case_insensitive_keys.include?(field)
          q_value.downcase!
        end

        # q = "#{field.to_s} = ? AND provider='email'"
        # Override: look for provider as iOS instead of email
        q = "#{field.to_s} = ? AND provider='iOS'"

        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
          q = "BINARY " + q
        end

        @resource = resource_class.where(q, q_value).first
      end

      if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        valid_password = @resource.valid_password?(resource_params[:password])
        if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
          render_create_error_bad_credentials
          return
        end
        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }
        @resource.save

        sign_in(:user, @resource, store: false, bypass: false)

        yield @resource if block_given?

        render_create_success
      elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        render_create_error_not_confirmed
      else
        render_create_error_bad_credentials
      end
    end

    protected

    def valid_params?(key, val)
      resource_params[:password] && key && val
    end

    private

    def resource_params
      # params.permit(*params_for_resource(:sign_in))
      # Override: permit uid parameter
      params.permit(*params_for_resource(:sign_in), :uid)

    end

  end
end
