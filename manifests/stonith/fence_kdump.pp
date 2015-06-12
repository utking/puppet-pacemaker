# generated by agent_generator.rb, manual changes will be lost

define pacemaker::stonith::fence_kdump (
  $nodename = undef,
  $ipport = undef,
  $family = undef,
  $timeout = undef,
  $verbose = undef,
  $usage = undef,

  $interval = "60s",
  $ensure = present,
  $pcmk_host_list = undef,

  $tries = undef,
  $try_sleep = undef,
) {
  $nodename_chunk = $nodename ? {
    undef => "",
    default => "nodename=\"${nodename}\"",
  }
  $ipport_chunk = $ipport ? {
    undef => "",
    default => "ipport=\"${ipport}\"",
  }
  $family_chunk = $family ? {
    undef => "",
    default => "family=\"${family}\"",
  }
  $timeout_chunk = $timeout ? {
    undef => "",
    default => "timeout=\"${timeout}\"",
  }
  $verbose_chunk = $verbose ? {
    undef => "",
    default => "verbose=\"${verbose}\"",
  }
  $usage_chunk = $usage ? {
    undef => "",
    default => "usage=\"${usage}\"",
  }

  $pcmk_host_value_chunk = $pcmk_host_list ? {
    undef => '$(/usr/sbin/crm_node -n)',
    default => "${pcmk_host_list}",
  }

  # $title can be a mac address, remove the colons for pcmk resource name
  $safe_title = regsubst($title, ':', '', 'G')

  if($ensure == absent) {
    exec { "Delete stonith-fence_kdump-${safe_title}":
      command => "/usr/sbin/pcs stonith delete stonith-fence_kdump-${safe_title}",
      onlyif => "/usr/sbin/pcs stonith show stonith-fence_kdump-${safe_title} > /dev/null 2>&1",
      require => Class["pacemaker::corosync"],
    }
  } else {
    package {
      "fence-agents-kdump": ensure => installed,
    } ->
    exec { "Create stonith-fence_kdump-${safe_title}":
      command => "/usr/sbin/pcs stonith create stonith-fence_kdump-${safe_title} fence_kdump pcmk_host_list=\"${pcmk_host_value_chunk}\" ${nodename_chunk} ${ipport_chunk} ${family_chunk} ${timeout_chunk} ${verbose_chunk} ${usage_chunk}  op monitor interval=${interval}",
      unless => "/usr/sbin/pcs stonith show stonith-fence_kdump-${safe_title} > /dev/null 2>&1",
      tries => $tries,
      try_sleep => $try_sleep,
      require => Class["pacemaker::corosync"],
    } ->
    exec { "Add non-local constraint for stonith-fence_kdump-${safe_title}":
      command => "/usr/sbin/pcs constraint location stonith-fence_kdump-${safe_title} avoids ${pcmk_host_value_chunk}",
      tries => $tries,
      try_sleep => $try_sleep,
    }
  }
}
