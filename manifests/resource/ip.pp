class pacemaker::resource::ip($ip_address, $cidr_netmask=32, $group=nil, $interval="30s", $stickiness=0, $ensure=present) 
  inherits pacemaker::corosync {

    $resource_id = "ip-${ip_address}"

    if($ensure == absent) {
        exec { "Removing ip ${ip_address}":
        command => "/usr/sbin/pcs resource delete ${resource_id}",
        onlyif  => "/usr/sbin/pcs resource show ${resource_id} > /dev/null 2>&1",
        require => Exec["Start Cluster $cluster_name"],
        }
    } else {
        exec { "Creating ip ${ip_address}":
        command => "/usr/sbin/pcs resource create ${resource_id} IPaddr2 ip=${ip_address} cidr_netmask=${cidr_netmask} op monitor interval=${interval}",
        unless  => "/usr/sbin/pcs resource show ${resource_id} > /dev/null 2>&1",
        require => [Exec["Start Cluster $cluster_name"],Package["pcs"]]
        }
        pacemaker::resource::group { "${resource_id}-${group}":
            resource_id => $resource_id,
            resource_group => $group,
            require => Exec["Creating ip ${ip_address}"],
        }
    }
}
