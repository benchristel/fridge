require "in_memory_storage"
require "file_storage"

module StorageFactory
  TYPES = %w(file memory)
  TYPE_VAR = "FRIDGE_STORAGE_TYPE"
  DIR_VAR  = "FRIDGE_STORAGE_DIR"

  def self.build(env)
    requested_type = env[TYPE_VAR] || "memory"

    unless TYPES.include? requested_type
      types_str = TYPES.map(&:inspect).join(", ")
      raise "Unrecognized #{TYPE_VAR} #{requested_type.inspect}. Options are #{types_str}."
    end

    case requested_type
    when "memory"
      InMemoryStorage.new

    when "file"
      unless env[DIR_VAR]
        raise "FRIDGE_STORAGE_TYPE=file requires FRIDGE_STORAGE_DIR to be set."
      end
      FileStorage.new env[DIR_VAR]

    end
  end
end
