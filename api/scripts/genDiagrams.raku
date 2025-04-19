use v6;

# Generate All PlantUML Diagrams
#
# This script generates all the diagrams in svg format
# from the /src folder. Because it can take minutes to generate
# all these diagrams, in case an error occurs, you can resume
# the process from where it left. 
# 
# To do so, run with the `resume` argument like so:
#
# $ rakudo scripts/genDiagrams.raku resume
#
# From /

my $currentPumlPath = '';

constant $resumeTxtPath = '.resumeDiagramsGen.txt';
constant $exportDir = 'dist';

our $resumed = False;
my $lastPuml;

# Handle Ctrl+C and save the resume point
signal(SIGINT).tap(-> $ {
    say "\n You can resume from here ...";
    if $currentPumlPath.defined {
        spurt $resumeTxtPath, $currentPumlPath;
    }
    exit;
});

if (@*ARGS[0] // "") eq "resume" {
    unless $resumeTxtPath.IO.e {
        say "No resumable point detected. Run without the `resume` arg.";
        say "Exiting ...";
        exit;
    } 
    my $fh = open $resumeTxtPath, :r;
    $lastPuml = $fh.get;
    $fh.close;
}

for 'src' {
    if !.Str.IO.d && .Str ~~ /.puml/ { 

        my $isWBS = .Str ~~ /api.puml$/;

        if (@*ARGS[0] // "") eq "resume" && !$resumed {
            if $lastPuml eq .Str {
                $resumed = True;
                say "Resuming ...";
            }
        } else {

            my $outputDir = .Str.IO.dirname.subst(/src/, $exportDir);

            my $proc = Proc::Async.new(:w, 'java', '-DPLANTUML_LIMIT_SIZE=8192', '-jar', 'plantuml.jar', '-svg', .Str);
            my $out = await $proc.start;

            if $out.exitcode eq 0 {
                # Creates the folder structure in the dist folder
                mkdir $outputDir;

                # Moves the diagrams that have just been generated to the dist directory
                if $isWBS {
                    shell "mv {.Str.subst(/\.puml$/, '.svg')} $outputDir";
                } else {
                    shell "mv {.Str.subst(/\.puml$/, '-Response.svg')} $outputDir";
                    shell "mv {.Str.subst(/\.puml$/, '-Request.svg')} $outputDir";
                }
                
                # Logs the successfull generation of the diagram
                say .Str ~ " ✅";

                # Updates the latest successful path
                $currentPumlPath = .Str;
            } else {
                # Logs that an error has occurred
                say .Str ~ " ❌";
                my $resume = open $resumeTxtPath, :w;

                # Stores the previous successful path
                # Because the current one would get skipped at resume
                $resume.say($currentPumlPath);
                $resume.close();
                say "Exiting ...";
                exit;
            }
        }
	}
    .IO.dir()».&?BLOCK if .IO.d;
}

# Deletes the resume file when all diagrams have been generated
unlink $resumeTxtPath;
