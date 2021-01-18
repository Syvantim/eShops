#========================================================================================
# §package      FI_GAGAR::ElectionChoice::API::Cartridge
# §base         DE_EPAGES::Design::API::DesignInstaller
# §state        public
#----------------------------------------------------------------------------------------
# §description  This is the main cartridge class for install/patch/uninstall.
#========================================================================================
package FI_GAGAR::ElectionChoice::API::Cartridge;
use base DE_EPAGES::Design::API::DesignInstaller;

use strict;

#========================================================================================
# §function     new
# §state        private
#----------------------------------------------------------------------------------------
# §syntax       $Installer = FI_GAGAR::ElectionChoice::API::Cartridge->new(%options);
#----------------------------------------------------------------------------------------
# §description  Creates a new installer object of FI_GAGAR::ElectionChoice.
#----------------------------------------------------------------------------------------
# §input        %options | options for un/install
#               <ul>
#                 <li>IsRecursive - recursive un/installation of required or dependent
#                     cartridges
#               </ul>
#               | hash
# §return       $Installer | cartridge installer | object
#========================================================================================
sub new {
    my ($class, %options) = @_;

    my $self = __PACKAGE__->SUPER::new(
        %options,
        'CartridgeDirectory' => 'FI_GAGAR/ElectionChoice',
        'Version'            => '7.54.0',
        'Patches'            => [],
    );
    return bless $self, $class;
}

#========================================================================================
# §function     install
# §state        private
#----------------------------------------------------------------------------------------
# §syntax       $Installer->install;
#----------------------------------------------------------------------------------------
# §description  Installs the cartridge.
#========================================================================================
sub install {
    my $self = shift;

    $self->startInstall;
    $self->SUPER::install;
    $self->finishInstall;
    return;
}

#========================================================================================
# §function     uninstall
# §state        private
#----------------------------------------------------------------------------------------
# §syntax       $Installer->uninstall;
#----------------------------------------------------------------------------------------
# §description  Uninstalls the cartridge.
#========================================================================================
sub uninstall {
    my $self = shift;

    $self->startUninstall;
    $self->SUPER::uninstall;
    $self->finishUninstall;
    return;
}

1;
