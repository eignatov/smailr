module Smailr
    module Alias
        def self.add(source, destinations)
            srclocalpart, srcdomain = source.split('@')

            # We don't want aliases for non-local domains, since the
            # exim router won't accept it.
            if not Model::Domain[:fqdn => srcdomain].exists?
                say_error "You are trying to add an alias for a non-local domain: #{source}"
                exit 1
            end

            destinations.each do |dst|
                dstlocalpart, dstdomain = dst.split('@')

                Model::Alias.find_or_create(:domain       => Model::Domain[:fqdn => srcdomain],
                                            :localpart    => srclocalpart,
                                            :dstdomain    => dstdomain,
                                            :dstlocalpart => dstlocalpart)
            end
        end

        def self.rm(source, destinations)
            srclocalpart, srcdomain = source.split('@')

            destinations.each do |dst|
                dstlocalpart, dstdomain = dst.split('@')

                Model::Alias.filter(:domain       => Model::Domain[:fqdn => srcdomain],
                                    :localpart    => srclocalpart,
                                    :dstdomain    => dstdomain,
                                    :dstlocalpart => dstlocalpart).delete
            end
        end
    end
end
