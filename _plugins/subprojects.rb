require 'set'
module Jekyll
  class SubprojectGenerator < Generator
    safe true
    priority :high # Subprojects need to be imported before other plugins run

    def generate(site)

      # Contains all static files required by tutorials
      new_static_files = []

      # Generate configured tutorials
      (site.config['subprojects'] || []).each do |location|
        Jekyll.logger.info("Subproject:", "#{location}")

        # Make sure the tutorial directory and README exist
        unless File.directory?(site.in_source_dir(location))
          message ="No subproject found at #{location}"
          Jekyll.logger.error("Tutorials:", message)
          raise RuntimeError, message
        end

        # Namespace images to avoid filename collisions
        image_dest = File.join("images", location)

        # Register the tutorial README as a page
        pages = Dir.chdir(location) do 
          Dir.foreach(".").reject{ |f| File.directory?(f) || f.end_with?(".") }.select{ |f| Utils.has_yaml_header?(site.in_source_dir(File.join(location, f))) }
        end

        unless pages.empty?()
          Jekyll.logger.info("Adding pages:", pages.join(", "))
          pages.each do |file|
            # Create the Jekyll Page
            page = Page.new(site, site.source, location, file)
            
            # Rewrite markdown image links and HTML src tags to use the new namespaced path.
            if page.content
               page.content = page.content.gsub(/\]\(images\//, "](/" + image_dest + "/")
               page.content = page.content.gsub(/src="images\//, "src=\"/" + image_dest + "/")
               page.content = page.content.gsub(/\]\(\.\/images\//, "](/" + image_dest + "/")
               page.content = page.content.gsub(/src="\.\/images\//, "src=\"/" + image_dest + "/")
            end

            site.pages << page
          end
        end

        # Copy all images to images/location/
        images = File.join(location, 'images')

        next unless File.directory?(site.in_source_dir(images))

        FileUtils.mkdir_p(site.in_source_dir(image_dest))

        static_files = Dir.foreach(images).reject{ |f| File.directory?(f) || f.end_with?(".")}
        static_files.each do |image|
          from = File.join(images, image)
          to = File.join(image_dest, image)
          Jekyll.logger.debug("Registering:", "#{from}")

          # Skip the copy if the file already exists. This solves endless rebuild loops.
          unless File.exist?(site.in_source_dir(to))
            Jekyll.logger.debug("Writing:", "#{to}")
            FileUtils.cp(site.in_source_dir(from), site.in_source_dir(to))
          end

          # Save this static file for later
          new_static_files << StaticFile.new(site, site.source, image_dest, image)
        end
      end

      # Reject all existing statics
      existing_statics = site.static_files.map { |sf| sf.relative_path.delete_prefix('/') }.to_set
      new_static_files.reject! { |static_file| existing_statics.include?(static_file.relative_path) }

      # Register all statics
      site.static_files += new_static_files
    end
  end
end
