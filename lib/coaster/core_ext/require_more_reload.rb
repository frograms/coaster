def require_more
  required_file_path = caller[0].split(':', 2).first
  load_name = nil
  load_path_index = $LOAD_PATH.each_with_index do |load_path, ix|
    scanned = required_file_path.scan(/(#{load_path})#{File::SEPARATOR}(.*)/).first
    next false unless scanned
    load_name = scanned[1]
    break ix
  end

  return false unless load_path_index

  more_load_paths = $LOAD_PATH.drop(load_path_index + 1)
  more_load_paths.each do |load_path|
    path = File.join(load_path, load_name)
    if File.exist?(path)
      loaded = require(path)
      loaded = load(path) unless loaded
      return loaded
    end
  end

  raise LoadError, "cannot require more -- #{load_name}"
end
