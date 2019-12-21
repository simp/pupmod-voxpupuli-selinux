# Manage SELinux on RHEL based systems.
#
# @example Enable enforcing mode with targeted policy
#   class { 'selinux':
#     mode => 'enforcing',
#     type => 'targeted',
#   }
#
# @param package_name sets the name(s) for the selinux tools package
#   Default value: OS dependent (see data/).
# @param manage_auditd_package install auditd to log SELinux violations,
#   for OSes that do not have auditd installed by default.
#   Default value: OS dependent (see data/)
# @param refpolicy_package_name sets the name for the refpolicy development package, required for the
#   refpolicy module builder
#   Default value: OS dependent (see data/)
# @param mode sets the operating state for SELinux.
# @param type sets the selinux type
# @param refpolicy_makefile the path to the system's SELinux makefile for the refpolicy framework
# @param manage_package manage the package for selinux tools and refpolicy
# @param auditd_package_name used when `manage_auditd_package` is true
# @param module_build_root directory where modules are built. Defaults to `$vardir/puppet-selinux`
# @param default_builder which builder to use by default with vox_selinux::module
# @param boolean Hash of vox_selinux::boolean resource parameters
# @param fcontext Hash of vox_selinux::fcontext resource parameters
# @param module Hash of vox_selinux::module resource parameters
# @param permissive Hash of vox_selinux::module resource parameters
# @param port Hash of vox_selinux::port resource parameters
# @param exec_restorecon Hash of vox_selinux::exec_restorecon resource parameters
#
class vox_selinux (
  Variant[String[1], Array[String[1]]] $package_name,
  Boolean $manage_auditd_package,
  String $refpolicy_package_name,
  Optional[Enum['enforcing', 'permissive', 'disabled']] $mode = undef,
  Optional[Enum['targeted', 'minimum', 'mls']] $type          = undef,
  Stdlib::Absolutepath $refpolicy_makefile                    = '/usr/share/selinux/devel/Makefile',
  Boolean $manage_package                                     = true,
  String[1] $auditd_package_name                              = 'auditd',
  Stdlib::Absolutepath $module_build_root                     = "${facts['puppet_vardir']}/puppet-selinux",
  Enum['refpolicy', 'simple'] $default_builder                = 'simple',

  Optional[Hash] $boolean         = undef,
  Optional[Hash] $fcontext        = undef,
  Optional[Hash] $module          = undef,
  Optional[Hash] $permissive      = undef,
  Optional[Hash] $port            = undef,
  Optional[Hash] $exec_restorecon = undef,
) {

  class { 'vox_selinux::package':
    manage_package        => $manage_package,
    package_names         => Array.new($package_name, true),
    manage_auditd_package => $manage_auditd_package,
    auditd_package_name   => $auditd_package_name,
  }

  class { 'vox_selinux::config':
    mode => $mode,
    type => $type,
  }

  if $boolean {
    create_resources ( 'vox_selinux::boolean', $boolean )
  }
  if $fcontext {
    create_resources ( 'vox_selinux::fcontext', $fcontext )
  }
  if $module {
    create_resources ( 'vox_selinux::module', $module )
  }
  if $permissive {
    create_resources ( 'vox_selinux::permissive', $permissive )
  }
  if $port {
    create_resources ( 'vox_selinux::port', $port )
  }
  if $exec_restorecon {
    create_resources ( 'vox_selinux::exec_restorecon', $exec_restorecon )
  }

  # Ordering
  anchor { 'vox_selinux::start': }
  -> Class['vox_selinux::package']
  -> Class['vox_selinux::config']
  -> anchor { 'vox_selinux::module pre': }
  -> anchor { 'vox_selinux::module post': }
  -> anchor { 'vox_selinux::end': }
}
