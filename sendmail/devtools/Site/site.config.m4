dnl ## devtools/Site/site.config.m4 / 20150426
dnl ## Marianne Spiller <github@spiller.me>
dnl ## Building sendmail-8.15.2 from source using ./Build -c

dnl ### Changes to disable the default NIS support
APPENDDEF(`confENVDEF', `-UNIS')

dnl ### Changes for PH_MAP support.
dnl ###		APPENDDEF(`confMAPDEF',`-DPH_MAP')
dnl ###		APPENDDEF(`confLIBS', `-lphclient')
dnl ###		APPENDDEF(`confINCDIRS', `-I/opt/nph/include')
dnl ###		APPENDDEF(`confLIBDIRS', `-L/opt/nph/lib')

APPENDDEF(`confENVDEF',`-DSTARTTLS')
APPENDDEF(`confLIBS', `-lssl -lcrypto')
dnl ## 		APPENDDEF(`confLIBDIRS', `-L/usr/local/ssl/lib -R/usr/local/ssl/lib')
APPENDDEF(`confLIBDIRS', `-L/usr/local/ssl/lib')
APPENDDEF(`confINCDIRS', `-I/usr/local/ssl/include')
APPENDDEF(`confMAPDEF', `-DLDAPMAP')
APPENDDEF(`confLIBS', `-lresolv -lldap -llber')
APPENDDEF(`confENVDEF', `-DSASL=2')
APPENDDEF(`conf_sendmail_LIBS', `-lsasl2')
APPENDDEF(`confINCDIRS', `-I/usr/include/sasl')
APPENDDEF(`confMAPDEF',`-DNEWDB')
APPENDDEF(`confLIBS', `-ldb')
