# $Id: smeserver-vacation.spec,v 1.11 2024/03/01 09:40:09 brianr Exp $
# Authority: dungog
# Name: Stephen Noble

%define name smeserver-vacation
%define version 11.0.0
%define release 1
Summary: SME Server enhancement to enable vacation messages for users.
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GNU GPL version 2
URL: http://www.dungog.net/sme
Group: SMEserver/addon
Source: %{name}-%{version}.tar.xz

BuildArchitectures: noarch
BuildRoot: /var/tmp/%{name}-%{version}
Requires: smeserver-release >= 9.0,
Requires: smeserver-formmagick >= 1.4.0-12
# needs /usr/share/perl5/vendor_perl/ctime.pl
Requires: perl-Perl4-CoreLibs
BuildRequires: smeserver-devtools >= 1.13.1-03
#BuildRequires: smeserver-manager >= 24
AutoReqProv: no

%description
SME Server enhancement to enable vacation messages for users.
Optionally provides a user-manager panel where users can
enable vacation for themselves and to modify their own message

%changelog
* Sat May 17 2025 Brian Read <brianr@koozali.org> 11.0.0-1.sme
- Fix call to $config-> to  config-> in default panel [SME: 12908]

* Sun Sep 08 2024 fix-e-smith-pkg.sh by Trevor Batley <trevor@batley.id.au> 1.1-38.sme
- Fix e-smith references in smeserver-vacation [SME: 12732]

* Sat Sep 07 2024 cvs2git.sh aka Brian Read <brianr@koozali.org> 1.1-37.sme
- Roll up patches and move to git repo [SME: 12338]

* Sat Sep 07 2024 BogusDateBot
- Eliminated rpmbuild "bogus date" warnings due to inconsistent weekday,
  by assuming the date is correct and changing the weekday.

* Fri Mar 01 2024 Brian Read <brianr@koozali.org> 1.1-36.sme
- Edit Menu entry to conform to new arrangements [SME: 12493]

* Fri Feb 16 2024 Brian Read <brianr@koozali.org> 1.1-35.sme
- Sort out html chars in email default  [SME: 12475]
- Add signal-event refresh to spec file. [sme 12474]

* Fri Jan 07 2022 Brian Read <brianr@bjsystems.co.uk> 1.1-34.sme
- Add-extra-class-in-div-for-AdminLTE [SME: 11834]

* Wed Aug 25 2021 Terry Fage <tfage@yahoo.com.au> 1.1-33.sme
- apply locale 2021-08-25 patch

* Fri Feb 26 2021 Jean-Philipe Pialasse <tests@pialasse.com> 1.1-32.sme
- avoid reencoding of strings in admin table of users [SME: 11399]

* Mon Feb 22 2021 Jean-Philipe Pialasse <tests@pialasse.com> 1.1-31.sme
- add requirement ctime.pl to display log  [SME: 10927]

* Sat Oct 24 2020 Brian Read <brianr@bjsystems.co.uk> 1.1-30.sme
- Update to make call to smanager and systemd dependant on smanager being installed and move from post in spec file [SME: 11052]
- to smeserver-vacation-update event

* Thu Jun 11 2020 Brian Read <brianr@bjsystems.co.uk> 1.1-29.sme
- Update for Apache-Mod-Proxy mode Server2 [SME:10927]

* Tue May 19 2020 Brian Read <brianr@bjsystems.co.uk> 1.1-28.sme
- Part of SME10 Server manager2  - Better display of dates in list [SME:10927 ]

* Tue Apr 28 2020 Brian Read <brianr@bjsystems.co.uk> 1.1-27.sme
- Update to SME10 - rework server manager panels to use manager2 [SME:10927]

* Fri Dec 14 2018 John Crisp <jcrisp@safeandsoundit.co.uk> 1.1-26.sme
- apply locale 2018-12-14 patch

* Sun Feb 26 2017 Jean-Philipe Pialasse <tests@pialasse.com> 1.1-25.sme
- html message autodection: swith to html when "<html" and "</html>" are present
- in the content, update patch [SME: 6614]

* Mon Jan 16 2017 Jean-Philipe Pialasse <tests@pialasse.com> 1.1-24.sme
- NFR allow html message and auto detect to switch from text to html [SME: 6614]

* Mon Jan 16 2017 Jean-Philipe Pialasse <tests@pialasse.com> 1.1-23.sme
- Fix possible race condition vulnerability during creation of vacation.msg [SME: 9073]
- thanks to Mats Schuh and Charlie Brady for the work.
- Translation smeserver-vacation-1.1-locale-2017-01-16.patch
- Eliminated rpmbuild "bogus date" warnings due to inconsistent weekday,
  by assuming the date is correct and changing the weekday.

* Sat Jul 16 2016 stephane de Labrusse <stephdl@de-labrusse.fr> 1.1-22.sme
- Added a capital to subject : Subject [SME: 8772]

* Fri Jul 15 2016 stephane de Labrusse <stephdl@de-labrusse.fr> 1.1-21.sme
- Translation patch added
- Added smeserver-vacation-1.1-locale-2016-07-15.patch
- Added a signature in the email body
- modified smeserver-vacation-1.1.bz8772.fix.vacation.message.translation.patch

* Thu Jul 14 2016 stephane de Labrusse <stephdl@de-labrusse.fr> 1.1-19.sme
- corrected the object email issue [SME: 8772]
- modified smeserver-vacation-1.1.bz8772.fix.vacation.message.translation.patch

* Sun Jul 10 2016 stephane de Labrusse <stephdl@de-labrusse.fr> 1.1-17.sme
- Fixed the auto enabled and disable vacation message [SME: 9661]
- Added smeserver-vacation-1.1.bz9661.fix_auto_enable_disable_vacation.patch
- Fixed the translation of the vacation message [SME: 8772]
- Added smeserver-vacation-1.1.bz8772.fix.vacation.message.translation.patch

* Wed Jul 06 2016 stephane de Labrusse <stephdl@de-labrusse.fr> 1.1-15.sme
- Add translation smeserver-vacation-1.1-locale-2016-07-07.patch
- Add translation smeserver-vacation-1.1-locale-2016-07-06.patch
- delegate the vacation messages by group permissions [SME: 9657] 

* Wed Jun 22 2016 stephane de Labrusse <stephdl@de-labrusse.fr> 1.1-13.sme
- Add the automated and disabling user vacations on given date in the user panel.
- Add translation smeserver-vacation-1.1-locale-2016-06-21.patch

* Tue Mar 08 2016 JP Pialasse <tests@pialasse.com> 1.1-12.sme
- Added smeserver-vacation-1.1-locale-2016-03-08.patch

* Tue Sep 29 2015 mats schuh <m.schuh@neckargeo.net> 1.1-11.sme
- Added smeserver-vacation-1.1-locale-2015-09-29.patch

* Wed Sep 23 2015 mats schuh <m.schuh@neckargeo.net> 1.1-10.sme
- suppress the mail output from the cron job [SME: 9065]

* Sat Sep 12 2015 stephane de Labrusse <stephdl@de-labrusse.fr> 1.1-9.sme
- Added smeserver-vacation-1.1-locale-2015-09-12.patch

* Fri Sep 4 2015 stephane de Labrusse <stephdl@de-labrusse.fr> 1.1-7.sme 
- code done by Mats Schuh <m.schuh@neckargeo.net>
- Allow automated enabling and disabling of user vacations on given dates [SME: 7555]
- Above functionality provided by additional db accounts entries and a cron script

* Thu Jan 8 2015 Daniel Berteaud <daniel@firewall-services.com> 1.1-6.sme
- Make the subject header match case insensitive (patch from Mats Schuh) [SME: 8777]

* Thu Jan 8 2015 Daniel Berteaud <daniel@firewall-services.com> 1.1-5.sme
- Do not localize From header (patch from Mats Schuh) [SME: 8776]

* Tue Jan 6 2015 stephane de Labrusse <stephdl@de-labrusse.fr> 1.1-4.sme
- Updated instructions to use virtual sender domain for vacation message
- Created by Mats Schuh m.schuh@neckargeo.net

* Wed Dec 24 2014 Daniel Berteaud <daniel@firewall-services.com> 1.1-3.sme
- Fix multiline matching [SME: 8741]

* Wed Dec 24 2014 Daniel Berteaud <daniel@firewall-services.com> 1.1-2.sme
- Fix dbmopen by specifying the dbm module to use (DB_File) [SME: 8741]

* Wed Nov 13 2013 Daniel Berteaud <daniel@firewall-services.com> 1.1-1.sme
- Rebuild for SME9

* Mon Jul 15 2013 JP Pialasse <tests@pialasse.com> 1.0-41.sme
- apply locale 2013-07-15 patch

* Sun Mar 06 2011 SME Translation Server <translations@contribs.org> 1.0-40.sme
- apply locale 2011-03-06 patch

* Sun May 23 2010 SME Translation Server <translations@contribs.org> 1.0-39.sme
- apply locale 2010-05-23 patch

* Tue Oct 27 2009 SME Translation Server <translations@contribs.org> 1.0-38.sme
- apply locale 2009-10-27 patch

* Mon Aug 24 2009 SME Translation Server <translations@contribs.org> 1.0-37.sme
- apply locale 2009-08-24 patch

* Thu Jun 11 2009 Stephen Noble <support@dungog.net> - 1.0-36
- send vacation mail in utf8 [SME 4389]

* Sat Jun 06 2009 Stephen Noble <support@dungog.net> - 1.0-35
- cp .qmail fragment before SME filtering with filterorder prop [SME: 5327]

* Wed May 20 2009 SME Translation Server <translations@contribs.org> 1.0-34.sme
- apply locale 2009-05-20 patch

* Mon Apr 27 2009 SME Translation Server <translations@contribs.org> 1.0-33.sme
- apply locale 2009-04-27 patch

* Sun Mar  1 2009 Jonathan Martens <smeserver-contribs@snetram.nl> 1.0-32
- Apply  1 Mar 2009 locale patch [SME: 5018]

* Thu Jan  1 2009 Jonathan Martens <smeserver-contribs@snetram.nl> 1.0-31
- Apply  1 Jan 2009 locale patch [SME: 4900]

* Tue Oct 14 2008 Jonathan Martens <smeserver-contribs@snetram.nl> 1.0-30
- Apply 14 Oct 2008 locale patch

* Sat Sep 27 2008 Stephen Noble <support@dungog.net> - 1.0-29
- move .qmail fragment after SME forwarding [SME: 4603]
- Apply 27 August 2008 locale patch

* Wed Aug 13 2008 Jonathan Martens <smeserver-contribs@snetram.nl> 1.0-28
  Sat Aug 13 2008 --> Sat Aug 09 2008 or Wed Aug 13 2008 or Sat Aug 16 2008 or ....
- Add precedence list to ignore functions to ignore, for instance, 
  mail from contribs.org mailinglists [SME: 4549]

* Tue Aug 12 2008 Gavin Weight <gweight@gmail.com> 1.0-27
- Fix Locale to read vacation panel correctly. [SME: 4311] 

* Tue Jul 1 2008 Jonathan Martens <smeserver-contribs@snetram.nl> 1.0-26
- Apply 1 July 2008 locale patch

* Mon May 5 2008 Jonathan Martens <smeserver-contribs@snetram.nl> 1.0-25
- Apply 5 May 2008 locale patch

* Mon Apr 28 2008 Shad L. Lords <slords@mail.com> 1.0-24
- Convert dos line endings to unix

* Sat Apr 26 2008 Jonathan Martens <smeserver-contribs@snetram.nl> 1.0-23
- Add common <base> tags to e-smith-formmagick's general

* Tue Apr 22 2008 Jonathan Martens <smeserver-contribs@snetram.nl> 1.0-22
- Apply 22 April 2008 locale patch

* Tue Apr 1 2008 Shad L. Lords <slords@mail.com> 1.0-21
- Update to UTF-8 translations

* Fri Mar 14 2008 Stephen Noble <support@dungog.net> - 1.0-20
- update locale 2008-03-14, removed -13

* Fri Mar 14 2008 Stephen Noble <support@dungog.net> - 1.0-19
- update locale 2008-03-13

* Wed Mar 12 2008 Shad L. Lords <slords@mail.com> - 1.0-18
- Add requires for e-smith-formmagick for UTF-8 support [SME: 3858]

* Tue Mar 11 2008 Stephen Noble <support@dungog.net> - 1.0-17
- remove dud es patch

* Tue Mar 11 2008 Stephen Noble <support@dungog.net> - 1.0-16
- update locale 2008-03-11

* Sat Mar 08 2008 Stephen Noble <support@dungog.net> - 1.0-15
- prepare en lexicons for pootle translations

* Wed Dec 26 2007 Stephen Noble <support@dungog.net> 1.0-14
- fix spanish translation

* Mon Oct 29 2007 Stephen Noble <support@dungog.net> 1.0-13
- add spanish translation, thanks Normando Hall [SME 3503]

* Thu Jun 14 2007 Stephen Noble <support@dungog.net>
- apply updates up to -11

* Sun Apr 29 2007 Shad L. Lords <slords@mail.com>
- Clean up spec so package can be built by koji/plague

* Fri Dec 29 2006  Stephen Noble <support@dungog.net>
- display Vacation status correctly on modify page in server-manager [sme 2200]
- [1.0-11]

* Thu Dec 07 2006 Shad L. Lords <slords@mail.com>
- Update to new release naming.  No functional changes.
- Make Packager generic

* Mon Oct 30 2006  Stephen Noble <support@dungog.net>
- display description unshaded *
- german lexicon fix
- cosmetic log error fixed [sme 1992]
- [1.0-10]

* Thu Aug 24 2006 Stephen Noble <support@dungog.net>
- now finds corrects vacation text when used under userpanel.
- german translation [sme 1101]
- [1.0-9]

* Thu Apr 06 2006 Stephen Noble <support@dungog.net>
  Wed Apr 06 2006 --> Wed Apr 05 2006 or Thu Apr 06 2006 or Wed Apr 12 2006 or ....
- suppress description if no users [contribs 1243]
- [1.0-8]

* Thu Apr 06 2006 Stephen Noble <support@dungog.net>
  Wed Apr 06 2006 --> Wed Apr 05 2006 or Thu Apr 06 2006 or Wed Apr 12 2006 or ....
- say no users if none exist [contribs 1243]
- display DomainName in email address [contribs 1242]
- [1.0-7]

* Thu Apr 06 2006 Stephen Noble <support@dungog.net>
  Wed Apr 06 2006 --> Wed Apr 05 2006 or Thu Apr 06 2006 or Wed Apr 12 2006 or ....
- unlink .vacation.msg before writing [contribs 1192]
- vacation doesn't respond to spam [contribs 1190]
- [1.0-6]

* Sat Mar 25 2006 Stephen Noble <support@dungog.net>
- updated lexicons
- removed event
- [1.0-5]

* Fri Mar 24 2006 Stephen Noble <support@dungog.net>
- Change the interval between repeat replies to the same sender
- config setprop qmail VacationDelay -t3d, man vacation
- reset vacationDB when setting status to no
- modified to, Subject: Re: $SUBJECT - Away from my email
- updated fr lexicon
- [1.0-4]

* Wed Mar 22 2006 Stephen Noble <support@dungog.net>
- updated lexicons
- [1.0-3]

* Wed Mar 22 2006 Stephen Noble <support@dungog.net>
- fr lexicon
- expand ~/.qmail on uninstall
- [1.0-2]

* Mon Mar 20 2006 Stephen Noble <support@dungog.net>
- FormMagick version
- [1.0-1]

* Mon Dec 12 2005 Stephen Noble <support@dungog.net>
- Strip out DOS Carriage Returns (CR)
- thanks to mike sensney
- [0.9-2]

* Sat Sep 03 2005 Stephen Noble <support@dungog.net>
- renamed smeserver-vacation,
- contains vacation & userpanel-vacation
- [0.9-1]

* Sat Sep 03 2005 David Beveridge <davidb@nass.com.au>
- [0.3-2]
- upgrade to work with AccountsDB on SME 7.0

* Mon Dec 31 2001 Daniel van Raay <danielvr@caa.org.au>
- [0.2-4]
- Added generated 'From:' lines to default reply message
- Minor cosmetic cleaning

* Fri Nov 23 2001 Daniel van Raay <danielvr@caa.org.au>
- [0.2-3]
- .vacation.db files are now deleted in the user-modify event

* Wed Nov 14 2001 Daniel van Raay <danielvr@caa.org.au>
  Tue Nov 14 2001 --> Tue Nov 13 2001 or Wed Nov 14 2001 or Tue Nov 20 2001 or ....
- [0.2-2]
- fixed bug in vacation script that delivered multiple bounces to users

* Tue Sep 04 2001 Daniel van Raay <danielvr@caa.org.au>
- [0.2-1]
- added -j option to vacation command line
- updated for compatibility with e-smith 4.1

* Wed Dec 27 2000 Daniel van Raay <danielvr@caa.org.au>
- [0.1-1]
- initial release

%prep
%setup

%build
perl createlinks

LEXICONS=$(find root/etc/e-smith/{locale/,web/functions/} -type f )
for lexicon in $LEXICONS
do
    /sbin/e-smith/validate-lexicon $lexicon
done

LINKS=$(find root/etc/e-smith/locale/ -type d -maxdepth 1 | sed 's/root\/etc\/e-smith\/locale\///')
for link in $LINKS
do
 /bin/ln -s uservacations root/etc/e-smith/locale/$link/etc/e-smith/web/functions/userpanel-vacation
done

%install
rm -rf $RPM_BUILD_ROOT
(cd root   ; find . -depth -print | cpio -dump $RPM_BUILD_ROOT)
rm -f %{name}-%{version}-filelist
/sbin/e-smith/genfilelist $RPM_BUILD_ROOT \
     --file '/usr/local/bin/vacation' 'attr(0755,root,root)' \
     --file '/sbin/e-smith/vacation/check_vacation_dates.sh' 'attr(0755,root,root)' \
     > %{name}-%{version}-filelist
echo "%doc COPYING"  >> %{name}-%{version}-filelist

%clean
rm -rf $RPM_BUILD_ROOT

%pre
%preun

%post
if [ -d /etc/e-smith/events/conf-userpanel ] ; then
   /sbin/e-smith/signal-event conf-userpanel
fi

if (systemctl list-unit-files |grep smanager) then
  echo "Smanager restart in spec file"
  /sbin/e-smith/signal-event smanager-refresh;
fi

%postun
#uninstall
if [ $1 = 0 ] ; then

 DBS=`find /home/e-smith/db/navigation -type f -name "navigation.*"`
 for db in $DBS ; do
          /sbin/e-smith/db $db delete userpanel-vacation 2>/dev/null
          /sbin/e-smith/db $db delete uservacations 2>/dev/null
	done
	
 #need to expand ~/.qmail for users who are still enabled
 /etc/e-smith/events/actions/qmail-update-user

fi


%files -f %{name}-%{version}-filelist
%defattr(-,root,root)
