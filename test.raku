#!/usr/bin/env raku

use v6.d;

$*OUT.out-buffer = False;

%*ENV<AUTHOR_TESTING> = 1;

chdir $*PROGRAM.parent;

my $jobs = max(2, ($*KERNEL.cpu-cores // 2) - 2);

my @stages = (
  { :name<prove6>, :cmd['prove6', "-j$jobs", '-Ilib', 't'] },
  { :name<behave>, :cmd['behave', '--parallel', $jobs.Str]  },
);

my $only = @*ARGS[0];

my @run-stages = $only ?? @stages.grep({ .<name> eq $only }).list !! @stages;

if $only && !@run-stages {
  note "Unknown stage '$only'. Valid stages: {@stages.map(*.<name>).join(', ')}";
  exit 2;
}

my %durations;
my $total-start = now;

sub format-ts(--> Str) {
  my $d = DateTime.now;
  sprintf '%04d-%02d-%02d %02d:%02d:%02d',
  $d.year, $d.month, $d.day,
  $d.hour, $d.minute, $d.second.Int;
}

END {
  if %durations {
    say '';
    say '==> Runtimes';
    for @run-stages -> $stage {
      next unless %durations{$stage<name>}:exists;
      printf "  %-9s %7.2fs\n", $stage<name>, %durations{$stage<name>};
    }
    printf "  %-9s %7.2fs\n", 'total', (now - $total-start).Num;
  }
}

for @run-stages -> $stage {
  my @cmd = $stage<cmd>.list;

  say "==> [{format-ts()}] @cmd.join(' ')";

  my $start = now;
  my $proc = run(|@cmd);

  %durations{$stage<name>} = (now - $start).Num;

  exit $proc.exitcode unless $proc.exitcode == 0;

  say '';
}
