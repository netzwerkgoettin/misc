;; /etc/nagvis/nagvis.ini.php / 20160104
;; Marianne Spiller <github@spiller.me>
;; nagvis-1.7.10 

; <?php return 1; ?>
[global]
;audit_log="1"
;dateformat="Y-m-d H:i:s"
file_group="www-data"
file_mode=660
language="de_DE"
[paths]
base="/usr/share/nagvis/"
htmlbase="/nagvis"
htmlcgi="/icingaweb2/monitoring"
[defaults]
backend="live_1"
backgroundcolor="#ffffff"
contextmenu=1
urltarget="_parent"
hosturl="[htmlcgi]/host/show?host=[host_name]"
hostgroupurl="[htmlcgi]/list/hosts?hostgroup=[hostgroup_name]"
serviceurl="[htmlcgi]/service/show?host=[host_name]&service=[service_description]"
servicegroupurl="[htmlcgi]/list/services?servicegroup=[servicegroup_name]"
;mapurl="[htmlbase]/index.php?mod=Map&act=view&show=[map_name]"
;view_template="default"
[index]
[automap]
defaultparams="&childLayers=2"
defaultroot="$YOUR_HOSTNAME"
graphvizpath="/usr/bin/"
[wui]
[worker]
[backend_live_1]
backendtype="mklivestatus"
socket="unix:/var/run/icinga2/cmd/livestatus"
htmlcgi="/icingaweb2/monitoring"
[states]
