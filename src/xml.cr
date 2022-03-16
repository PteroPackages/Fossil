require "json"
require "xml"

module Fossil::XMLFmt
  def self.serialize(model) : String
    hash = Hash(String, JSON::Any).from_json model
    XML.build(indent: "  ") { |xml| into_xml xml, hash }
  end

  def self.into_xml(xml, obj)
    case obj
    when .is_a?(Hash), .as_h?
      (obj.is_a?(Hash) ? obj : obj.as_h).each do |k, v|
        xml.element(k) { into_xml xml, v }
      end
    when .as_i64?, .as_s?, .as_bool?, .as_nil
      xml.text obj.to_s
    when .as_a?
      obj.as_a.each do |i|
        xml.element("item") { into_xml xml, i }
      end
    end
  end

  # TODO: for deserialization
  # def self.into_hash : Nil
  # end
end
