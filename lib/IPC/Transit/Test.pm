package IPC::Transit::Test;

use strict;use warnings;
use Data::Dumper;
use IPC::Transit;

BEGIN {
    $IPC::Transit::config_dir = '/tmp/ipc_transit_test';
    $IPC::Transit::config_file = "transit_test_$$.conf";
    $IPC::Transit::test_qname = 'tr_perl_dist_test_qname';
    $IPC::Transit::test_qname1 = 'tr_perl_dist_test_qname1';
    $IPC::Transit::test_qname2 = 'tr_perl_dist_test_qname2';
};

sub clear_test_queue {
    for(1..100) {
        my $m;
        eval {
            $m = IPC::Transit::receive(qname => $IPC::Transit::test_qname, nonblock => 1);
        };
        last if $m;
    }
}

sub run_daemon {
    my $prog = shift;
    my $pid = fork;
    die "run_daemon: fork failed: $!" if not defined $pid;
    if(not $pid) { #child
        exec "perl -Ilib bin/$prog -P/tmp/ipc_transit_test";
        exit;
    }
    return $pid;
}

sub kill_daemon {
    my $pid = shift;
    return kill 9, $pid;
}


END {
    IPC::Transit::Internal::_drop_all_queues();
};

1;

__END__

=head1 NAME

=head1 SYNOPSIS

IPC::Transit::Internal - Internal routines for IPC::Transit

=head1 Internal

=head2 clear_test_queue()

Prepare/clear test queue

=head2 run_daemon()/kill_daemon()

Start/stop IPC::Transit daemon

=head1 COPYRIGHT

Copyright (c) 2012, Dana M. Diederich. All Rights Reserved.

=head1 LICENSE

This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html)

=head1 AUTHOR

Dana M. Diederich <diederich@gmail.com>

=cut
