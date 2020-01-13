
#module SettingsHelper

  def dc_fill_projects_dropdown(project_id)
    plist = Project.allowed_to(:current_user).order(:lft).all
    return project_tree_options_for_select(plist, :selected => Project.find_by_id(project_id) )
  end

  def dc_fill_custom_fields_dropdown(cf_name)
    return options_for_select(CustomField.all.where(:type => 'ProjectCustomField').collect{|column| column.name}, cf_name)
  end

#end
