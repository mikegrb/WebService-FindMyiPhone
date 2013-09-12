# NAME

WebService::FindMyiPhone - Perl interface to Apple's Find My iPhone service

# SYNOPSIS

    use WebService::FindMyiPhone;
    my $fmiphone = WebService::FindMyiPhone->new(
        username => 'email@address',
        password => 'YaakovLOVE',
    );
    my $iphone = $fmiphone->get_device_by( name => 'mmm cake');
    my $location = $iphone->location();
    $iphone->send_message(1, 'Where did I leave you?');

# DESCRIPTION

WebService::FindMyiPhone is a Perl interface to Apple's Find My iPhone service.

# METHODS

## new

## update\_devices

## get\_devices\_field( $field )

Retrieves an array ref of specified field's value for each device.

    my $names = $fmiphone->get_devices_field('name');
    # $names = [ "mmm cake", "soryu2", "mikegrb's ipad" ];

## get\_devices\_field(\[ @fields \])

Retrieves an array ref array refs of specified fields' value for each device.

    my $info = $fmiphone->get_device_field(
        [qw(name deviceDisplayName deviceClass deviceModel rawDeviceModel)] );
    # $info =  [
    #   [ "mmm cake", "iPhone 5", "iPhone", "SixthGen", "iPhone5,1" ],
    #   [ "soryu2", "MacBook Pro 15"", "MacBookPro", "MacBookPro10_1", "MacBookPro10,1" ],
    #   [ "mikegrb's ipad", "iPad 2", "iPad", "SecondGen", "iPad2,1" ]
    # ]

## get\_device\_by( $field => $value)

[WebService::FindMyiPhone::Device](http://search.cpan.org/perldoc?WebService::FindMyiPhone::Device) object for the first device with $field
set to $value.

# DEVICE FIELDS

There are quite a few device fields but the ones you are likely to find most
useful for identifying devices are `name`, `deviceModel`,
`deviceDisplayName`, `rawDeviceModel`, `modelDisplayName`, `deviceClass`.

c<name> is likely to be the most useful for identifying devices but multiple
devices with the same name are possible and only the first found is returned
by c<get\_device\_by>.  It seems that Apple returns devices by some order of
recentness so if your old iPhone has the same name as the new one, you are
likely to get the new one first.

# AUTHOR

Mike Greb <michael@thegrebs.com>

# COPYRIGHT

Copyright 2013- Mike Greb

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
