def fixture_data
  require "yaml"
  YAML.load_file(File.join(__dir__, "fixture_data.yml"))
end
