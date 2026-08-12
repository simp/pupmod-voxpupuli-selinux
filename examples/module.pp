# Class:
#
# Description
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

vox_selinux::module { 'apache':
  ensure    => 'present',
  source_te => 'puppet:///modules/vox_selinux/apache.te',
  builder   => 'simple',
}
