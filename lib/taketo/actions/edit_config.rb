module Taketo
  module Actions

    class EditConfig < BaseAction
      def run
        editor = ENV["EDITOR"]
        system("#{editor} #{options[:config]}")
      end
    end

  end
end


