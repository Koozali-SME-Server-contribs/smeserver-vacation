package SrvMngr::Controller::Uservacations;
#----------------------------------------------------------------------
# heading     : User management
# description : User Vacations
# navigation  : 2000 150
#
# name   : Uservacationsget, method : get,   url : /uservacations,     ctlact : Uservacations#main
# name   : Uservacationspost,method : post,  url : /Uservacations,     ctlact : Uservacations#do_display
# name   : Uservacations1,   method : get,   url : /Uservacations1,    ctlact : Uservacations#do_display
# name   : Uservacations2,   method : post,  url : /Uservacations2,    ctlact : Uservacations#do_display
# routes : end
#----------------------------------------------------------------------

use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';

#use DateTime; #Not part of SME10 mix
use POSIX;

use Locale::gettext;
use SrvMngr::I18N;
use SrvMngr qw(theme_list init_session);

use Data::Dumper;
use esmith::util;
#use esmith::HostsDB::UTF8;
use esmith::AccountsDB;
use esmith::ConfigDB::UTF8;

my $db;
my $adb;

our $PanelUser = $ENV{'REMOTE_USER'} ||'';
$PanelUser = $1 if ($PanelUser =~ /^([a-z][\.\-a-z0-9]*)$/);

our  %delegatedVacations;

use constant FALSE => 0;
use constant TRUE  => 1;

sub main {

    my $c = shift;
    $c->app->log->info( $c->log_req );

	$db  = esmith::ConfigDB::UTF8->open() || die("Couldn't open config db");
	$adb = esmith::AccountsDB->open() || die("Couldn't open accounts db");

    my %vac_datas = ();
    my $title = $c->l('vac_FORM_TITLE');
    my $modul = '';

	if (! $c->is_admin) {
		#Here it is in user panel mode and needs the current user data loaded up
		$vac_datas{trt} = 'ADD';
		my $account = $c->session('username'); #TESTING from somewhere ....#$c->param("account");
		my $user = $adb->get($account);
		my $username = $user->prop("FirstName")." ".$user->prop("LastName");
        my $EmailVacation = $user->prop('EmailVacation') || '';
		my $EmailVacationFrom = $user->prop('EmailVacationFrom') || '';
		my $EmailVacationTo = $user->prop('EmailVacationTo') || '';
		$c->stash(account=>$account);
		my $VacText = get_vacation_text($c);
        $c->stash(username=>$username,
                  EmailVacation=>$EmailVacation,
                  EmailVacationFrom=>$EmailVacationFrom,
                  EmailVacationTo=>$EmailVacationTo,
                  VacText=>$VacText                 
                  );  
	} else {
		$vac_datas{trt} = 'LIST';
	}
    
	my @vacations = get_vacation_table($c); 
	my $empty = (scalar @vacations == 0);

    $vac_datas{"first"} = 'vac_MODIFY_DESCRIPTION';

    $c->stash(
        title         => $title,
        modul         => $modul,
        vac_datas      => \%vac_datas,
        vacations =>\@vacations,
        empty => $empty
    );
    $c->render( template => 'uservacations' );
}

sub do_display {

    my $c = shift;
    $c->app->log->info( $c->log_req );

	$db  = esmith::ConfigDB::UTF8->open() || die("Couldn't open config db");
	$adb = esmith::AccountsDB->open() || die("Couldn't open accounts db");

    my $rt           = $c->current_route;
    my $trt          = ( $c->param('trt') || 'LIST' );

    $trt = 'ADD'  if ( $rt eq 'Uservacations1' );
    $trt = 'ADD1'  if ( $rt eq 'Uservacations2' );

    my %vac_datas = ();
    my $title    = $c->l('vac_FORM_TITLE');
    my $modul    = '';

 
    if ( $trt eq 'ADD' ) {
		# Add or change a vacation message - called from the list panel
		# Get the data and pass it across.
		my $account = $c->param("account");
		my $user = $adb->get($account);
		my $username = $user->prop("FirstName")." ".$user->prop("LastName");
        my $EmailVacation = $user->prop('EmailVacation') || '';
		my $EmailVacationFrom = $user->prop('EmailVacationFrom') || '';
		my $EmailVacationTo = $user->prop('EmailVacationTo') || '';
		$c->stash(account=>$account);
		my $VacText = get_vacation_text($c);
        $c->stash(username=>$username,
                  EmailVacation=>$EmailVacation,
                  EmailVacationFrom=>$EmailVacationFrom,
                  EmailVacationTo=>$EmailVacationTo,
                  VacText=>$VacText                 
                  );  
    }

   if ( $trt eq 'ADD1' ) {
		#Add or edit vacation message. 
        my $ret = add_vac_message($c);	
        #Return to list page if success	
        # unless in user panel, in which case return to vacation msg display
        if ($ret eq "OK")  {
			if (! $c->is_admin){
				$trt = "ADD";
				#my $fred = 1/0;
				my $account = $c->session('username'); #TESTING from somewhere ....#$c->param("account");
				my $user = $adb->get($account);
				my $username = $user->prop("FirstName")." ".$user->prop("LastName");
				my $EmailVacation = $user->prop('EmailVacation') || '';
				my $EmailVacationFrom = $user->prop('EmailVacationFrom') || '';
				my $EmailVacationTo = $user->prop('EmailVacationTo') || '';
				my $VacText = get_vacation_text($c);
				$c->stash(account=>$account,
						  username=>$username,
						  EmailVacation=>$EmailVacation,
						  EmailVacationFrom=>$EmailVacationFrom,
						  EmailVacationTo=>$EmailVacationTo,
						  VacText=>$VacText                 
						  );  
			} else {
				$trt = "LIST";	
				$vac_datas{success} = "vac_SUCCESS";
			}
		} else {
			my $account = $c->param("account");
			my $user = $adb->get($account);
			my $username = $user->prop("FirstName")." ".$user->prop("LastName");
			my $EmailVacationFrom = $c->param('EmailVacationFrom') || '';
			my $EmailVacationTo = $c->param('EmailVacationTo') || '';
			my $EmailVacation = $c->param('EmailVacation') || '';
			my $VacText = $c->param("VacText");
			$c->stash(account=>$account,
					  username=>$username,
					  EmailVacation=>$EmailVacation,
					  EmailVacationFrom=>$EmailVacationFrom,
					  EmailVacationTo=>$EmailVacationTo,
					  VacText=>$VacText                 
                  );  
			#Error - return to Add page
			$trt = "ADD";
			$vac_datas{error} = $ret;
		}	
    }
    
	if ( $trt eq 'LIST' ) {

		#List all the users and vacation message details.
		my @vacations = get_vacation_table($c); 
		my $empty = (scalar @vacations == 0);
		$c->stash(
			empty => $empty,
			vacations =>\@vacations
		);
    }


    $vac_datas{'trt'} = $trt;  
    $c->stash( title => $title, modul => $modul, vac_datas => \%vac_datas );
    $c->render( template => 'uservacations' );
}

sub user_accounts_exist
{
    my $q = shift;
    #return scalar $adb->users;
    if (scalar $adb->users)
    { return $q->l('vac_DESCRIPTION'); }
}

sub get_vacation_table
{
    my $self = shift;

#We want to retrieve granted group from DB, and retrieve users of groups
    my $record = $adb->get($PanelUser);
    my $dg;
    if ($record) {$dg=$record->prop('delegatedVacations')||'';}
    else {$dg = '';}
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
    return () if (@users == 0); ##$self->l("ACCOUNT_USER_NONE") 
    return () if (@visiblemembers == 0 && $dg ne '');#; #$self->l("NO_USERS_IN_GRANTED_GROUPS") 

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
            { 	User           => $user->key,
				FullName       => $user->prop('FirstName') . " " .$user->prop('LastName'),
				status         => $self->l($status),
				EmailVacation  => $EmailVacation,
				EmailVacationFrom => showDate($EmailVacationFrom),
				EmailVacationTo => showDate($EmailVacationTo),
				Modify         => $self->l('vac_MODIFY'),
            }
    }
    return @data;
}

sub showDate {
    my $strDate = shift;

    # Try to capture Year, Month, Day from the string
    my ($Year, $Month, $Day) = ($strDate =~ /(\d{4})(\d{2})(\d{2})/);

    # Provide default values if regex capture fails or any part is undefined
    $Year  = defined $Year  ? $Year  : '0000';
    $Month = defined $Month ? $Month : '00';
    $Day   = defined $Day   ? $Day   : '00';

    return "$Year-$Month-$Day";
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
    my $q = shift;
    my $domain = $db->get_value('DomainName');
    my $user = $q->param('account') || $q->stash('account') || "unknown";
    my $fullname    = $adb->get_prop($user, "FirstName") . " " .
                      $adb->get_prop($user, "LastName");

    my $vfile = "/home/e-smith/files/users/$user/.vacation.msg";

    my $from = $q->l('vac_FROM');
    my $Subject = $q->l('vac_SUBJECT');
    my $away = $q->l('vac_AWAY_FROM_MAIL');
    my $return = $q->l('vac_ANSWER_TO_OBJECT_SENDER');

    #my $ExistingMessage = "$from $fullname &lt\;$user\@$domain&gt\;\n"."$Subject $return\n".
    #                      "\n$away\n"."\n--\n$fullname";

    my $ExistingMessage = "$from $fullname \<$user\@$domain\>\n"."$Subject $return\n".
                          "\n$away\n"."\n--\n$fullname";

$q->app->log->info( "DEBUG: File path is $vfile\n");
$q->app->log->info( "DEBUG: File exists? ", -e $vfile, "\n");
$q->app->log->info( "DEBUG: File empty? ", -z $vfile, "\n");


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
    return $ExistingMessage;
}

# saves the text to .vacation.msg
sub add_vac_message
{
    my $q = shift;

    my $domain = $db->get_value('DomainName');
    my $user = $q->param('account');

    my $EmailVacation  = $q->param('EmailVacation')||"no";
    #die($EmailVacation);
    #if ($EmailVacation eq "yes") {$EmailVacation = "yes";} else {$EmailVacation = "no";}

    #Decode To and FROM to standard format - comes over in html5 iso format yyyy-mm-dd
    my $EmailVacationFrom = trim($q->param('EmailVacationFrom'));
    my ($fromYear,$fromMonth,$fromDay)  = ($EmailVacationFrom =~ /(\d{4})-(\d{2})-(\d{2})/);
    $EmailVacationFrom = $fromYear.$fromMonth.$fromDay;
    if ($EmailVacationFrom !~ m/^2[0-9]{3}[0|1][0-9][0-3][0-9]$/ and $EmailVacationFrom ne "") {return "vac_FROM_DATE_INCORRECT";}
    my $EmailVacationTo = trim($q->param('EmailVacationTo'));
    my ($toYear,$toMonth,$toDay)  = ($EmailVacationTo =~ /(\d{4})-(\d{2})-(\d{2})/);
    $EmailVacationTo = $toYear.$toMonth.$toDay;
#    $EmailVacationTo =~ s/-//g; #Just take out "-".  
    if ($EmailVacationTo !~ m/^2[0-9]{3}[0|1][0-9][0-3][0-9]$/ and $EmailVacationFrom ne "") {return "vac_TO_DATE_INCORRECT";}
    #Check not the same or From follows To.   
    if ($EmailVacationTo ne "" and $EmailVacationTo eq $EmailVacationFrom) {return "vac_DATES_THE_SAME";}
    my $UnixFrom = mktime(0,0,0,$fromDay,$fromMonth,$fromYear);
    my $UnixTo = mktime(0,0,0,$toDay,$toMonth,$toYear);
    if ($UnixTo < $UnixFrom) {return "vac_TO_DATE_MUST_BE_LATER";}
    

    my $new_message    = $q->param('VacText');   
    my $vfile = "/home/e-smith/files/users/$user/.vacation.msg";

    my $fullname    = $adb->get_prop($user, "FirstName") . " " .
                      $adb->get_prop($user, "LastName");

    my $from = 'From:';
    my $away = $q->l('vac_AWAY_FROM_MAIL');
    my $return = $q->l('vac_ANSWER_TO_OBJECT_SENDER');

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

    return "OK";
}

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

1;