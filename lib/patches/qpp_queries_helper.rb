#module QueriesHelper
  def should_apply_for_default_query?
    if !params[:query_id].blank? || params[:format]=="csv"
      return false
    elsif api_request? || params[:set_filter] || session[:query].nil? ||
           session[:query][:project_id] != (@project ? @project.id : nil) ||
        session[:query][:column_names].nil?
      return true
    end
    return false
  end

   def get_default_query
     @query = nil
     if params[:set_filter].nil?
       prj = Project.find_by_id(QPP_Constants::settings['query_templates_project_id'])
       custom_name = QPP_Constants::settings['type_custom_field_name']
       if @project
         query_default_name = QPP_Constants::settings['my_default_query_name']
         @query = Query.where(["name = ? AND project_id = ? AND user_id = ?",query_default_name, @project.id, User.current.id]).first
         unless @query
           query_default_name = QPP_Constants::settings['default_query_name']
           @query = Query.where(["name = ? AND project_id = ?",query_default_name, @project.id]).first
         end
         unless @query
           if prj
             cv=@project.custom_values.detect do |custom_value|
               true if custom_value.custom_field.name == custom_name && !custom_value.value.blank?
             end
             template_str = ( cv ? cv.value.to_s.strip : QPP_Constants::PROJECT_DEFAULT_SUFFIX )
             @query = Query.where(["name = ? AND project_id = ?",QPP_Constants::QUERY_DEFAULT_PFX + template_str,prj.id]).first
           end
         end
       else
         query_default_name = QPP_Constants::settings['my_global_query_name']
         @query = Query.where(["name = ? AND project_id IS NULL AND user_id = ?",query_default_name, User.current.id]).first
         unless @query
           @query = Query.where(["name = ? AND project_id IS NULL",QPP_Constants::QUERY_DEFAULT_GLOBAL_NAME]).first if prj
         end
       end
       if @query && @project
         @query = @query.dup
         @query.project = @project
         @query.name=QPP_Constants::QUERY_TEMP_NAME
         session[:query] = {:project_id => @query.project_id}
       end
     end
   end
#end
