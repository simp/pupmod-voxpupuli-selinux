# vox_selinux::params
#
# THIS IS A PRIVATE CLASS
# =======================
#
# This class provides default parameters for the selinux class
#
# @api private
#
class vox_selinux::params {
  $refpolicy_makefile = '/usr/share/selinux/devel/Makefile'
  $mode           = undef
  $type           = undef
  $manage_package = true

  $refpolicy_package_name = 'selinux-policy-devel'

  $module_build_root = "${facts['puppet_vardir']}/simp-vox_selinux"

  case $facts['os']['family'] {
    'RedHat': {
      if $facts['os']['name'] == 'Amazon' {
        $package_name = 'policycoreutils'
      } else {
        $package_name = $facts['os']['release']['major'] ? {
          '5'     => 'policycoreutils',
          '6'     => 'policycoreutils-python',
          '7'     => 'policycoreutils-python',
          default => 'policycoreutils-python-utils',
        }
      }
    }
    default: {
      fail("${facts['os']['family']} is not supported")
    }
  }
}
