package WebService::FindMyiPhone;

use strict;
use warnings;

use 5.010_001;
our $VERSION = '0.01';

use Carp;
use List::Util 'first';
use Mojolicious;
use WebService::FindMyiPhone::Device;

use Data::Dumper;    # TODO: remove

sub new {
    my ( $class, %args ) = @_;

    for my $required_arg (qw(username password)) {
        croak "Required argument $required_arg not specifided."
            unless $args{$required_arg};
    }

    $ENV{MOJO_USERAGENT_DEBUG} = 1 if $args{debug};

    my $self = {
        username => $args{username},
        password => $args{password},
        debug    => $args{debug},
        devices  => [],
        hostname => 'fmipmobile.icloud.com',
        ua       => Mojo::UserAgent->new(),
    };
    bless $self, $class;

    $self->{ua}->name('Find iPhone/1.4 MeKit (iPad: iPhone OS/4.2.1)');
    $self->_get_shard();
    $self->update_devices();

    return $self;
}

sub _get_shard {
    my ($self) = @_;
    my $data
        = '{"clientContext":{"appName":"FindMyiPhone","appVersion":"1.4","buildVersion":"145","deviceUDID":"0000000000000000000000000000000000000000","inactiveTime":2147483647,"osVersion":"4.2.1","personID":0,"productType":"iPad1,1"}}';
    my $response = $self->_post( '/initClient', $data );
    $self->{hostname} = $response->headers->header('X-Apple-MMe-Host');
    warn "User is on shard $self->{hostname}" if $self->{debug};
}

sub update_devices {
    my ($self) = @_;
    my $data
        = '{"clientContext":{"appName":"FindMyiPhone","appVersion":"1.4","buildVersion":"145","deviceUDID":"0000000000000000000000000000000000000000","inactiveTime":2147483647,"osVersion":"4.2.1","personID":0,"productType":"iPad1,1"}}';

    if ( @{ $self->{devices} } ) {
        my $new_device_data
            = $self->_post( '/initClient', $data )->json->{content};
        for my $device ( @{$new_device_data} ) {
            my $device_object = $self->get_device_by( id => $device->{id} );
            $device_object->_update_self($device);
        }
    }
    else {
        $self->{devices}
            = $self->_post( '/initClient', $data )->json->{content};
        $_ = WebService::FindMyiPhone::Device->new( $self, $_ )
            for @{ $self->{devices} };
    }
    return $self->{devices};
}

sub get_device_field {
    my ( $self, $field ) = @_;
    return [ map { $_->{$field} } @{ $self->{devices} } ] unless ref $field;
    return [ map { [ @$_{@$field} ] } @{ $self->{devices} } ];
}

sub get_device_by {
    my ( $self, $field, $query ) = @_;
    return first { $_->{$field} eq $query } @{ $self->{devices} };
}

sub _post {
    my ( $self, $path, $data ) = @_;

    state $headers = {
        'Content-Type'          => ' application/json; charset=utf-8',
        'X-Apple-Find-Api-Ver'  => ' 2.0',
        'X-Apple-Authscheme'    => ' UserIdGuest',
        'X-Apple-Realm-Support' => ' 1.0',
        'X-Client-Name'         => ' iPad',
        'X-Client-UUID'         => ' 0cf3dc501ff812adb0b202baed4f37274b210853',
        'Accept-Language'       => ' en-us',
    };

    my $url = Mojo::URL->new( join '', 'https://', $self->{hostname},
        '/fmipservice/device/', $self->{username}, $path );
    warn "Posting to $url\n" if $self->{debug};
    $url->userinfo( $self->{username} . ':' . $self->{password} );

    my $transaction = $self->{ua}
        ->post( $url, $headers, ref $data ? ( json => $data ) : $data );

    if ( my $response = $transaction->success ) {
        return $response;
    }
    else {
        my ( $err, $code ) = $transaction->error;
        confess $code ? "$code response: $err" : "Connection error: $err";
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

WebService::FindMyiPhone - Blah blah blah

=head1 SYNOPSIS

  use WebService::FindMyiPhone;
  my $fmiphone = WebService::FindMyiPhone->new(
      username => 'email@address',
      password => 'YaakovLOVE',
  );
  my $iphone = $fmiphone->get_device_by( name => 'mmm cake');
  my $location = $iphone->location();
  $iphone->send_message(1, 'Where did I leave you?');

=head1 DESCRIPTION

WebService::FindMyiPhone is

=head1 AUTHOR

Mike Greb E<lt>michael@thegrebs.comE<gt>

=head1 COPYRIGHT

Copyright 2013- Mike Greb

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
