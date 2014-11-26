require 'redmine'

Redmine::Plugin.register :single_auth do
  name 'Redmine SSO plugin'
  author 'Pitin Vladimir Vladimirovich'
  author_url 'http://rmplus.pro'
  url 'http://rmplus.pro/plugins/single_auth'
  description 'A plugin for doing single one authentification and synhronize users and groups with LDAP'
  version '1.1'

  settings partial: 'settings/single_auth_settings',
           default: { 'server_env_var' => 'REMOTE_USER',
                      'logout_timeout' => 60,
                      'intranet_domains' => ['rm.local', 'redmine.local'],
                      'token_valid_time' => 360,
                      'screensaver_timeout' => 60 }
end

Rails.application.config.to_prepare do
  ApplicationController.send(:include, SingleAuth::ApplicationControllerPatch)
  AccountController.send(:include, SingleAuth::AccountControllerPatch)
  User.send(:include, SingleAuth::UserPatch)
  Object.send(:include, SingleAuth::ObjectPatch)
  token_valid_time = Setting.plugin_single_auth[:token_valid_time] || Redmine::Plugin::registered_plugins[:single_auth].settings[:default][:token_valid_time]
  redef_without_warning(ROTP, :DEFAULT_INTERVAL, token_valid_time.to_i)
end

require 'single_auth/view_hooks'

