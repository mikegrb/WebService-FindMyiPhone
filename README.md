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

Takes named parameters. `username` & `password` are required. `debug` is
also available.

## update\_devices

Updates the information stored for all devices.  This includes location
information for each device.

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

[WebService::FindMyiPhone::Device](https://metacpan.org/pod/WebService::FindMyiPhone::Device) object for the first device with `$field`
set to `$value`.

# DEVICE FIELDS

There are quite a few device fields but the ones you are likely to find most
useful for identifying devices are `name`, `deviceModel`,
`deviceDisplayName`, `rawDeviceModel`, `modelDisplayName`, `deviceClass`.

`name` is likely to be the most useful for identifying devices but multiple
devices with the same name are possible and only the first found is returned
by `get_device_by`.  It seems that Apple returns devices by some order of
recentness so if your old iPhone has the same name as the new one, you are
likely to get the new one first.

# DEVICE OBJECTS

Device objects are stored as a blessed hashref, the `_parent` key is a
reference to the [WebService::FindMyiPhone](https://metacpan.org/pod/WebService::FindMyiPhone) object that created it.  The rest
of the keys are directly from Apple.  You are incouraged to inspect the data
there and make use of anything interesting to you.

## Device Methods

### send\_message( $sound, $message, $subject )

Send a message to the device.  `$sound` determines if a sound should be
played with the message, a true value will cause a sound even if the phone or
iPad is in silent mode.  `$message` is the message to display.  `$subject` is
optional and defaults to 'Important Message'.

### remote\_lock($passcode)

Lock the device remotely and require `$passcode` to unlock.

### location()

Returns a hashref with location data.  Keys include `latitude`, `longitude`,
`horizontalAccuracy`, `positionType`, `isInaccurate`, `isOld `,
`locationType`, `locationFinished`, and `timeStamp`.

If <locationFinished> is false, the method will sleep 2 seconds, call the
parent's `update_devices` method and check again.  It will try up to 3 times
and then return what it has.

Possible values for `positionType` are 'GPS' and 'Wifi'.

`timeStamp` is epoch time with milliseconds, divide by 1000 for standard time
with milliseconds.

# AUTHOR

Mike Greb <michael@thegrebs.com>

# COPYRIGHT

Copyright 2013- Mike Greb

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
