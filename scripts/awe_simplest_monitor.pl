use Config::Simple;
use Log::Log4perl qw(:easy);
use lib qw(./lib);
use AWE;
use strict;
my (@client_addrs, $server_addr, $server_port, $min_clients, $cfg);

Log::Log4perl->easy_init($DEBUG);

# make these configs
my $url = "http://140.221.85.56:7080";
my $min_clients = 10;

if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) {
    INFO "reading config from $ENV{KB_DEPLOYMENT_CONFIG}";
    $cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG}) or
        die "could not construct new Config::Simple object";

    @client_addrs = $cfg->param("awe_monitor.client-addrs");
    $server_addr = $cfg->param("awe_monitor.server-addr");
    $server_port = $cfg->param("awe_monitor.server-port");
    $min_clients = $cfg->param("awe_monitor.min-clients");
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
    $url = "http://$server_addr:$server_port";
}
else {
    die "can not find config file";
}
INFO "getting info from server at ", $url;

my ($total_clients, $idle_clients, $busy_clients, $suspended_clients) = (0,0,0,0);

my $server = AWE::Server->new($url);
my @clients = $server->clients();

foreach my $client (@clients) {
	$idle_clients++ if $client->status() eq "idle";
	$busy_clients++ if $client->status() eq "busy";
	$suspended_clients++ if $client->status() eq "suspended";
}

$total_clients = @clients;
if ($total_clients != $idle_clients + $suspended_clients + $busy_clients) {
	die "total_clients ($total_clients) != idle_clients ($idle_clients) 
	+ suspended_clients ($suspended_clients) + busy_clients ($busy_clients)";
}

if ($idle_clients + $busy_clients < $min_clients) {
	INFO "idle clients ($idle_clients) + busy clients ($busy_clients) ",
		"< min_clients ($min_clients)\n";
	# AWE::Client->launch('nova');
	# AWE::Client->launch('sge');
	AWE::Client->launch('native');
	# AWE::Client->launch('condor');
}
