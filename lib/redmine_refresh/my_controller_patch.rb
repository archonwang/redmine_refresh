require_dependency 'my_controller'

module RedmineRefresh
  module MyControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        after_filter :save_helpdesk_preferences, :only => [:account]
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def save_helpdesk_preferences
        if request.post? && flash[:notice] == l(:notice_account_updated)
          User.current.pref[:refresh_interval] = ( params[:refresh] && params[:refresh][:refresh_interval] ? params[:refresh][:refresh_interval] : 60 ).to_i
        end
        User.current.pref.save
      end
    end
  end
end

MyController.send(:include, RedmineRefresh::MyControllerPatch) unless MyController.included_modules.include? RedmineRefresh::MyControllerPatch
