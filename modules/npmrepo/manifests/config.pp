# npm repo config
class npmrepo::config(
  $port = '10000',
  $cache_dir = '/data/npmrepo',
  $cache_mem = '128',
  $config_file = '/etc/npm_lazy_mirror.json'
){

  file { $config_file:
    ensure  => 'present',
    content => template('npmrepo/config.js');
  }
}