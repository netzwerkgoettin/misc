dnl ## /etc/mail/sendmail.mc / 20160426
dnl ## Marianne Spiller <github@spiller.me>
dnl ## Used until sendmail-8.14.4 / m4 sendmail.mc > sendmail.cf

divert(-1)dnl
divert(0)dnl
define(`_USE_ETC_MAIL_')dnl
include(`/usr/share/sendmail/cf/m4/cf.m4')dnl
VERSIONID(`@(#)mycf.mc (spiller.me) 2016/04/20')dnl
OSTYPE(`debian')dnl
DOMAIN(`debian-mta')dnl
dnl # Items controlled by /etc/mail/sendmail.conf - DO NOT TOUCH HERE 
undefine(`confHOST_STATUS_DIRECTORY')dnl		#DAEMON_HOSTSTATS 
dnl # Items controlled by /etc/mail/sendmail.conf - DO NOT TOUCH HERE
undefine(`confHOST_STATUS_DIRECTORY')dnl
GENERICS_DOMAIN(spiller.me)dnl
MASQUERADE_AS(`spiller.me')dnl
dnl ## 		FEATURE(`accept_unresolvable_domains')dnl
dnl ## 		FEATURE(`accept_unqualified_senders')
FEATURE(`always_add_domain')dnl
dnl ### do STARTTLS
define(`confCACERT_PATH', `/etc/ssl/my')dnl
define(`confCACERT', `/etc/ssl/CAcert/CAcert.pem')dnl
define(`confSERVER_CERT', `/etc/ssl/CAcert/spiller_server.pem')dnl
define(`confSERVER_KEY', `/etc/ssl/CAcert/sendmail.pem')dnl
define(`confCLIENT_CERT', `/etc/ssl/CAcert/spiller_server.pem')dnl
define(`confCLIENT_KEY', `/etc/ssl/CAcert/sendmail.pem')dnl
DAEMON_OPTIONS(`Family=inet,  Name=MTA-v4, Port=smtp')dnl
DAEMON_OPTIONS(`Family=inet,  Name=MSP-v4, Port=465')dnl
define(`confAUTH_MECHANISMS', `LOGIN PLAIN')dnl
TRUST_AUTH_MECH(`LOGIN PLAIN')dnl
FEATURE(`no_default_msa')dnl
define(`confPRIVACY_FLAGS',dnl
`needmailhelo,noexpn,novrfy,needexpnhelo,needvrfyhelo,restrictqrun,restrictexpand,nobodyreturn,authwarnings')dnl
dnl ## define(`confFORWARD_PATH',`$z/.forward')dnl
define(`confCONNECTION_RATE_THROTTLE', `15')dnl
define(`confCONNECTION_RATE_WINDOW_SIZE',`10m')dnl
dnl ## FEATURE(`use_ct_file')dnl
dnl ## define(`confCT_FILE',`/etc/mail/trusted-users')
FEATURE(`use_cw_file')dnl
define(`confCW_FILE',`/etc/mail/sendmail.cw')dnl
FEATURE(genericstable)dnl
dnl ## LDAP SETTINGS
define(`confLDAP_CLUSTER',`spiller.me')dnl
FEATURE(`virtusertable',`LDAP')dnl
define(`ALIAS_FILE',`ldap:')dnl
define(`confLDAP_DEFAULT_SPEC',`-h 127.0.0.1 -b dc=sysadmama,dc=de')dnl
define(`confLDAP_DEFAULT_SPEC', `-w 3')dnl
FEATURE(`access_db',`hash -T<TMPF> /etc/mail/access.db')dnl
FEATURE(`allmasquerade')dnl
FEATURE(`masquerade_envelope')dnl
FEATURE(`greet_pause', `1000')dnl 1 seconds
dnl ## FEATURE(`delay_checks', `friend', `n')dnl
define(`confBAD_RCPT_THROTTLE',`3')dnl
dnl ## FEATURE(`conncontrol', `nodelay', `terminate')dnl
dnl ## FEATURE(`ratecontrol', `nodelay', `terminate')dnl
define(`confSMTP_LOGIN_MSG',`WELCOME ON SPILLER.ME MAILSTORE; $b')dnl
define(`confREJECT_MSG',`YOU ARE NOT WELCOME ON THIS SYSTEM!!!')dnl
define(`confRELAY_MSG',`SPILLER.ME IS NOT A PUBLIC RELAY!!!')dnl
dnl ## FEATURE(`dnsbl',`zen.spamhaus.org',`"554 Rejected " $&{client_addr} " found in zen.spamhaus.org"',`t')dnl
dnl ## DKIM settings
INPUT_MAIL_FILTER(`opendkim', `S=inet:8891@127.0.0.1')
INPUT_MAIL_FILTER(`opendmarc', `S=inet:8893@127.0.0.1')
dnl ## greylisting -- milter-greylist
INPUT_MAIL_FILTER(`greylist',`S=local:/var/run/milter-greylist/milter-greylist.sock')dnl
define(`confMILTER_MACROS_CONNECT',`j,{if_addr}')dnl
define(`confMILTER_MACROS_HELO',`{verify},{cert_subject}')dnl
define(`confMILTER_MACOS_ENVFROM',`i,{auth_authen}')dnl
dnl ## 
dnl ## spam filtering -- spamassassin
dnl ## INPUT_MAIL_FILTER(`spamassassin',`S=local:/var/run/spamass/spamass.sock,F=T,T=C:15m;S:4m;R:4m;E:10m')dnl
dnl ## 
dnl ## mail scanning -- clamav
dnl ## INPUT_MAIL_FILTER(`clmilter',`S=local:/var/run/clamav/clamav-milter.ctl,F=,T=S:4m;R:4m')dnl
dnl ## insert them
dnl ## define(`confINPUT_MAIL_FILTERS',`greylist,spamassassin,clmilter')dnl
dnl ## define(`confINPUT_MAIL_FILTERS',`greylist,spamassassin')dnl
dnl ## define(`confINPUT_MAIL_FILTERS',`greylist')dnl
LOCAL_CONFIG
O ServerSSLOptions=+SSL_OP_NO_SSLv2 +SSL_OP_NO_SSLv3 +SSL_OP_CIPHER_SERVER_PREFERENCE
O ClientSSLOptions=+SSL_OP_NO_SSLv2 +SSL_OP_NO_SSLv3
O CipherList=HIGH:MEDIUM:!aNULL:!eNULL@STRENGTH
MAILER_DEFINITIONS
define(`LOCAL_MAILER_PATH', `/usr/bin/dspam')
define(`LOCAL_MAILER_ARGS', `dspam "--deliver=innocent" --user $u -d %u') 
dnl ## local mail delivery -- cyrusv2
dnl ## define(`confLOCAL_MAILER',`cyrusv2')dnl
dnl ## define(`CYRUSV2_MAILER_ARGS', `FILE /var/run/cyrus/socket/lmtp')dnl
dnl ## FEATURE(`ckuser_cyrus')dnl
MAILER(`local')dnl
dnl ## MAILER(`cyrusv2')dnl
MAILER(`smtp')dnl
dnl ## EOF
