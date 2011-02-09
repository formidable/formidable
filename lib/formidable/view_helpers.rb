module Formidable
  module ViewHelpers

    def formidable_js
      "<script type=\"text/javascript\" src=\"//#{HOST}/api/formidable.js\"></script>".html_safe
    end

  end
end
