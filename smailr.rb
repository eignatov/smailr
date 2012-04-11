#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'thor/group'
require 'digest/md5'

DB = Sequel.sqlite :database => 'smailr.db'

class Domain < Sequel::Model
    one_to_many :mailboxes
end

class Mailbox < Sequel::Model
    many_to_one :domain

    def password=(clear)
        self[:password] = Digest::MD5.hexdigest(clear)
    end
end

class Alias < Sequel::Model
end


##
## THOR
##

class DomainCLI < Thor
    namespace :domain

    desc 'list', 'List the current domains'
    def list()
        domains = DB[:domains]
        domains.all.each do |d| 
            puts d[:fqdn]
        end
    end

    desc 'add', 'Add a new domain.'
    def add(fqdn)
        domain = Domain.create(:fqdn => fqdn)
    end

    desc 'rm', 'Remove a domain.'
    def rm(fqdn)
        domain = Domain[:fqdn => fqdn]
        domain.destroy
    end

    ## Update
    #d = Domain[:fqdn => 'ono.at']
    #d.update(:fqdn => 'ono2.at')
end

class MboxCLI < Thor
    namespace :mbox

    desc 'list', 'List mailboxes of a specific domain'
    def list(fqdn)
        domain = Domain[:fqdn => fqdn]
        domain.mailboxes.each do |mbox|
            puts "#{mbox.localpart}@#{fqdn}"
        end
    end

    desc 'add', 'Add a mailbox to a domain'
    def add(address, password)
        localpart, fqdn = address.split('@')

        domain = Domain[:fqdn => fqdn]
        mbox   = Mailbox.create(:localpart => localpart, :password => password)
        domain.add_mailbox(mbox)
    end

    desc 'rm', 'Remove a mailbox from a domain.'
    def rm(address)
        localpart, fqdn = address.split('@')

        domain = Domain[:fqdn => fqdn]
        domain.remove_mailbox(:localpart => localpart)
    end
end

class SmailrCLI < Thor
    register(DomainCLI, 'domain', 'domain <command>', 'Edit domain properties')
    register(MboxCLI,   'mbox',   'mbox <domain> <command>', 'Edit mailbox properties')

    desc 'setup', 'Setup a sqlite database'
    def setup
        DB.create_table :domains do 
            primary_key :id
            column :fqdn, :string, :unique => true
        end

        DB.create_table :mailboxes do 
            primary_key :id
            foreign_key :domain_id
            column :localpart, :string, :required => true
            column :password,  :string, :required => true
        end


        DB.create_table :aliases do
            primary_key :id
            column :domain, :string, :required => true
            column :localpart, :string, :required => true
            column :forward, :string, :requred => true
        end
    end
end

SmailrCLI.start