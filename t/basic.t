#!env perl

use strict;use warnings;

use lib '../lib';
use lib 'lib';
use Test::More tests => 74;
use Test::Exception;

use_ok('IPC::Transit') or exit;
use_ok('IPC::Transit::Test') or exit;

#clean out the queue if there's something in it
IPC::Transit::Test::clear_test_queue();
ok IPC::Transit::send(qname => $IPC::Transit::test_qname, message => { a => 'b' });
ok my $m = IPC::Transit::receive(qname => $IPC::Transit::test_qname, nowait => 1);
ok $m->{a} eq 'b';

for(1..20) {
    ok IPC::Transit::send(qname => $IPC::Transit::test_qname, message => { a => $_ });
}
foreach my $ct (1..20) {
    ok my $m = IPC::Transit::receive(qname => $IPC::Transit::test_qname, nowait => 1);
    ok $m->{a} == $ct;
}

{   #raw
    ok IPC::Transit::send(qname => $IPC::Transit::test_qname, message => { a => 'b' }, serializer => 'json', compression => 'none'), 'send returned true';

    dies_ok {IPC::Transit::send(message => { a => 'b' }, serializer => 'json', compression => 'none')} 'Missing qname';
    dies_ok {IPC::Transit::send(qname => $IPC::Transit::test_qname, serializer => 'json', compression => 'none')} 'Missing message';

    my $qname = 'test_qname';
    my %message = ( a => 'b' );
    dies_ok {IPC::Transit::send(qname => \$qname, message => { a => 'b' }, serializer => 'json', compression => 'none')} 'qname non-scalar';
    dies_ok {IPC::Transit::send(qname => \$qname, message => %message, serializer => 'json', compression => 'none')} 'message non-reference';

    my $ret = IPC::Transit::receive(qname => $IPC::Transit::test_qname, raw => 1, nowait => 1);
    ok $ret, 'receive returned true';
    ok $ret->{message}->{a} eq 'b', 'basic message validation';
    ok $ret->{wire_headers}->{s} eq 'json', 'serialization type preserved';
    ok $ret->{wire_headers}->{c} eq 'none', 'compression type preserved';
}
