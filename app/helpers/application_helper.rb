module ApplicationHelper
  def bootstrap_class_for(flash_type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end
  
  def show_svg(path)
    File.open("app/assets/images/icons/#{path}", "rb") do |file|
      raw file.read
    end
  end
end
