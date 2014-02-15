use JSON;
use strict;

our $json = JSON->new();


package AWE::Server;

sub new {
	my $class = shift;
	my $url = shift;
	my $self = {url => $url};
	return bless $self, $class;
}

sub clients {
	my $self = shift;
	my @clients = ();

	my $url = "$self->{url}/clients";
	my $json_text = `curl -s -L \'$url\'`;
	my $perl_scalar = $json->decode( $json_text );
	foreach (@ {$perl_scalar->{data}}) {
		push @clients, AWE::Client->new($json->encode($_));
	}
	return @clients;
}

sub jobs {
	my $self = shift;
	my $job_properties = shift;
	my @jobs = ();
	
	my $url = "$self->{url}/jobs";
	foreach my $key (keys %$job_properties) {
		$url .= '?query&' . $key . '=' . $job_properties->{$key} ;
	}

        my $json_text = `curl -s -L \'$url\'`;
        my $perl_scalar = $json->decode( $json_text );

        foreach (@ {$perl_scalar->{data}}) {
                push @jobs, AWE::Job->new($json->encode($_));
        }
        return @jobs;

	sub queue {
		my $self = shift;
		my $url = "$self->{url}/queue";
		my $json_text = `curl -s -L \'$url\'`;
		return AWE::Queue->new($json_text);
	}
}

package AWE::Client;
use Native;

sub launch {
        my $self = shift;
	my $type = shift;

	if ($type =~ /native/i) {
		Native::launch();	
	}
}

sub new {
	my $class = shift;
	my $json_text = shift;
	my $perl_scalar = $json->decode($json_text);
	my $self = {json_text => $json_text, perl_scalar => $perl_scalar};
	return bless $self, $class;
}

sub host {
	my $self = shift;
	$self->{perl_scalar}->{host};
}
	
sub status {
	my $self = shift;
	my $current_work = $self->{perl_scalar}->{current_work};
	my $status = $self->{perl_scalar}->{Status};
	my $rv = "unknown";

	if($status =~ /active/i and %$current_work == 0) {
		$rv = "idle";
	}
	elsif ($status =~ /activei/i and %$current_work > 0) {
		$rv = "busy";
	}
	elsif ($status =~ /suspend/i) {
		$rv = "suspended";
	}
	return $rv;
}

sub current_work {
	my $self = shift;
	$self->{perl_scalar}->{current_work};
}
	

package AWE::Job;

sub new {
	my $class = shift;
	my $json_text = shift;
	my $perl_scalar = $json->decode($json_text);
	my $self = {json_text => $json_text, perl_scalar => $perl_scalar};
	return bless $self, $class;
}

sub state_tasks {
	my $self = shift;
	my $state = shift;
	my (@tasks, $i);

	for ($i = 0; $i < @{$self->{perl_scalar}->{tasks}}; $i++) {
		if ($self->{perl_scalar}->{tasks}->[$i]->{state} =~ /^$state$/i ) {
			push @tasks, $self->{perl_scalar}->{tasks}->[$i];
		}
	}
	return @tasks;
}

sub queued_tasks {
        my $self = shift;
        return $self->state_tasks("queued");
}

sub pending_tasks {
	my $self = shift;
	return $self->state_tasks("pending");
}


package AWE::Queue;

sub new {
	my $class = shift;
	my $json_text = shift;
	my $perl_scalar = $json->decode($json_text);
	my $self = {perl_scalar => $perl_scalar, json_text => $json_text};
	bless $self, $class;
}

sub data {
	my $self = shift;
	return $self->{perl_scalar}->{data};
}


1;
