module Fastlane
  module Actions
    module SharedValues
      CREATE_XCFRAMEWORK_CUSTOM_VALUE = :CREATE_XCFRAMEWORK_CUSTOM_VALUE
    end

    class CreateXcframeworkAction < Action
      def self.run(params)
        scheme = params[:scheme]
        product_name = params[:product_name] || scheme
        output_path = params[:output]
        target_version = "#{scheme}-#{params[:version]}"
        supporting_root = "#{output_path}/#{target_version}/Supporting Files"
        
        frameworks = []

        ["iphoneos", "iphonesimulator"].each do |sdk|
          archive_path = "#{output_path}/#{scheme}-#{sdk}.xcarchive"

          command = ["xcodebuild"]
          command << "archive"
          command << "-scheme #{scheme}"
          command << "-archivePath #{archive_path}"
          command << "-sdk #{sdk}"
          command << "SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
          command << "SWIFT_VERSION=5.0"
          command << "| xcpretty"

          Action.sh command.join(" ")

          frameworks.push("#{archive_path}/Products/Library/Frameworks/#{product_name}.framework")
          dSYM_path = "#{archive_path}/dSYMs/#{product_name}.framework.dSYM"
          FileUtils.mkdir_p("#{supporting_root}/#{sdk}/dSYMs/")
          FileUtils.cp_r(dSYM_path, "#{supporting_root}/#{sdk}/dSYMs/#{product_name}.framework.dSYM")

          bitcode_symbol_map_path = "#{archive_path}/BCSymbolMaps/"
          if Dir.exist?(bitcode_symbol_map_path)
            FileUtils.mkdir_p("#{supporting_root}/#{sdk}/BCSymbolMaps/")
            FileUtils.cp_r(bitcode_symbol_map_path, "#{supporting_root}/#{sdk}")
          end
        end

        framework_args = frameworks.map { |framework_path| "-framework '#{framework_path}'"}

        command = ["xcodebuild"]
        command << "-create-xcframework #{framework_args.join(" ")}"
        command << "-output '#{output_path}/#{target_version}/#{product_name}.xcframework'"
        command << "| xcpretty"

        Action.sh command.join(" ")

        return "#{output_path}/#{target_version}/"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       description: "The target version to archive",
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       description: "The scheme name to archive"),
          FastlaneCore::ConfigItem.new(key: :product_name,
                                       description: "The product name. Default is the same as scheme",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :output,
                                       description: "The output path of built artifacts")
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['CREATE_XCFRAMEWORK_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["onevcat"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
