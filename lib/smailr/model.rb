module Smailr
    module Model
        class Domain < Sequel::Model
            one_to_many :mailboxes
        end

        class Mailbox < Sequel::Model
            many_to_one :domain
            one_to_many :aliases

            def password=(clear)
                self[:password] = Digest::SHA1.hexdigest(clear)
            end

            def self.domain(fqdn)
                return Domain[:fqdn => fqdn]
            end

            def self.for_address(address)
                localpart, fqdn = address.split('@')

                return self[:localpart => localpart,
                            :domain    => domain(fqdn)]
            end
        end

        class Alias < Sequel::Model
            many_to_one :mailbox

            def self.domain(fqdn)
                return Domain[:fqdn => fqdn]
            end

            def self.mbox_for_address(address)
                localpart, fqdn = address.split('@')

                return Mailbox[:localpart => localpart,
                               :domain    => domain(fqdn)]
            end
        end
    end
end
