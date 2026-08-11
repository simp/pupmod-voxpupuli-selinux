# Manages additional packages required to support some of the functions.
#
# @param manage_package See main class
# @param package_name See main class
#
# @api private
#
class vox_selinux::refpolicy_package (
  Boolean $manage_package = $vox_selinux::manage_package,
  String[1] $package_name = $vox_selinux::refpolicy_package_name,
) inherits vox_selinux {
  assert_private()
  if $manage_package {
    stdlib::ensure_packages ($package_name)
  }
}
