use Test::More;
use strict;

use DE_EPAGES::Core::API::Script qw( RunScript );
use FI_GAGAR::ElectionChoice::API::Cartridge;

RunScript(
    Sub => sub {
        my $Cartridge = FI_GAGAR::ElectionChoice::API::Cartridge->new();
        $Cartridge->test();
        done_testing();
    }
);
