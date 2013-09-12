# NAME

WebService::FindMyiPhone - Blah blah blah

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

WebService::FindMyiPhone is

# AUTHOR

Mike Greb <michael@thegrebs.com>

# COPYRIGHT

Copyright 2013- Mike Greb

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
