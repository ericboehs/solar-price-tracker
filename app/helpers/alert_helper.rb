module AlertHelper
  def alert(type, message, **options)
    render Ui::AlertComponent.new(type: type, message: message, **options)
  end

  def success_alert(message, **options)
    alert(:success, message, **options)
  end

  def error_alert(message, **options)
    alert(:error, message, **options)
  end

  def warning_alert(message, **options)
    alert(:warning, message, **options)
  end

  def info_alert(message, **options)
    alert(:info, message, **options)
  end
end
