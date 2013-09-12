package WebService::FindMyiPhone::Device;

use strict;
use warnings;

use 5.010_001;
our $VERSION = '0.01';

use Carp;

use Data::Dumper;    # TODO: remove

sub new {
    my ( $class, $parent, $data ) = @_;
    my $self = { parent => $parent, %$data };
    return bless $self, $class;
}

sub _update_self {
    my ( $self, $new_data ) = @_;
    $self->{$_} = $new_data->{$_} for keys %$new_data;
}

sub send_message {
    my ( $self, $sound, $message, $subject ) = @_;
    $sound = $sound ? 'true' : 'false';
    $subject ||= 'Important Message';
    my $post
        = sprintf(
        '{"clientContext":{"appName":"FindMyiPhone","appVersion":"1.4","buildVersion":"145","deviceUDID":"0000000000000000000000000000000000000000","inactiveTime":5911,"osVersion":"3.2","productType":"iPad1,1","selectedDevice":"%s","shouldLocate":false},"device":"%s","serverContext":{"callbackIntervalInMS":3000,"clientId":"0000000000000000000000000000000000000000","deviceLoadStatus":"203","hasDevices":true,"lastSessionExtensionTime":null,"maxDeviceLoadTime":60000,"maxLocatingTime":90000,"preferredLanguage":"en","prefsUpdateTime":1276872996660,"sessionLifespan":900000,"timezone":{"currentOffset":-25200000,"previousOffset":-28800000,"previousTransition":1268560799999,"tzCurrentName":"Pacific Daylight Time","tzName":"America/Los_Angeles"},"validRegion":true},"sound":%s,"subject":"%s","text":"%s","userText":true}',
        $self->{id}, $self->{id}, $sound, $subject, $message );
    return $self->{parent}->_post( '/sendMessage', $post )->json;
}

sub remote_lock {
    my ( $self, $passcode ) = @_;
    my $post
        = sprintf(
        '{"clientContext":{"appName":"FindMyiPhone","appVersion":"1.4","buildVersion":"145","deviceUDID":"0000000000000000000000000000000000000000","inactiveTime":5911,"osVersion":"3.2","productType":"iPad1,1","selectedDevice":"%s","shouldLocate":false},"device":"%s","oldPasscode":"","passcode":"%s","serverContext":{"callbackIntervalInMS":3000,"clientId":"0000000000000000000000000000000000000000","deviceLoadStatus":"203","hasDevices":true,"lastSessionExtensionTime":null,"maxDeviceLoadTime":60000,"maxLocatingTime":90000,"preferredLanguage":"en","prefsUpdateTime":1276872996660,"sessionLifespan":900000,"timezone":{"currentOffset":-25200000,"previousOffset":-28800000,"previousTransition":1268560799999,"tzCurrentName":"Pacific Daylight Time","tzName":"America/Los_Angeles"},"validRegion":true}}',
        $self->{id}, $self->{id}, $passcode );
    return $self->{parent}->_post( '/remoteLock', $post );
}

sub location {
    my ($self) = @_;
    my $count = 0;
    while ( !$self->{location}{locationFinished} ) {
        print Dumper( $self->{location} );
        sleep 5;
        $self->{parent}->update_devices;
        last if ++$count >= 5;
        warn "Sleeping and checking again";

    }
    return $self->{location};
}

1;
__END__

=encoding utf-8

=head1 NAME

WebService::FindMyiPhone::Device - Blah blah blah

=head1 SYNOPSIS

  use WebService::FindMyiPhone;

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
