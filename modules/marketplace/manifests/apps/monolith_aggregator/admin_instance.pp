# define admin instance for monolith aggregator
define marketplace::apps::monolith_aggregator::admin_instance(
    $mkt_endpoint,
    $db_uri,
    $es_url,
    $ga_auth,
    $mkt_user,
    $mkt_pass,
    $cluster,
    $domain,
    $env,
    $ssh_key,
    $cron_user = 'mkt_prod_monolith',
    $pyrepo = 'https://pyrepo.addons.mozilla.org/',
    $gitrepo = 'https://github.com/mozilla/monolith-aggregator.git'
) {
    $project_dir = $name
    git::clone {
        "${project_dir}/monolith-aggregator":
            repo => $gitrepo;

    }
    cron {
        "aggr-${project_dir}":
            environment => 'MAILTO=amo-developers@mozilla.org',
            command     => "cd ${project_dir}/monolith-aggregator; ../venv/bin/monolith-extract aggregator.ini --date yesterday",
            user        => $cron_user,
            hour        => 1,
            minute      => 15;
    }

    file {
        "${project_dir}/monolith-aggregator/aggregator.ini":
            require => Git::Clone["${project_dir}/monolith-aggregator"],
            content => template('marketplace/apps/monolith_aggregator/admin/aggregator.ini');

        "${project_dir}/monolith-aggregator/auth.json":
            require => Git::Clone["${project_dir}/monolith-aggregator"],
            content => $ga_auth;

        "${project_dir}/monolith-aggregator/monolith.password.ini":
            require => Git::Clone["${project_dir}/monolith-aggregator"],
            content => template('marketplace/apps/monolith_aggregator/admin/monolith.password.ini');
    }

    file {
        "${project_dir}/monolith-aggregator/deploysettings.py":
            require => Git::Clone["${project_dir}/monolith-aggregator"],
            content => template('marketplace/apps/monolith/deploysettings.py');
    }

}
