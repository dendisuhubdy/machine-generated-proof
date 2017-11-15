#!/usr/bin/perl -w

=head1 NAME

runepar.pl (Script running special large-theory E strategies)

=head1 SYNOPSIS

runepar.pl timelimit sine file [doproof serial cleanup]

=head1 DESCRIPTION

parallelizes (or serializes) E with different (now hardwired) large-theory strategies, 
possibly calling --sine=Auto 

=head1 CONTACT

Josef Urban (firstname dot lastname at gmail dot com)

=head1 COPYRIGHT

Copyright (C) 2012-2013 Josef Urban (firstname dot lastname at gmail dot com)

=head1 LICENCE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

=cut



use strict;
my $tl = shift @ARGV;
my $sine = shift @ARGV; # 0 or 1
my $file = shift @ARGV;
my $doproof = shift @ARGV; # 0, 1, 2 or nothing (which means 1); 2 means proofs go to stdout too
my $serial = shift @ARGV; # 0, 1 or nothing (which means 0 - run in parallel)
my $cleanup = shift @ARGV; # 0, 1 or nothing (which means 1 - do cleanup)

$doproof = 1 unless(defined($doproof));
$serial = 0 unless(defined($serial));
$cleanup = 1 unless(defined($cleanup));

die "runepar.pl takes at least three paramaters: timelimit dosine inputfile" unless((defined $tl) && (defined $sine) && (defined $file));

my $tl1 = 1 + $tl;

my @strats;  # the strategies used, now set to @mizstratsold

# mizstratsold without four (protokoll_X----_sauto_300 ,
# protokoll_my14simple, protokoll_my16simple, protokoll_my22simple)
my @mizstrats1 =
(
'protokoll_G-E--_008_K18_F1_PI_AE_CS_SP_S0Y',
'protokoll_G-E--_107_C37_F1_PI_AE_Q4_CS_SP_PS_S0Y',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S_sine05',
# 'protokoll_my14simple',
# 'protokoll_my16simple',
'protokoll_my18simple',
# 'protokoll_my22simple',
'protokoll_my21simple',
'protokoll_my24simple',
'protokoll_my8simple_sine13',
'protokoll_my11simple_sine13',
'protokoll_my1_SOS',
'protokoll_my13simple',
'protokoll_X----_auto_sine03',
# 'protokoll_X----_sauto_300',
'protokoll_my23simple'
);

my @greedymizstrats =
(
 'protokoll_my21simple',
 'protokoll_my14simple',
 'protokoll_G-E--_107_C37_F1_PI_AE_Q4_CS_SP_PS_S0Y',
 'protokoll_my8simple_sine13',
 'protokoll_my18simple',
 'protokoll_G-E--_008_K18_F1_PI_AE_CS_SP_S0Y',
 'protokoll_my16simple',
 'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S_sine05',
 'protokoll_X----_sauto_300',
 'protokoll_X----_auto_sine03',
 'protokoll_my23simple',
 'protokoll_my1_SOS',
 'protokoll_my22simple',
 'protokoll_my11simple_sine13'
# 'protokoll_my24simple',
# 'protokoll_my13simple'
);


# we only run these 16 now (first version for mizar used for casc mzt 12)
# it seems that some are redundant, see above
my @mizstratsold =
(
'protokoll_G-E--_008_K18_F1_PI_AE_CS_SP_S0Y',
'protokoll_G-E--_107_C37_F1_PI_AE_Q4_CS_SP_PS_S0Y',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S_sine05',
'protokoll_my14simple',
'protokoll_my16simple',
'protokoll_my18simple',
'protokoll_my22simple',
'protokoll_my21simple',
'protokoll_my24simple',
'protokoll_my8simple_sine13',
'protokoll_my11simple_sine13',
'protokoll_my1_SOS',
'protokoll_my13simple',
'protokoll_X----_auto_sine03',
'protokoll_X----_sauto_300',
'protokoll_my23simple'
);

# the E strategies before CliStr growing, inlcuding the six covering MZT training problems
my @origEStrats =
(
'protokoll_G-E--_008_K18_F1_PI_AE_CS_SP_S0Y',
'protokoll_G-E--_107_C37_F1_PI_AE_Q4_CS_SP_PS_S0Y',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S_sine05',
'protokoll_G-E--_008_B31_F1_PI_AE_S4_CS_SP_S2S',
'protokoll_G-E--_010_B02_F1_PI_AE_S4_CS_SP_S0Y',
'protokoll_G-E--_045_B31_F1_PI_AE_S4_CS_SP_S0Y',
'protokoll_G-E--_024_B07_F1_PI_AE_Q4_CS_SP_S0Y',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S', 
'protokoll_X----_auto_sine03',
'protokoll_X----_sauto_300',
'protokoll_X----_auto_sine05',
'protokoll_G-E--_107_C37_F1_PI_AE_Q4_CS_SP_PS_S0Y_sine13',
'protokoll_G-E--_052_K18_F1_PI_AE_Q4_CS_SP_S0Y',
'protokoll_G-E--_092_C01_F1_PI_AE_Q4_CS_SP_PS_S0Y',
'protokoll_G-E--_008_C18_F1_PI_AE_Q4_CS_SP_PS_S0Y',
'protokoll_G-E--_008_B07_F1_PI_AE_Q4_CS_SP_S2S'
);

# only those from which strats could be grown, plus auto
my @strictorigEStrats =
(
'protokoll_G-E--_008_K18_F1_PI_AE_CS_SP_S0Y',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S_sine05',
'protokoll_G-E--_008_B31_F1_PI_AE_S4_CS_SP_S2S',
'protokoll_G-E--_010_B02_F1_PI_AE_S4_CS_SP_S0Y',
'protokoll_G-E--_045_B31_F1_PI_AE_S4_CS_SP_S0Y',
'protokoll_G-E--_024_B07_F1_PI_AE_Q4_CS_SP_S0Y',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S', 
'protokoll_X----_auto_sine03',
'protokoll_X----_sauto_300',
'protokoll_X----_auto_sine05',
);

my @EAutoStrat =
(
'protokoll_X----_sauto_300'
);





@strats = @mizstratsold;


# possible SZS statuses
sub szs_INIT        ()  { 'Initial' } # system was not run on the problem yet
sub szs_UNKNOWN     ()  { 'Unknown' } # used when system dies
sub szs_THEOREM     ()  { 'Theorem' }
sub szs_COUNTERSAT  ()  { 'CounterSatisfiable' }
sub szs_RESOUT      ()  { 'ResourceOut' }
sub szs_GAVEUP      ()  { 'GaveUp' }   # system exited before the time limit for unknown reason

# add --sine=Auto to these when $sine=1
#
my @nsine = (
'protokoll_G-E--_008_K18_F1_PI_AE_CS_SP_S0Y',
'protokoll_G-E--_107_C37_F1_PI_AE_Q4_CS_SP_PS_S0Y',
'protokoll_my10simple',
'protokoll_my11simple',
'protokoll_my12simple',
'protokoll_my13simple',
'protokoll_my14simple',
'protokoll_my15simple',
'protokoll_my16simple',
'protokoll_my17simple',
'protokoll_my18simple',
'protokoll_my19simple',
'protokoll_my1KBO_SOS',
'protokoll_my1_SOS',
'protokoll_my20simple',
'protokoll_my21simple',
'protokoll_my22simple',
'protokoll_my23simple',
'protokoll_my24simple',
'protokoll_my25simple',
'protokoll_my2simple',
'protokoll_my3simple',
'protokoll_my4simple',
'protokoll_my5simple',
'protokoll_my6simple',
'protokoll_my7simple',
'protokoll_my8simple',
'protokoll_my9simple',
'protokoll_G-E--_008_B31_F1_PI_AE_S4_CS_SP_S2S',
'protokoll_G-E--_010_B02_F1_PI_AE_S4_CS_SP_S0Y',
'protokoll_G-E--_045_B31_F1_PI_AE_S4_CS_SP_S0Y',
'protokoll_G-E--_024_B07_F1_PI_AE_Q4_CS_SP_S0Y',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S',
'protokoll_G-E--_052_K18_F1_PI_AE_Q4_CS_SP_S0Y',
'protokoll_G-E--_092_C01_F1_PI_AE_Q4_CS_SP_PS_S0Y',
'protokoll_G-E--_008_C18_F1_PI_AE_Q4_CS_SP_PS_S0Y',
'protokoll_G-E--_008_B07_F1_PI_AE_Q4_CS_SP_S2S'
);

# do not add --sine=Auto to these
my @wsine =
(
'protokoll_X----_sauto_300',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S_sine05',
'protokoll_X----_auto_sine03',
'protokoll_X----_auto_sine05',
'protokoll_X----_auto_sine13',
'protokoll_my11simple_sine13',
'protokoll_my17simple_sine13',
'protokoll_my8simple_sine13',
'protokoll_G-E--_107_C37_F1_PI_AE_Q4_CS_SP_PS_S0Y_sine13'
);

my %wsinestr = ();
my %nsinestr = ();

@wsinestr{@wsine} = ();
@nsinestr{@nsine} = ();

# strategy defs
my %sdef =
(
'protokoll_G-E--_008_K18_F1_PI_AE_CS_SP_S0Y' => '  --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(10*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*FIFOWeight(ConstPrio))\' ',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S_sine05' => '  --sine=gf120_gu_RUU_F100_L00100 --oriented-simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(4*Refinedweight(SimulateSOS,1,1,2,1.5,2),3*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),1*Clauseweight(PreferProcessed,1,1,1),1*FIFOWeight(PreferProcessed))\' ',
'protokoll_G-E--_107_C37_F1_PI_AE_Q4_CS_SP_PS_S0Y' => '  --definitional-cnf=24 --split-clauses=4 --split-reuse-defs --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --presat-simplify --prefer-initial-clauses -tKBO6 -warity -c1 -Ginvconjfreq -F1  --delete-bad-limit=1024000000 -WSelectMaxLComplexAvoidPosPred -H\'(4*RelevanceLevelWeight2(SimulateSOS,0,2,1,2,100,100,100,400,1.5,1.5,1),3*ConjectureGeneralSymbolWeight(PreferNonGoals,200,100,200,50,50,1,100,1.5,1.5,1),1*Clauseweight(PreferProcessed,1,1,1),1*FIFOWeight(PreferProcessed))\'  ',
'protokoll_X----_auto_sine03' => '  --delete-bad-limit=1024000000 -xAuto -tAuto --sine=gf120_gu_R02_F100_L20000 ',
'protokoll_X----_auto_sine05' => '  --delete-bad-limit=1024000000 -xAuto -tAuto --sine=gf120_gu_RUU_F100_L00100 ',
'protokoll_X----_auto_sine13' => '   --delete-bad-limit=1024000000 -xAuto -tAuto --sine=gf120_h_gu_R02_F100_L20000 ',
'protokoll_X----_sauto_300' => '   --delete-bad-limit=1024000000 --auto ',
'protokoll_my10simple' => '  --definitional-cnf=24 --split-clauses=7 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(2*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*FIFOWeight(PreferProcessed),1*FIFOWeight(ConstPrio))\'  ',
'protokoll_my11simple' => '  --definitional-cnf=24 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tKBO -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*FIFOWeight(PreferProcessed),2*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*Refinedweight(SimulateSOS,1,1,2,1.5,2),2*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5))\'  ',
'protokoll_my11simple_sine13' => '  --sine=gf120_h_gu_R02_F100_L20000 --definitional-cnf=24 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tKBO -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*FIFOWeight(PreferProcessed),2*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*Refinedweight(SimulateSOS,1,1,2,1.5,2),2*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5))\'  ',
'protokoll_my12simple' => '  --definitional-cnf=24 --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tKBO -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),2*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my13simple' => '  --definitional-cnf=24 --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tAuto -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(6*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),8*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my14simple' => '  --definitional-cnf=24 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Garity -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(6*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*FIFOWeight(PreferProcessed),1*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*FIFOWeight(ConstPrio))\'  ',
'protokoll_my15simple' => '  --definitional-cnf=24 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectNewComplexAHP -H\'(1*Refinedweight(SimulateSOS,1,1,2,1.5,2),6*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),2*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5))\'  ',
'protokoll_my16simple' => '  --definitional-cnf=24 --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(1*FIFOWeight(ConstPrio),1*FIFOWeight(PreferProcessed),1*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5))\'  ',
'protokoll_my17simple' => '  --definitional-cnf=24 --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Garity -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(1*FIFOWeight(ConstPrio),1*FIFOWeight(PreferProcessed),1*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),3*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100,1.5, 1.5, 1),10*Refinedweight(SimulateSOS,1,1,2,1.5,2))\'  ',
'protokoll_my17simple_sine13' => '  --sine=gf120_h_gu_R02_F100_L20000 --definitional-cnf=24 --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Garity -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(1*FIFOWeight(ConstPrio),1*FIFOWeight(PreferProcessed),1*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),3*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100,1.5, 1.5, 1),10*Refinedweight(SimulateSOS,1,1,2,1.5,2))\'  ',
'protokoll_my18simple' => '  --definitional-cnf=24  --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectNewComplexAHP -H\'(1*FIFOWeight(ConstPrio),2*FIFOWeight(PreferProcessed),8*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5))\'  ',
'protokoll_my19simple' => '  --definitional-cnf=24 --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Garity -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(1*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),10*Refinedweight(SimulateSOS,1,1,2,1.5,2),2*FIFOWeight(PreferProcessed),8*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*FIFOWeight(ConstPrio))\' ',
'protokoll_my1KBO_SOS' => '  --definitional-cnf=24  --split-aggressive --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tKBO -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(4*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),10*Refinedweight(SimulateSOS,1,1,2,1.5,2),1*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),1*Clauseweight(PreferProcessed,1,1,1),2*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my1_SOS' => '  --definitional-cnf=24  --split-aggressive --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(4*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),10*Refinedweight(SimulateSOS,1,1,2,1.5,2),1*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),1*Clauseweight(PreferProcessed,1,1,1),2*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my20simple' => '  --definitional-cnf=24  --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tKBO -Garity -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*Refinedweight(SimulateSOS,1,1,2,1.5,2),1*FIFOWeight(ConstPrio),10*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5))\'  ',
'protokoll_my21simple' => '  --definitional-cnf=24 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*FIFOWeight(ConstPrio),2*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),2*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my22simple' => '  --definitional-cnf=24  --split-clauses=7 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tAuto -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(1*FIFOWeight(ConstPrio),6*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),8*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),2*FIFOWeight(PreferProcessed),1*Refinedweight(SimulateSOS,1,1,2,1.5,2))\'  ',
'protokoll_my23simple' => '  --definitional-cnf=24  --split-aggressive --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Garity -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(1*FIFOWeight(PreferProcessed),10*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5))\'  ',
'protokoll_my24simple' => '  --definitional-cnf=24  --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Garity -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(1*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),6*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),2*FIFOWeight(PreferProcessed),1*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),8*Refinedweight(SimulateSOS,1,1,2,1.5,2))\'  ',
'protokoll_my25simple' => '  --definitional-cnf=24  --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tKBO -Garity -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(2*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),2*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),2*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),2*FIFOWeight(PreferProcessed),1*FIFOWeight(ConstPrio))\'  ',
'protokoll_my2simple' => ' --definitional-cnf=24  --split-aggressive --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*Clauseweight(PreferProcessed,1,1,1),2*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my3simple' => ' --definitional-cnf=24 --split-aggressive --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Garity -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*Clauseweight(PreferProcessed,1,1,1),2*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my4simple' => ' --definitional-cnf=24 --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tAuto -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(6*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*FIFOWeight(ConstPrio),1*FIFOWeight(PreferProcessed),1*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1))\'  ',
'protokoll_my5simple' => '  --definitional-cnf=24  --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tKBO -Garity -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*FIFOWeight(ConstPrio),8*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),2*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my6simple' => '  --definitional-cnf=24  --split-clauses=7 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*FIFOWeight(ConstPrio),2*FIFOWeight(PreferProcessed),1*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5))\'  ',
'protokoll_my7simple' => '  --definitional-cnf=24 --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*FIFOWeight(PreferProcessed),1*FIFOWeight(ConstPrio),2*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5))\'  ',
'protokoll_my8simple' => '  --definitional-cnf=24 --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tKBO -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*FIFOWeight(ConstPrio),4*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),2*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my8simple_sine13' => '  --sine=gf120_h_gu_R02_F100_L20000 --definitional-cnf=24 --split-aggressive --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tKBO -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(1*FIFOWeight(ConstPrio),4*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),2*FIFOWeight(PreferProcessed))\'  ',
'protokoll_my9simple' => '  --definitional-cnf=24 --split-aggressive --split-clauses=7 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tAuto -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(6*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*FIFOWeight(ConstPrio),2*Refinedweight(SimulateSOS,1,1,2,1.5,2),2*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),2*FIFOWeight(PreferProcessed),10*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),3*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1))\' ',
'protokoll_G-E--_008_B31_F1_PI_AE_S4_CS_SP_S2S' => '  --split-aggressive --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectNewComplexAHP -H\'(10*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*FIFOWeight(ConstPrio))\' ',
'protokoll_G-E--_010_B02_F1_PI_AE_S4_CS_SP_S0Y' => '  --split-aggressive --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Garity -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(4*ConjectureRelativeSymbolWeight(SimulateSOS,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),3*ConjectureRelativeSymbolWeight(PreferNonGoals,0.5, 100, 100, 100, 100, 1.5, 1.5, 1),1*Clauseweight(PreferProcessed,1,1,1),1*FIFOWeight(PreferProcessed))\' ',
'protokoll_G-E--_045_B31_F1_PI_AE_S4_CS_SP_S0Y' => '  --split-aggressive --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreqconstmin -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(4*Refinedweight(SimulateSOS,1,1,2,1.5,2),3*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),1*Clauseweight(PreferProcessed,1,1,1),1*FIFOWeight(PreferProcessed))\' ',
'protokoll_G-E--_024_B07_F1_PI_AE_Q4_CS_SP_S0Y' => '  --split-reuse-defs --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(4*ConjectureGeneralSymbolWeight(SimulateSOS,100,100,100,50,50,50,50,1.5,1.5,1),3*ConjectureGeneralSymbolWeight(PreferNonGoals,100,100,100,50,50,1000,100,1.5,1.5,1),1*Clauseweight(PreferProcessed,1,1,1),1*FIFOWeight(PreferProcessed))\' ',
'protokoll_G-E--_045_K18_F1_PI_AE_CS_OS_S0S' => '  --oriented-simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectComplexG -H\'(4*Refinedweight(SimulateSOS,1,1,2,1.5,2),3*Refinedweight(PreferNonGoals,1,1,2,1.5,1.5),1*Clauseweight(PreferProcessed,1,1,1),1*FIFOWeight(PreferProcessed))\' ',
'protokoll_G-E--_107_C37_F1_PI_AE_Q4_CS_SP_PS_S0Y_sine13' => '  --sine=gf120_h_gu_R02_F100_L20000 --split-clauses=4 --split-reuse-defs --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --presat-simplify --prefer-initial-clauses -tKBO6 -warity -c1 -Ginvconjfreq -F1 -s --delete-bad-limit=1024000000 -WSelectMaxLComplexAvoidPosPred -H\'(4*RelevanceLevelWeight2(SimulateSOS,0,2,1,2,100,100,100,400,1.5,1.5,1),3*ConjectureGeneralSymbolWeight(PreferNonGoals,200,100,200,50,50,1,100,1.5,1.5,1),1*Clauseweight(PreferProcessed,1,1,1),1*FIFOWeight(PreferProcessed))\' ', 
'protokoll_G-E--_052_K18_F1_PI_AE_Q4_CS_SP_S0Y' => '  --split-reuse-defs --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -winvfreqrank -c1 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectMaxLComplexAvoidPosPred -H\'(10*ConjectureRelativeSymbolWeight(ConstPrio,0.05, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*FIFOWeight(SimulateSOS))\' ',
'protokoll_G-E--_092_C01_F1_PI_AE_Q4_CS_SP_PS_S0Y' => '  --definitional-cnf=24 --tstp-in --presat-simplify --split-clauses=4 --split-reuse-defs --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -F1 -s --delete-bad-limit=1024000000 -WSelectMaxLComplexAvoidPosPred -tKBO6 -H\'(4*RelevanceLevelWeight2(SimulateSOS,1,2,0,2,100,100,100,400,1.5,1.5,1),3*ConjectureGeneralSymbolWeight(PreferNonGoals,200,100,200,50,50,1,100,1.5,1.5,1),1*Clauseweight(PreferProcessed,1,1,1),1*FIFOWeight(PreferProcessed))\' ',
'protokoll_G-E--_008_C18_F1_PI_AE_Q4_CS_SP_PS_S0Y' => '  --definitional-cnf=24 --split-reuse-defs --split-clauses=4 --tstp-in --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er  --presat-simplify --prefer-initial-clauses -tKBO6 -winvfreqrank -c1 -Ginvfreq -F1 -s --delete-bad-limit=1024000000 -WSelectMaxLComplexAvoidPosPred -H\'(10*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*FIFOWeight(ConstPrio))\' ',
'protokoll_G-E--_008_B07_F1_PI_AE_Q4_CS_SP_S2S' => '  --split-reuse-defs --split-clauses=4 --simul-paramod --forward-context-sr --destructive-er-aggressive --destructive-er --prefer-initial-clauses -tLPO4 -Ginvfreq -F1 --delete-bad-limit=150000000 -WSelectNewComplexAHP -H\'(10*ConjectureRelativeSymbolWeight(ConstPrio,0.1, 100, 100, 100, 100, 1.5, 1.5, 1.5),1*FIFOWeight(ConstPrio))\' '
);


local $SIG{'TERM'} = \&Cleanup;
local $SIG{'INT'} = \&Cleanup;
local $SIG{'XCPU'} = \&Cleanup;

sub Cleanup
{
    if($cleanup == 1)
    {
	foreach my $strat (@strats)
	{
	    unlink("$file.err.$strat");
	    unlink("$file.out.$strat");
	}
	unlink("$file.out1");
    }
}


sub RunStrategyNoProof
{
    my ($strat) = @_;

    my $sinestr = '';
    if(($sine == 1) && exists($nsinestr{$strat})) { $sinestr = ' --sine=Auto '; }
    `ulimit -t $tl1; $ENV{E_HOME}/eprover $sdef{$strat} $sinestr --tstp-format -R -s --cpu-limit=$tl $file 2>$file.err.$strat | grep "\\(User\\|SZS status\\)" >$file.out.$strat`;
}

sub RunStrategyWithProof
{
    my ($strat) = @_;

    my $sinestr = '';
    if(($sine == 1) && exists($nsinestr{$strat})) { $sinestr = ' --sine=Auto '; }
    my $status_line = `ulimit -t 61; $ENV{E_HOME}/eprover $sdef{$strat} $sinestr --cpu-limit=60 --memory-limit=Auto --tstp-in -l4 -o- --pcl-terms-compressed --pcl-compact $file |$ENV{E_HOME}/epclextract --tstp-out -f -C --competition-framing |tee $file.out1 | grep "SZS status" `;

    # if epclextract breaks, add at least the correct status to the proof file
    unless ($status_line=~m/.*SZS status[ :]*(.*)/)
    {
	`echo "# SZS status Theorem" > $file.out1`;
    }

    if(($doproof==2) && ($status_line=~m/.*SZS status[ :]*Theorem/))
    {
	open(F,"$file.out1"); local $/; my $contents= <F>; close(F); print $contents;
    }
}

sub ProcessStrategyOutput
{
    my ($strat) = @_;

    if(open(OUT,"$file.out.$strat"))
    {
	while($_=<OUT>)
	{

	    if (m/.*SZS status[ :]*(.*)/)
	    {
		my $status = $1;

		if ($status eq szs_COUNTERSAT)
		{
		    print '# SZS status ', szs_COUNTERSAT, "\n";
		    Cleanup();
		    exit(0);
		}
		elsif ($status eq szs_THEOREM)
		{
		    print '# SZS status ', szs_THEOREM, "\n";
		    
		    if($doproof > 0)
		    {
			RunStrategyWithProof($strat);
		    }
		    else
		    {
			`echo "# SZS status Theorem" > $file.out1`;
		    }

		    #	    `$ENV{E_HOME}/eproof  $sdef{$strat} $sinestr --cpu-limit=60 --memory-limit=Auto --tstp-format $file > $file.out1`;
		    Cleanup();
		    exit(0);
		}
	    }
	}
	close(OUT);
    }
}

sub min { my ($x,$y) = @_; ($x <= $y)? $x : $y }
sub max { my ($x,$y) = @_; ($x <= $y)? $y : $x }

my $status = szs_UNKNOWN ;

if($serial == 1)
{
    my $oldtl = $tl;
    $tl = max( 1, int( $oldtl/(2+(scalar @greedymizstrats)) ));

    @strats = @greedymizstrats;

    foreach my $strat (@strats)
    {
	RunStrategyNoProof($strat);
	ProcessStrategyOutput($strat);
    }

    print '# SZS status ', $status, "\n"; # only printed if everything failed
    Cleanup();
    exit(0);
}


my @childs = ();
foreach my $strat (@strats)
{

    my $pid = fork();
    if ($pid) 
    {
	# parent
	push(@childs, $pid);
    } 
    elsif ($pid == 0) 
    {
	# child
	RunStrategyNoProof($strat);
	exit(0);
    } 
    else 
    {
	die "couldn’t fork: $!\n";
    }
}

foreach (@childs) { waitpid($_, 0);}


foreach my $strat (@strats)
{
    ProcessStrategyOutput($strat);
}

print '# SZS status ', $status, "\n";
Cleanup();
exit(0);

