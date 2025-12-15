require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Runner group
runner_group = project.main_group.children.find { |group| group.display_name == 'Runner' }

# Path to the GoogleService-Info.plist file
file_path = 'ios/Runner/GoogleService-Info.plist'

# Check if file exists on disk
unless File.exist?(file_path)
  puts "File #{file_path} not found on disk!"
  exit 1
end

# Check if already added
file_ref = runner_group.files.find { |f| f.path == 'GoogleService-Info.plist' }

if file_ref
  puts "GoogleService-Info.plist already linked."
else
  # Add file to group
  file_ref = runner_group.new_file('GoogleService-Info.plist')
  puts "Added file reference to Runner group."
end

# Find the Runner target
target = project.targets.find { |t| t.name == 'Runner' }

# Add to Resources build phase
resources_phase = target.resources_build_phase
build_file = resources_phase.files.find { |f| f.file_ref == file_ref }

if build_file
  puts "GoogleService-Info.plist already in Resources build phase."
else
  resources_phase.add_file_reference(file_ref)
  puts "Added to Resources build phase."
end

project.save
puts "Project saved."
