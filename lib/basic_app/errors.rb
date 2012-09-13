module BasicApp

 class ErbTemplateError < StandardError
   def initialize(message = "ERB template error")
     super
   end
 end

 class MustacheTemplateError < StandardError
   def initialize(message = "Mustache template error")
     super
   end
 end

 class AssetConfigurationError < StandardError
   def initialize(message = "Asset configuration error")
     super
   end
 end

end
