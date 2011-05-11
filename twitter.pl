#!/usr/bin/perl

# A perl console based twitter client with timeline viewing, @reply, and DM support
# Uses Net::Twitter and Term::ANSIMenu from CPAN repository for functionality.
# Code is provided as-is

use Net::Twitter;
use Term::ANSIMenu;

# The following 4 values must be retrieved by creating
# a developer account at http://dev.twitter.com

my $consumer_key = "";
my $consumer_secret = "";
my $access_token = "";
my $access_token_secret = "";

$nettwit = Net::Twitter->new(
	traits => [qw/OAuth API::REST/],
	consumer_key		=> $consumer_key,
	consumer_secret		=> $consumer_secret,
	access_token		=> $access_token,
	access_token_secret	=> $access_token_secret,
);

my $menumap = Term::ANSIMenu->new(
	width => 40,
	title => 'Swanky v0.4',
	items => [['1', 'Update Status', \&update_status],
		  ['2', 'Timeline', \&view_status],
		  ['3', 'Mentions', \&view_mentions],
		  ['4', 'Direct Messages', \&view_dm],
		  ['q', 'Exit', undef]
		 ],
	prompt => 'Choose: ');

$menumap->print_menu();
while (my $key = $menumap->read_key()) {
  last unless defined $menumap->do_key($key);
}

sub update_status {
  print "Enter status update: ";
  chomp($status_update = <STDIN>);
  if (!$status_update) {
    print "Status Update is Empty! Try Again!\n";
    update_status();
  } else {
    my $output = $nettwit->update($status_update);
  }
}      

sub view_status {
  my $timelines = $nettwit->friends_timeline({ count => 15 });
  my $count = 0;
  for my $timeline ( @$timelines ) {
    print "--------\n";
    print "\[$count\]$timeline->{created_at} <$timeline->{user}{screen_name}> $timeline->{text}\n";
    $count++;
  }
  print "Enter tweet number to act, leave blank to return to main menu: ";
  my $keypress = <STDIN>;
  if ($keypress ne "\n") {
    print "Tweet: <@$timelines[$keypress]->{user}{screen_name}> @$timelines[$keypress]->{text}\n";
    print "Type \"RT\" to retweet or type \"\@\" to reply: "; 
    chomp(my $option = <STDIN>);
    $option eq uc($option);
    if ($option eq "RT") {
      my $retweet eq $nettwit->retweet({ id => @$timelines[$keypress]->{id} });
      return;
    }
    if ($option eq "\@") {
      chomp($status_update = <STDIN>);
      my $reply = "\@@$timelines[$keypress]->{user}{screen_name} $status_update";
      my $reply_id = @$timelines[$keypress]->{id};
      print "$reply to tweet $reply_id";
      my $output = $nettwit->update({ status => $reply, in_reply_to_status_id => $reply_id });
    }
  }
}

sub view_mentions {
  my $mentions = $nettwit->mentions({ count => 15 });
  my $count = 0;
  for my $mention ( @$mentions ) {
    print "--------\n";
    print "\[$count\]$mention->{created_at} <$mention->{user}{screen_name}> $mention->{text}\n";
    $count++;
  }
  print "Enter tweet number to act, leave blank to return to main menu: ";
  my $keypress = <STDIN>;
  if ($keypress ne "\n") {
    print "Tweet: <@$mentions[$keypress]->{user}{screen_name}> @$mentions[$keypress]->{text}\n";
    print "Type \"RT\" to retweet or type \"\@\" to reply: ";
    chomp(my $option = <STDIN>);
    $option eq uc($option);
    if ($option eq "RT") {
      my $retweet eq $nettwit->retweet({ id => @$mentions[$keypress]->{id} });
      return;
    }
    if ($option eq "\@") {
      chomp($status_update = <STDIN>);
      my $reply = "\@@$mentions[$keypress]->{user}{screen_name} $status_update";
      my $reply_id = @$mentions[$keypress]->{id};
      print "$reply to tweet $reply_id";
      my $output = $nettwit->update({ status => $reply, in_reply_to_status_id => $reply_id });
    }
  }
}


sub view_dm {
  my $dms = $nettwit->direct_messages({ count => 15 });
  my $count = 0;
  for my $dm ( @$dms ) {
    print "--------\n";
    print "\[$count\]$dm->{created_at} <$dm->{sender_screen_name}> $dm->{text}\n";
    $count++;
  }
  print "Press N for New, Enter number to reply, or leave blank and press Enter/Return to return to main menu: ";
  my $keypress = <STDIN>;
  if ($keypress eq "\n") {
    return;
  }
  if ($keypress ne "N") {
    print "Enter text to reply\n";
    chomp($dm_text = <STDIN>);
    my $dm_user = @$dms[$keypress]->{sender_screen_name};
    my $output = $nettwit->new_direct_message({ screen_name => $dm_user, text => $dm_text });
  } 
  if ($keypress eq "N") {
    print "User to DM: ";
    chomp($dm_user = <STDIN>);
    print "Text to DM:\n";
    chomp($dm_text = <STDIN>);
    my $output = $nettwit->new_direct_message({ screen_name => $dm_user, text => $dm_text });
  }
}
