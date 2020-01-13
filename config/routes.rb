RedmineApp::Application.routes.draw do
  match 'query_per_project/redirect_to_user_query', :to => 'query_per_project#redirect_to_user_query', :via => [:get, :post]
end
