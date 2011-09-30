require "rubygems"
require "fssm"

def filter_run(b, r)
  path = File.join(b, r)
  lib = /lib\/(.*)\.rb$/
  spec = /spec\/.*_spec\.rb$/
  view = /app\/views\/(.*)\//
  case path
    when lib then run_spec "spec/#{path.scan(lib)}_spec.rb"
    when view then run_spec "spec/controllers/#{path.scan(lib)}"
    when spec then run_spec path
  end
end

def run_spec(file)
  return unless file.end_with? '_spec.rb'
  puts "Running #{file}"
  system "spec", "-cb", file
end

FSSM.monitor do
  all = proc do
    update { |b, r| filter_run b, r }
    create { |b, r| filter_run b, r }
  end

  path "spec", &all
  path "lib", &all
end
