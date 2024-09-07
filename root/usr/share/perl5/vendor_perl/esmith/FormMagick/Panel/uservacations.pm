#----------------------------------------------------------------------
#  uservacations.pm
#  support@dungog.net
#----------------------------------------------------------------------

package esmith::FormMagick::Panel::uservacations;

use strict;
use warnings;

use esmith::util;
use esmith::FormMagick;
use esmith::AccountsDB;
use esmith::ConfigDB;

use Exporter;
use Carp qw(verbose);

use HTML::Tabulate;

our @ISA = qw(esmith::FormMagick Exporter);

our @EXPORT = qw();

our $db  = esmith::ConfigDB->open();
our $adb = esmith::AccountsDB->open();

our $PanelUser = $ENV{'REMOTE_USER'} ||'';
$PanelUser = $1 if ($PanelUser =~ /^([a-z][\.\-a-z0-9]*)$/);

our  %delegatedVacations;

sub new {
    shift;
    my $self = esmith::FormMagick->new(filename => '/etc/e-smith/web/functions/uservacations');
    $self->{calling_package} = (caller)[0];
    bless $self;
    return $self;
}


#server-manager functions
sub user_accounts_exist
{
    my $self = shift;
    my $q = $self->{cgi};
    #return scalar $adb->users;
    if (scalar $adb->users)
    { return $self->localise('DESCRIPTION'); }
}

sub print_vacation_table
{
    my $self = shift;
    my $q = $self->{cgi};

#We want to retrieve granted group from DB, and retrieve users of groups
    my $record = $adb->get($PanelUser);
    my $dg=$record->prop('delegatedVacations')||'';
    $dg =~ s/ //g;
    my @g = split(/,/, $dg);
    my @visiblemembers = ();

    foreach my $g (@g) {
        my $members = $adb->get_prop("$g",'Members');
        next unless defined $members;
        $members =~ s/ //g;
        my @members = split(/,/, $members);
        push @visiblemembers , @members ;
        }

    foreach my $k (  @visiblemembers )
                {
                $delegatedVacations{$k}=1;
                }
    

    my @users = $adb->users;
    return $self->localise("ACCOUNT_USER_NONE") if (@users == 0);
    return $self->localise("NO_USERS_IN_GRANTED_GROUPS") if (@visiblemembers == 0 && $dg ne '');

    my $vacation_table =
    {
       title => $self->localise('USER_LIST_CURRENT'),

       stripe => '#D4D0C8',

       fields => [ qw(User FullName status Modify) ],

       labels => 1,

       field_attr => {
                       User          => { label_escape => 0, escape => 0 , label => $self->localise('ACCOUNT')     },

                       FullName      => { label_escape => 0, escape => 0 , label => $self->localise('USER_NAME') },

                       status        => { label_escape => 0, escape => 0 , label => $self->localise('LABEL_VACATION') },

                       Modify        => { label_escape => 0,
                                           label => $self->localise('MODIFY'),
                                           link  => \&modify_link
                                        },
                      }
    };

    my @data = ();

    for my $user (@users)
    {
        next if %delegatedVacations and not $delegatedVacations{$user->key};
        # make it clearer which uses have vacation
        my $EmailVacation = $user->prop('EmailVacation') || '';
	my $EmailVacationFrom = $user->prop('EmailVacationFrom') || '';
	my $EmailVacationTo = $user->prop('EmailVacationTo') || '';
        my $status        = $user->prop('EmailVacation') || '';
        if ($status eq 'yes') { $status = 'YES'; } else { $status = ''; }

        push @data,
            { User           => $user->key,
              FullName       => $user->prop('FirstName') . " " .
                                $user->prop('LastName'),
              status         => $self->localise($status),
              EmailVacation  => $EmailVacation,
	      EmailVacationFrom => $EmailVacationFrom,
	      EmailVacationTo => $EmailVacationTo,
              Modify         => $self->localise('MODIFY'),
            }
    }

    my $t = HTML::Tabulate->new($vacation_table);

    $t->render(\@data, $vacation_table);
}

sub modify_link
{
    my ($data_item, $row, $field) = @_;

    return "uservacations?" .
        join("&",
        "page=0",
        "page_stack=",
        "Next=Next",
        "User="     . $row->{User},
        "FullName=" . $row->{FullName},
        "EmailVacation=" . $row->{EmailVacation},
        "EmailVacationFrom=" . $row->{EmailVacationFrom},
	"EmailVacationTo=" . $row->{EmailVacationTo},
        "wherenext=VACATION_PAGE_MODIFY");
}

# this formats the text to display on screen
sub get_vacation_text
{
    my $self = shift;
    my $q = $self->{cgi};

    my $domain = $db->get_value('DomainName');
    my $user = $q->param('User');

    my $fullname    = $adb->get_prop($user, "FirstName") . " " .
                      $adb->get_prop($user, "LastName");

    my $vfile = "/home/e-smith/files/users/$user/.vacation.msg";

    my $from = 'From:';
    my $away = $self->localise('AWAY_FROM_MAIL');
    my $return = $self->localise('ANSWER_TO_OBJECT_SENDER');

    my $ExistingMessage = "$from $fullname &lt\;$user\@$domain&gt\;\n"."Subject: $return\n".
                          "\n$away\n"."\n--\n$fullname";

    # if exists and is not empty
    if (( -e $vfile ) && (! -z $vfile ))
    {
        open (VACATION, "<$vfile")
          or die "Error: Could not open file: $vfile\n";
        my @vacationTemp;

        #reformat so email address isn't hidden inside < >
        while (<VACATION>)
        {
          $_ =~ s/</&lt\;/;
          $_ =~ s/>/&gt\;/;
          push (@vacationTemp, $_);
        }

        $ExistingMessage = join ("", @vacationTemp);

        close VACATION;
    }
    my $start = '<tr>
                 <td class="sme-noborders-label">' . $self->localise('MESSAGE') . '
                 <td class="sme-noborders-content"><TEXTAREA NAME="new_message" ROWS="10" COLS="60">';

    my $end   = '</TEXTAREA></td>
                 </tr>';

    return $start . $ExistingMessage . $end;
}

# saves the text to .vacation.msg
sub change_settings
{
    my $self = shift;
    my $q = $self->{cgi};

    my $domain = $db->get_value('DomainName');
    my $user = $q->param('User');

    my $EmailVacation  = $q->param('EmailVacation');
    my $EmailVacationFrom = $q->param('EmailVacationFrom');
    my $EmailVacationTo = $q->param('EmailVacationTo');
    my $new_message    = $q->param('new_message');
    my $vfile = "/home/e-smith/files/users/$user/.vacation.msg";

    my $fullname    = $adb->get_prop($user, "FirstName") . " " .
                      $adb->get_prop($user, "LastName");

    my $from = 'From:';
    my $away = $self->localise('AWAY_FROM_MAIL');
    my $return = $self->localise('ANSWER_TO_OBJECT_SENDER');

    my $vacation_text   = "$from $fullname \<$user\@$domain\>\n"."Subject: $return\n".
                          "\n$away \n"."\n--\n$fullname";

    my $reset = $vacation_text;

    # if exists and is not empty
    if (( -e $vfile ) && (! -z $vfile ))
    {
        open (VACATION, "<$vfile")
          or die "Error: Could not open file: $vfile\n";
        my @vacationTemp = <VACATION>;
        $vacation_text = join ("", @vacationTemp);

        close VACATION;
    }

    chomp $new_message;

    # reset msg to default,
    if ($new_message =~ /reset/)
    { $vacation_text = $reset; }
    else
    {
        #or save new_message
        unless ($new_message eq "")
        { $vacation_text = $new_message; }
    }

    # Strip out DOS Carriage Returns (CR)
    $vacation_text =~ s/\r//g;

    unlink $vfile;
    open (VACATION, ">$vfile")
      or die ("Error opening vacation message.\n");

    print VACATION "$vacation_text";
    close VACATION;

    esmith::util::chownFile($user, $user,
    "/home/e-smith/files/users/$user/.vacation.msg");

    $adb->set_prop($user, 'EmailVacation', $EmailVacation);
    $adb->set_prop($user, 'EmailVacationFrom', $EmailVacationFrom);
    $adb->set_prop($user, 'EmailVacationTo', $EmailVacationTo);

    #the first is more correct but is slower
    #system ("/sbin/e-smith/signal-event", "email-update", $user) == 0
    system ("/etc/e-smith/events/actions/qmail-update-user event $user") == 0
        or die ("Error occurred updating .qmail\n");

    if (($EmailVacation eq 'no') && ( -e "/home/e-smith/files/users/$user/.vacation"))
    {
        system ("/bin/rm /home/e-smith/files/users/$user/.vacation") == 0
          or die ("Error resetting vacation db.\n");
    }

    return $self->success("SUCCESS");
}

#userpanel functions   ######################################################
sub get_panel_user
{
    return $PanelUser;
}

sub get_full_name
{
    return  $adb->get_prop($PanelUser, "FirstName") . " " .
            $adb->get_prop($PanelUser, "LastName");
}

sub get_vacation_status
{
    return $adb->get_prop($PanelUser, "EmailVacation");
}

sub get_vacation_date_from
{
    return $adb->get_prop($PanelUser, "EmailVacationFrom");
}

sub get_vacation_date_to
{
    return $adb->get_prop($PanelUser, "EmailVacationTo");
}

# this formats the text to display on screen
sub userpanel_get_vacation_text
{
    my $self = shift;
    my $q = $self->{cgi};

    my $domain = $db->get_value('DomainName');

    # single difference in userpanel function
    my $user = $PanelUser;

    my $fullname    = $adb->get_prop($user, "FirstName") . " " .
                      $adb->get_prop($user, "LastName");
    my $vfile = "/home/e-smith/files/users/$user/.vacation.msg";

    my $from = 'From:';
    my $away = $self->localise('AWAY_FROM_MAIL');
    my $return = $self->localise('ANSWER_TO_OBJECT_SENDER');

    my $ExistingMessage = "$from $fullname &lt\;$user\@$domain&gt\;\n"."Subject: $return\n".
                          "\n$away"."\n--\n$fullname";

    # if exists and is not empty
    if (( -e $vfile ) && (! -z $vfile ))
    {
        open (VACATION, "<$vfile")
          or die "Error: Could not open file: $vfile\n";
        my @vacationTemp;

        #reformat so email address isn't hidden inside < >
        while (<VACATION>)
        {
          $_ =~ s/</&lt\;/;
          $_ =~ s/>/&gt\;/;
          push (@vacationTemp, $_);
        }

        $ExistingMessage = join ("", @vacationTemp);

        close VACATION;
    }
    my $start = '<tr>
                 <td class="sme-noborders-label">' . $self->localise('MESSAGE') . '
                 <td class="sme-noborders-content"><TEXTAREA NAME="new_message" ROWS="10" COLS="60">';

    my $end   = '</TEXTAREA></td>
                 </tr>';

    return $start . $ExistingMessage . $end;
}

# saves the text to .vacation.msg
sub userpanel_change_settings
{
    my $self = shift;
    my $q = $self->{cgi};

    my $domain = $db->get_value('DomainName');

    # single difference in userpanel function
    my $user = $PanelUser;

    my $EmailVacation  = $q->param('EmailVacation');
    my $new_message    = $q->param('new_message');
    my $EmailVacationFrom = $q->param('EmailVacationFrom');
    my $EmailVacationTo = $q->param('EmailVacationTo');
    my $vfile = "/home/e-smith/files/users/$user/.vacation.msg";

    my $fullname    = $adb->get_prop($user, "FirstName") . " " .
                      $adb->get_prop($user, "LastName");

    my $from = 'From:';
    my $away = $self->localise('AWAY_FROM_MAIL');
    my $return = $self->localise('ANSWER_TO_OBJECT_SENDER');

    my $vacation_text   = "$from $fullname \<$user\@$domain\>\n"."Subject: $return\n".
                          "\n$away \n"."\n--\n$fullname";

    my $reset = $vacation_text;

    # if exists and is not empty
    if (( -e $vfile ) && (! -z $vfile ))
    {
        open (VACATION, "<$vfile")
          or die "Error: Could not open file: $vfile\n";
        my @vacationTemp = <VACATION>;
        $vacation_text = join ("", @vacationTemp);

        close VACATION;
    }

    chomp $new_message;

    # reset msg to default,
    if ($new_message =~ /reset/)
    { $vacation_text = $reset; }
    else
    {
        #or save new_message
        unless ($new_message eq "")
        { $vacation_text = $new_message; }
    }

    # Strip out DOS Carriage Returns (CR)
    $vacation_text =~ s/\r//g;

    unlink $vfile;
    # for the next lines to avoid race condition vulnerability, we switch the effective user to 
    # the one needed see SME #9073 . Those 4 lines are for explanation of the used variables.
    #$< - real user id (uid); unique value
    #$> - effective user id (euid); unique value
    #$( - real group id (gid); list (separated by spaces) of groups
    #$) - effective group id (egid); list (separated by spaces) of groups

    # remember the UID of the user currently running this script
    my $original_uid = $>;
    my $original_gid = $);

    # switch effective UID running this script to $user
    # in order to prevent race condition vulnerability
    my $uid = getpwnam($user) or die "Could not get UID for $user\n";
    my $gid = getgrnam($user) or die "Could not get GID for $user\n";
    $) = $gid;# should be switched first while still root!
    $> = $uid;

    open (VACATION, ">$vfile")
      or die ("Error opening vacation message.\n");

    print VACATION "$vacation_text";
    close VACATION;

    # switch effective UID and GID back to original user
    $> = $original_uid;
    $) = $original_gid;

    $adb->set_prop($user, 'EmailVacation', $EmailVacation);
    $adb->set_prop($user, 'EmailVacationFrom', $EmailVacationFrom);
    $adb->set_prop($user, 'EmailVacationTo', $EmailVacationTo);

    #the first is more correct but is slower
    #system ("/sbin/e-smith/signal-event", "email-update", $user) == 0
    system ("/etc/e-smith/events/actions/qmail-update-user event $user") == 0
        or die ("Error occurred updating .qmail\n");

    if (($EmailVacation eq 'no') && ( -e "/home/e-smith/files/users/$user/.vacation"))
    {
        system ("/bin/rm /home/e-smith/files/users/$user/.vacation") == 0
          or die ("Error resetting vacation db.\n");
    }

    return $self->success("SUCCESS");
}

1;
