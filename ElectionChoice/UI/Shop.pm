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
use DE_EPAGES::Core::API::CSV qw(ParseCSV);
use DE_EPAGES::Core::API::File qw(ExistsFile GetFileContentLines WriteFile);
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

#=================================================================================
# §function      SaveElection
# §state         public
#---------------------------------------------------------------------------------
# §syntax        $Object->SaveElection($Servlet);
#---------------------------------------------------------------------------------
# §description   Function add a new vote to total value.
#---------------------------------------------------------------------------------
# §input         $Servlet | current servlet (contains form data) | object
# §return        -
#=================================================================================
sub SaveElection {
    my $self = shift;
    my ($Servlet) = @_;
    my $Shop = $Servlet->object;
    my $Form = $Servlet->form;

    LogDebug("Form",$Form);

    my $Result = $Form->value('Result');
    return unless $Result =~ /^[ABCD]$/;

    my $Attribute = "Polling" . $Result;
    my $OldValue = $Shop->get($Attribute);
    $Shop->set({ $Attribute => $OldValue + 1 });

    return;

}

#=================================================================================
# §function      ExportToFile
# §state         public
#---------------------------------------------------------------------------------
# §syntax        $Object->ExportToFile($Servlet);
#---------------------------------------------------------------------------------
# §description   Function writes Election data to csv file.
#---------------------------------------------------------------------------------
# §input         $Servlet | current servlet (contains form data) | object
# §return        -
#=================================================================================
sub ExportToFile {
    my $self = shift;
    my ($Servlet) = @_;
    my $shop = $Servlet->object;
    $self->SaveElection($Servlet);

    my $filename = '/tmp/export.csv';

    GetLog->debug("Tiedoston tallennus alkaa");
    my $hValues = $shop->get(['PollingA','PollingB','PollingC','PollingD']);

    open(FH, '>', $filename) or die $!;

    print FH $hValues->{'PollingA'};
    print FH ',';
    print FH $hValues->{'PollingB'};
    print FH ',';
    print FH $hValues->{'PollingC'};
    print FH ',';
    print FH $hValues->{'PollingD'};

    print FH "\n";

    close(FH);

    return;
}
1;