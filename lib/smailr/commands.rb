require 'commander'
require 'commander/import'

module Smailr
    module Commands
        #
        # Helpers
        #
        def self.determine_object(string)
            return :domain  if string =~ /^[^@][A-Z0-9.-]+\.[A-Z]{2,6}$/i
            return :address if string =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$/i
        end


        #
        # Commands
        #
        command :add do |c|
            c.syntax = 'emmr add domain | mailbox [options]'
            c.summary = 'Add a domain or addresses to the mail system.'
            c.example 'Add a domain',  'smailr add example.com'
            c.example 'Add a mailbox', 'smailr add user@example.com'
            c.example 'Add an alias',  'smailr add user@example.com -a user-alias@example.com'
            c.option '--alias STRING',    String, 'Specify an alias to create for mailbox.'
            c.option '--password STRING', String, 'The password for a new mailbox. If you omit this option, it prompts for one.'

            c.action do |args, options|
                type = determine_object(args[0])
                case type
                    when :domain  then add_domain(args[0])
                    when :address
                        add_alias(args[0], options) if options.alias
                        add_mailbox(args[0], options) if not options.alias
                    else
                        error "You can either add a domain or an address."
                end
            end
        end

        command :ls do |c|
            c.syntax  = 'emmr ls [domain]'
            c.summary = 'List domains or mailboxes of a specific domain.'
            c.action do |args, options|
                case args[0]
                    when /^[^@][A-Z0-9.-]+\.[A-Z]{2,6}$/i then
                        domain = Model::Domain[:fqdn => args[0]]
                        domain.mailboxes.each do |mbox|
                            puts "#{mbox.localpart}@#{args[0]}"
                        end
                    when nil
                        domains = DB[:domains]
                        domains.all.each do |d|
                            domain = Model::Domain[:fqdn => d[:fqdn]]
                            puts d[:fqdn]
                        end
                    else
                        error "You can either list a domains or an addresses."
                end
            end
        end

        command :rm do |c|
            c.syntax  = 'emmr rm domain | mailbox | alias'
            c.summary = 'Remove a domain, mailbox or alias known to the mail system.'
            c.example 'Remove a domain', 'smailr rm ono.at'
            c.option  '--force', 'Force the operation, do not ask for confirmation.'
            c.action do |args, options|
                type = determine_object(args[0])
                case type
                    when :domain  then rm_domain(args[0], options)
                    when :address
                        rm_mailbox(args[0], options)
                    else
                        error "You can either remove a domain or an address."
                end
            end
        end

        command :setup do |c|
            c.syntax  = 'emmr setup'
            c.summary = 'Initialize the database.'
            c.action do |args, options|
                DB.create_table :domains do
                    primary_key :id
                    column :fqdn, :string, :unique => true
                end

                DB.create_table :mailboxes do
                    primary_key :id
                    foreign_key :domain_id
                    column :localpart, :string, :required => true
                    column :password,  :string, :required => true
                    index [:domain_id, :localpart], :unique => true
                end
            end
        end

    end
end
