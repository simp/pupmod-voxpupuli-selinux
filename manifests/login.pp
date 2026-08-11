# This method will manage a selinux login, and will
# persist it across reboots.
#
# @summary Manage a SELinux login
#
# @example Add a map for the localuser to staff_u
#   vox_selinux::login { 'localuser_staff_u':
#     ensure   => 'present',
#     selinux_login_name  => 'localuser',
#     selinux_user => 'staff_u',
#   }
#
# @param ensure Set to present to add or absent to remove a selinux login.
# @param selinux_login_name A Linux user or group
# @param selinux_user The selinux user to map to
# @param selinux_mlsrange The MLS range to set. If undef, the MLS range of the SELinux user will be used.
#
define vox_selinux::login (
  String[1]                    $selinux_login_name,
  String[1]                    $selinux_user,
  Optional[String[1]]          $selinux_mlsrange = undef,
  Enum['present', 'absent'] $ensure = 'present',
) {
  include vox_selinux

  if $ensure == 'present' {
    Anchor['vox_selinux::module post']
    -> Vox_selinux::Login[$title]
    -> Anchor['vox_selinux::end']
  } elsif $ensure == 'absent' {
    Class['vox_selinux::config']
    -> Vox_selinux::Login[$title]
    -> Anchor['vox_selinux::module pre']
  } else {
    fail('Unexpected $ensure value')
  }

  # Do nothing unless SELinux is enabled
  if $facts['os']['selinux']['enabled'] {
    selinux_login { $selinux_login_name:
      ensure             => $ensure,
      selinux_login_name => $selinux_login_name,
      selinux_user       => $selinux_user,
      selinux_mlsrange   => $selinux_mlsrange,
    }
  }
}
