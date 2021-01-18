#=================================================================================
# §package       FI_GAGAR::ElectionChoice::UI::Shop
# §state         public
# §base          DE_EPAGES::Presentation::UI::Object
# §description   Shop UI methods.
#=================================================================================
package FI_GAGAR::ElectionChoice::UI::Shop;
use base DE_EPAGES::Presentation::UI::Object;
use strict;
use DE_EPAGES::Core::API::Log qw(GetLog LogDebug);
#=================================================================================
# §function      SaveSettings
# §state         public
#---------------------------------------------------------------------------------
# §syntax        $Object->SaveSettings($Servlet);
#---------------------------------------------------------------------------------
# §description   Function saves data on age settings page
#---------------------------------------------------------------------------------
# §input         $Servlet | current servlet (contains form data) | object
# §return        -
#=================================================================================
sub SaveSettings {
    my $self = shift;
    my ($Servlet) = @_;
    my $Shop = $Servlet->object;
    my $Form = $Servlet->form;
    my $hFormValues = $Form->form($Shop, 'ElectionSettings');
    LogDebug("Formin data", $Form);
    LogDebug("Formin arvot", $hFormValues);
   # $self->SUPER::Save($Servlet);
    $Shop->set($hFormValues);  #  $Shop->set({ 'PollingA' => 3, 'PollingB' => 3, 'PollingC' => 3 });
    return;
}
1;