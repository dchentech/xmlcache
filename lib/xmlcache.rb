module Xmlcache
  @@models = {}

  def self.expire_fragment ar
    if @@models[ar.class].blank?
      model = ar.class.name.downcase
      @@models[ar.class] = if defined?((ar.class)::XmlcachePrefix)
               (ar.class)::XmlcachePrefix.map {|pre| "views/#{model}_#{pre}_" }
             else
               ["views/#{model}_"]
             end
    end

    @@models[ar.class].each do |key|
      Rails.logger.debug { "clear cache #{key}#{ar.id}" } if Rails.cache.delete "#{key}#{ar.id}"
    end
  end
end

module ActionView
 module Helpers
   module CacheHelper
     def cache_xml(name, &block)
       controller.cache_xml_fragment(block, name)
     end
   end
 end
end

module ActionController
 module Caching
   module Fragments
     def cache_xml_fragment(block, name, options = nil)
       unless perform_caching then block.call; return end
       buffer = eval("xml.target!",block.binding)
       if cache = read_fragment(name, options)
         buffer.concat(cache)
       else
         pos = buffer.length
         block.call
         write_fragment(name, buffer[pos..-1], options)
       end
     end

   end
 end
end


module ActiveRecord
  class Base
    after_save :expire_fragment
    after_destroy :expire_fragment

    def expire_fragment
      Xmlcache.expire_fragment self
    end
  end
end
