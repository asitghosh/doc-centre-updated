module PagesHelper
  def selected_if_path_includes(path)
    'selected' if request.fullpath.include?(path) && action_name != "show_individual"
  end
end
