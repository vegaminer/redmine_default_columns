require_dependency 'queries_helper'

module QueryPerProject
  module Patches
    module QueriesHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          # alias_method_chain :retrieve_query, :default_query
          alias_method :retrieve_query_with_default_query, :retrieve_query_without_default_query
	  alias_method :retrieve_query_without_default_query, :retrieve_query_with_default_query
        end

      end

      module ClassMethods
      end

      module InstanceMethods
        def retrieve_query_without_default_query(klass=IssueQuery, use_session=true)
	  default_query(klass, use_session)	
	end

        def retrieve_query_with_default_query(klass=IssueQuery, use_session=true)
          if use_session
            # workaround bug in homepage plugin (if set to query_id, not possible to change custom at all)
            if !@project && params[:set_filter] && params[:query_id]
              params.delete(:query_id)
            end
            #
            if should_apply_for_default_query?
              get_default_query
              retrieve_query_without_default_query(klass, use_session) unless @query
            else
              retrieve_query_without_default_query(klass, use_session)
            end
          else
            retrieve_query_without_default_query(klass, use_session)
          end
        end

        require_dependency ('patches/qpp_queries_helper.rb')
      end
    end
    module SettingsHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

      end

      module ClassMethods
      end

      module InstanceMethods
        require_dependency ('patches/qpp_settings_helper.rb')
      end
    end
  end
end

unless QueriesHelper.included_modules.include? QueryPerProject::Patches::QueriesHelperPatch
  QueriesHelper.send(:include, QueryPerProject::Patches::QueriesHelperPatch)
end

unless SettingsHelper.included_modules.include? QueryPerProject::Patches::SettingsHelperPatch
  SettingsHelper.send(:include, QueryPerProject::Patches::SettingsHelperPatch)
end
