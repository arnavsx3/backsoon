Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src :self
    policy.img_src :self, :data
    policy.object_src :none
    policy.script_src :self
    policy.style_src :self
    policy.connect_src :self
    policy.base_uri :self
    policy.form_action :self
    policy.frame_ancestors :none
  end

  # A session-scoped nonce works with Turbo navigation and Rails import maps.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
  config.content_security_policy_nonce_auto = true
end
