class Ui::AlertComponent < ViewComponent::Base
  VARIANTS = {
    success: {
      container: "bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800 text-green-800 dark:text-green-200",
      icon: "text-green-400"
    },
    error: {
      container: "bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800 text-red-800 dark:text-red-200", 
      icon: "text-red-400"
    },
    warning: {
      container: "bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800 text-yellow-800 dark:text-yellow-200",
      icon: "text-yellow-400"
    },
    info: {
      container: "bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800 text-blue-800 dark:text-blue-200",
      icon: "text-blue-400"
    }
  }.freeze

  def initialize(type:, message:, dismissible: true, classes: "")
    @type = type.to_sym
    @message = message
    @dismissible = dismissible
    @classes = classes
  end

  private

  attr_reader :type, :message, :dismissible, :classes

  def container_classes
    base_classes = "rounded-md border px-4 py-3"
    variant_classes = VARIANTS.dig(type, :container) || VARIANTS.dig(:info, :container)
    [base_classes, variant_classes, classes].join(" ")
  end

  def icon_classes
    base_classes = "h-5 w-5"
    variant_classes = VARIANTS.dig(type, :icon) || VARIANTS.dig(:info, :icon)
    [base_classes, variant_classes].join(" ")
  end

  def icon_path
    case type
    when :success
      "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
    when :error
      "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
    when :warning
      "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.98-.833-2.75 0L3.064 16.5c-.77.833.192 2.5 1.732 2.5z"
    when :info
      "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
    else
      "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
    end
  end
end