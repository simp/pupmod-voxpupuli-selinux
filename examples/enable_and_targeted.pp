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

class { 'vox_selinux':
  mode => 'enforcing',
  type => 'targeted',
}
