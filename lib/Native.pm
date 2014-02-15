package Native;

use strict;
use lib qw(.);
use Config::Simple;
use Log::Log4perl qw(:easy);
use AWE;
Log::Log4perl->easy_init($DEBUG);


# configs
my ($key_file, $run_awe, @client_addrs, $server_addr,
    $server_port, $min_clients, $cfg, $url);
if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) {
    INFO "reading config from $ENV{KB_DEPLOYMENT_CONFIG}";
    $cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG}) or
        die "could not construct new Config::Simple object";
    @client_addrs = $cfg->param("awe_monitor.client-addrs");
    $server_addr = $cfg->param("awe_monitor.server-addr");
    $server_port = $cfg->param("awe_monitor.server-port");
    $min_clients = $cfg->param("awe_monitor.min-clients");
    $run_awe     = $cfg->param("awe_monitor.remote-script");
    $key_file    = $cfg->param("awe_monitor.key-file");
    $url = "http://$server_addr:$server_port";
}
elsif (-e "./deploy.cfg") {
    INFO "reading config from ./deploy.cfg";
    $cfg = new Config::Simple("./deploy.cfg") or
        die "could not construct new Config::Simple object";
    @client_addrs = $cfg->param("awe_monitor.client-addrs");
    $server_addr = $cfg->param("awe_monitor.server-addr");
    $server_port = $cfg->param("awe_monitor.server-port");
    $min_clients = $cfg->param("awe_monitor.min-clients");
    $run_awe     = $cfg->param("awe_monitor.remote-script");
    $key_file    = $cfg->param("awe_monitor.key-file");
    $url = "http://$server_addr:$server_port";
}
else {
    die "can not find configs";
}
INFO "getting info from server at ", $url;




sub launch {
	my $server = AWE::Server->new($url);
	my @clients = $server->clients();


	my %active_hosts = ();
	foreach my $client (@clients) {
		my $ip = $client->host();
		$active_hosts{$ip}++;
	}


	# just some logging stuff here
	foreach my $ip (keys %active_hosts) {
		INFO "$active_hosts{$ip} client(s) registered on ", $ip;
	}
	INFO "hosts allowed on ", join(" ", sort (@client_addrs));
	

	# subtract keys %active_hosts from @client_addrs and see whats left
	my %missing;
	foreach (@client_addrs) { $missing{$_}++ }
	foreach (keys %active_hosts) { $missing{$_} = $missing{$_} - $active_hosts{$_} };
	foreach (keys %missing) { INFO "$missing{$_} client(s) missing on $_"; }

	# select host to start new client on
	my $target; my $val = 0;
	foreach (keys %missing) { $target = $_ if $missing{$_} > $val }

	INFO "starting a client on $target";
	INFO "ssh -i $key_file $target $run_awe";
	#system ("ssh", "-i", "$key-file", "$target", "$run_awe");	

}
