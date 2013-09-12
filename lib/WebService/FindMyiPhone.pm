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

my $post_data
    = '{"clientContext":{"appName":"FindMyiPhone","appVersion":"1.4","buildVersion":"145","deviceUDID":"0000000000000000000000000000000000000000","inactiveTime":2147483647,"osVersion":"4.2.1","personID":0,"productType":"iPad1,1"}}';

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
    my $response = $self->_post( '/initClient', $post_data );
    $self->{hostname} = $response->headers->header('X-Apple-MMe-Host');
    warn "User is on shard $self->{hostname}" if $self->{debug};
}

sub update_devices {
    my ($self) = @_;
    if ( @{ $self->{devices} } ) {
        my $new_device_data
            = $self->_post( '/initClient', $post_data )->json->{content};
        for my $device ( @{$new_device_data} ) {
            my $device_object = $self->get_device_by( id => $device->{id} );
            $device_object->_update_self($device);
        }
    }
    else {
        $self->{devices}
            = $self->_post( '/initClient', $post_data )->json->{content};
        $_ = WebService::FindMyiPhone::Device->new( $self, $_ )
            for @{ $self->{devices} };
    }
    return $self->{devices};
}

sub get_devices_field {
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
        'X-Client-UUID'         => ' 0000000000000000000000000000000000000000',
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

WebService::FindMyiPhone - Perl interface to Apple's Find My iPhone service

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

WebService::FindMyiPhone is a Perl interface to Apple's Find My iPhone service.

=head1 METHODS

=head2 new

=head2 update_devices

=head2 get_devices_field( $field )

Retrieves an array ref of specified field's value for each device.

    my $names = $fmiphone->get_devices_field('name');
    # $names = [ "mmm cake", "soryu2", "mikegrb's ipad" ];

=head2 get_devices_field([ @fields ])

Retrieves an array ref array refs of specified fields' value for each device.

    my $info = $fmiphone->get_device_field(
        [qw(name deviceDisplayName deviceClass deviceModel rawDeviceModel)] );
    # $info =  [
    #   [ "mmm cake", "iPhone 5", "iPhone", "SixthGen", "iPhone5,1" ],
    #   [ "soryu2", "MacBook Pro 15"", "MacBookPro", "MacBookPro10_1", "MacBookPro10,1" ],
    #   [ "mikegrb's ipad", "iPad 2", "iPad", "SecondGen", "iPad2,1" ]
    # ]

=head2 get_device_by( $field => $value)

L<WebService::FindMyiPhone::Device> object for the first device with $field
set to $value.

=head1 DEVICE FIELDS

There are quite a few device fields but the ones you are likely to find most
useful for identifying devices are C<name>, C<deviceModel>,
C<deviceDisplayName>, C<rawDeviceModel>, C<modelDisplayName>, C<deviceClass>.

c<name> is likely to be the most useful for identifying devices but multiple
devices with the same name are possible and only the first found is returned
by c<get_device_by>.  It seems that Apple returns devices by some order of
recentness so if your old iPhone has the same name as the new one, you are
likely to get the new one first.

=head1 AUTHOR

Mike Greb E<lt>michael@thegrebs.comE<gt>

=head1 COPYRIGHT

Copyright 2013- Mike Greb

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
