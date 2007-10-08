# Xmlcache
 module ActionView
   module Helpers
     module CacheHelper
       def cache_xml(name ={}, &block)
         @controller.cache_xml_fragment(block, name)
       end
     end
   end
 end
  
 module ActionController
   module Caching
     module Fragments
       def cache_xml_fragment(block, name = {}, options = nil)
         unless perform_caching then block.call; return end
         buffer = eval("xml.target!",block.binding)
         if cache = read_fragment(name, options)
           buffer.concat(cache)
         else
           pos = buffer.length
           block.call
           write_fragment(name,buffer[pos..-1], options)
         end
       end
     end
   end
 end

