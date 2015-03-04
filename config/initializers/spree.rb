# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'


require 'spree/product_filters'

Spree.config do |config|
  config.shipping_instructions = true
  config.checkout_zone = ENV["CHECKOUT_ZONE"]
  config.address_requires_state = true

  # 12 should be Australia. Hardcoded for CI (Jenkins), where countries are not pre-loaded.
  if Rails.env.test? or Rails.env.development?
    config.default_country_id = 12
  else
    country = Spree::Country.find_by_name(ENV["DEFAULT_COUNTRY"])
    config.default_country_id = country.id if country.present?
  end

  config.admin_interface_logo = "RE-long.jpg"

  # -- spree_paypal_express
  # Auto-capture payments. Without this option, payments must be manually captured in the paypal interface.
  config.auto_capture = true
  #config.override_actionmailer_config = false
end

# TODO Work out why this is necessary
# Seems like classes within OFN module become 'uninitialized' when server reloads
# unless the empty module is explicity 'registered' here. Something to do with autoloading?
module OpenFoodNetwork
end

# Add calculators category for enterprise fees
module Spree
  module Core
    class Environment
      class Calculators
        include EnvironmentExtension

        attr_accessor :enterprise_fees
      end
    end
  end
end

Rails.application.config.spree.calculators.enterprise_fees = [Spree::Calculator::FlatPercentItemTotal,
                                                              Spree::Calculator::FlatRate,
                                                              Spree::Calculator::FlexiRate,
                                                              Spree::Calculator::PerItem,
                                                              Spree::Calculator::PriceSack,
                                                              OpenFoodNetwork::Calculator::Weight]

# Forcing spree to always allow SSL connections
# Since we are using config.force_ssl = true
# Without this we get a redirect loop: see https://groups.google.com/forum/#!topic/spree-user/NwpqGxJ4klk
SslRequirement.module_eval do
  protected

  def ssl_allowed?
    true
  end
end
