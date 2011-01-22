require "json"
require "logstash/time"
require "logstash/namespace"
require "uri"

# General event type. Will expand this in the future.
class LogStash::Event
  public
  def initialize(data=Hash.new)
    @cancelled = false
    @data = {
      "@source" => "unknown",
      "@type" => nil,
      "@tags" => [],
      "@fields" => {},
    }.merge(data)

    if !@data.include?("@timestamp")
      @data["@timestamp"] = LogStash::Time.now.utc.to_iso8601
    end
  end # def initialize

  public
  def self.from_json(json)
    return LogStash::Event.new(JSON.parse(json))
  end # def self.from_json

  public
  def cancel
    @cancelled = true
  end

  public
  def cancelled?
    return @cancelled
  end

  public
  def to_s
    return "#{timestamp} #{source}: #{message}"
  end # def to_s

  public
  def timestamp; @data["@timestamp"]; end # def timestamp
  def timestamp=(val); @data["@timestamp"] = val; end # def timestamp=

  public
  def source; @data["@source"]; end # def source
  def source=(val) 
    if val.is_a?(URI)
      @data["@source"] = val.to_s
      @data["@source_host"] = val.host
      @data["@source_path"] = val.path
    else
      @data["@source"] = val
    end
  end # def source=

  public
  def message; @data["@message"]; end # def message
  def message=(val); @data["@message"] = val; end # def message=

  public
  def type; @data["@type"]; end # def type
  def type=(val); @data["@type"] = val; end # def type=

  public
  def tags; @data["@tags"]; end # def tags
  def tags=(val); @data["@tags"] = val; end # def tags=

  # field-related access
  public
  def [](key)
    # If the key isn't in fields and it starts with an "@" sign, get it out of data instead of fields
    if ! @data["@fields"].has_key?(key) and key.slice(0,1) == "@"
      @data[key]
    # Exists in @fields (returns value) or doesn't start with "@" (return null)
    else
      @data["@fields"][key]
    end
  end # def []
  
  def []=(key, value); @data["@fields"][key] = value end # def []=
  def fields; return @data["@fields"] end # def fields
  
  public
  def to_json; return @data.to_json end # def to_json
  def to_hash; return @data end # def to_hash

  public
  def overwrite(event)
    @data = event.to_hash
  end

  public
  def include?(key); return @data.include?(key) end

  # Append an event to this one.
  public
  def append(event)
    self.message += "\n" + event.message 
    self.tags |= event.tags

    # Append all fields
    event.fields.each do |name, value|
      if self.fields.include?(name)
        puts "Merging field #{name}"
        self.fields[name] |= value
      else
        puts "Setting field #{name}"
        self.fields[name] = value
      end
    end # event.fields.each
  end # def append
end # class LogStash::Event
