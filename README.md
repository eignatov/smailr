# Smailr - A Virtual Mail Hosting Management CLI (ALPHA)

Smailr is a small CLI application, which lets you manage the database for a
typical Exim/Dovecot stack.

Configuration files are provided within the contrib directory, so you should be
able to get everything up and running within a couple of minutes.

Please note, Smailr is still in development!

## Installation

Install Smailr

    # gem install smailr

Add a user which will own the mails and is used for the LDA

    # useradd -r -d /srv/mail vmail
    # mkdir /srv/mail/users
    # chown -R vmail:vmail /srv/mail

Install Exim and Dovecot

    # aptitude install exim-daemon-heavy dovecot-imapd dovecot-pop3d

Install the example Exim and Dovecot configration files on your mailserver.

    # smailr setup
    *****************************************************************
    All needed configuration files are in ./smailr-etc for review.
    
    Please install exim4, dovecot and then run the commands below, or
    adjust the file locations according to your environment.
    
    Also make sure to configure a location for the SQLite database
    file in samilr.yml.
    
    Then run 'smailr migrate' to initialize the database.
    *****************************************************************
    
    cp smailr-etc/smailr.yml /etc/smailr.yml
    cp smailr-etc/dovecot.conf /etc/dovecot/
    cp smailr-etc/dovecot-sql.conf /etc/dovecot/
    cp smailr-etc/exim4/

    # invoke-rc.d exim4 restart
    # invoke-rc.d dovecot restart

Run the setup command to initialize the smailr database run:

    # smailr migrate

You should now be ready to just manage your mailserver with the commands listed
below.

## Managing your mailserver

### Domains

Add a local domain

    smailr add example.com

Remove a local domain and all associated mailboxes

    smailr rm example.com

List all domains

    smailr ls

### Mailboxes

Add a new local mailbox. This will interactively ask you for the user password

    smailr add user@example.com

You can as well specify the password on the CLI

    smailr add user@example.com --password secretpass

Remove a local mailbox

    smailr rm user@example.com

List all addresses for a domain

    smailr ls example.com

Update a users passowrd

    smailr passwd user@example.com

### Aliases

Simply add an 'user-alias@example.com' alias to the 'user@example.com' mailbox.

    smailr add user-alias@example.com --alias user@example.com

To remove the alias again, run the rm command.

    smailr rm user-alias@example.com --alias user@example.com

You can as well specify multiple destinations for both commands separated by a comma:

    smailr add user-alias@example.com --alias user@example.com,user1@example.com

### DKIM

You can even manage RSA keys for Domain Key Identified Mail (DKIM).

To create a new key for the selector MX do:

    # smailr add example.com --dkim mx
    public-key MIGJAo<snip>AAE= # returns the public key to use

To remove the key again run:

    smailr rm example.com --dkim mx

**IMPORTANT NOTE**: You will need to setup DNS manually for DKIM to work. The
above example requires the following DNS records:

    $ORIGIN example.com
       _domainkey     IN      TXT     "t=y\; o=~\;"
    mx._domainkey     IN      TXT     "v=DKIM1\; t=y\; k=rsa\; p=MIGJAo<snip>AAE="

Further explenation:

    'mx'   matches up with your dkim_selector specified on you CLI.

    't=y'  tells remote MTAs, that you are still testing DKIM.
           Use t=n once everything works.

    'o=~'  tells everybody, that only some may gets signed.
           Use o=- if you want to sign everything.

The exim configuration assumes a selector of 'mx' by default. You can change that, so
it matches something else. Eg. the current month of the year, in case you want
to generate a new key every month.

Check the remote\_smtp transport configuration in the supplied Exim configuration file
to change that.

### Mutt

Smailr can launch mutt with the required configuration for a specific mailbox
automatically. Open mutt for the specified mailbox:

    smailr mutt user@example.com

## Compatibility

Smailr was developed an tested on Debian/Squeeze and should be easily portable
to any other system.

## BUGS

For bugs or feature requests, please use the GitHub issue tracker.

https://github.com/sts/smailr/issues


## WHO

Stefan Schlesinger / sts@ono.at / @stsonoat / http://sts.ono.at

