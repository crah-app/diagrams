use v6;

# Directory Generator From PlantUML WBS Diagram
#
# This script generates the project structure from the `api.puml` PlantUML WBS diagram.
# Running this script after a change in the `api.puml` diagram will:
# - Not delete objects' and methods' folders or diagrams' files that have been removed from the `api.puml` diagrams
#	so you can't lose your work running this script.
# - Create objects' and methods' folders or diagrams' files that don't yet exist.

sub lcfirst($s) {
    return lc($s.substr(0, 1)) ~ $s.substr(1);
}

# Opens the PlantUML diagram file passed as argument
my $API = open 'api.puml', :r or die "Could not open file: $!";
my @API = $API.lines;

# Stores the last object name e.g Tricks
my $lastObject;
# Stores the id of the last endpoint e.g :trickId
my $lastEndpointId;
# Stores the last method e.g PUT
my $lastMethod;

# Fallback theme
my $theme = "toy";

for @API -> $line {
	if ($line ~~ rx/(\*+)\s+(\w+)\s*\/?(\w+)?\/?(\w+)?\/?(\:?\w+)?\/?(\w+)?/) {
		given $0.chars {

			# This is an object
			# e.g Posts, Likes
			when 2 {
				$lastObject = $1;

				my $path = "$*CWD/$lastObject";
				unless $path.IO.d {
					mkdir $path;
				}

				$lastEndpointId = "";
				$lastMethod = "";
			}

			# This is an endpoint
			# e.g Endpoint /api/posts, Endpoint /api/users
			when 3 {
				$lastEndpointId = "";
				$lastMethod = "";
			}

			# This is either a subordinated endpoint or a method
			# e.g Endpoint /api/posts/:postId, GET, PUT
			when 4 {
				if $4 ne "" {
					$lastEndpointId = $4;

					my $path = "$*CWD/$lastObject/$lastEndpointId";
					unless $path.IO.d {
						mkdir $path;
					}
				} else {
					$lastMethod = $1;

					my $path = "$*CWD/$lastObject/$lastMethod";
					unless $path.IO.d {
						mkdir $path;
					}
				}
			}

			# This is either a usecase or a method
			# e.g createArticle, GET, DELETE
			when 5 {
				if $lastEndpointId ne "" {
					my $path;

					# This is a sub-sub endpoint
					# e.g /api/posts/:postId/streamVideo
					if $5 ne "" {
						$lastEndpointId = $lastEndpointId ~ "/$5";
						$path = "$*CWD/$lastObject/$lastEndpointId";
					} else {
						$lastMethod = $1;
						$path = "$*CWD/$lastObject/$lastEndpointId/$lastMethod";
					}

					unless $path.IO.d {
						mkdir $path;
					}
				} else {
					my $path = "$*CWD/$lastObject/$lastMethod/{@(lcfirst($1))}.puml";
					unless $path.IO.e {
						my $uc = open $path, :w;
						$uc.say("@startuml {@(lcfirst($1))}-Request");
						$uc.say("!theme $theme");
						$uc.say("title \"{@(lcfirst($1))} /api/{@(lcfirst($lastObject))} $lastMethod Request\"");
						$uc.say('@enduml');
						$uc.say("@startuml {@(lcfirst($1))}-Response");
						$uc.say("!theme $theme");
						$uc.say("title \"{@(lcfirst($1))} /api/{@(lcfirst($lastObject))} $lastMethod Response\"");
						$uc.say('@enduml');
						$uc.close;
					}
				}
			}

			# This is a usecase or a sub-method
			# e.g createArticle, GET, PUT
			when 6 {
				# this is a method
				if $1 eq uc($1) {
					$lastMethod = $1;
					my $path = "$*CWD/$lastObject/$lastEndpointId/$lastMethod";
					unless $path.IO.d {
						mkdir $path;
					}
				} else {
					my $path = "$*CWD/$lastObject/$lastEndpointId/$lastMethod/{@(lcfirst($1))}.puml";
					unless $path.IO.e {
						my $uc = open $path, :w;
						$uc.say("@startuml {@(lcfirst($1))}-Request");
						$uc.say("!theme $theme");
						$uc.say("title \"{@(lcfirst($1))} /api/{@(lcfirst($lastObject))}/$lastEndpointId $lastMethod Request\"");
						$uc.say('@enduml');
						$uc.say("@startuml {@(lcfirst($1))}-Response");
						$uc.say("!theme $theme");
						$uc.say("title \"{@(lcfirst($1))} /api/{@(lcfirst($lastObject))}/$lastEndpointId $lastMethod Response\"");
						$uc.say('@enduml');
						$uc.close;
					}
				}
			}
			
			# This is a sub usecase
			# e.g streamVideo
			when 7 {
				my $path = "$*CWD/$lastObject/$lastEndpointId/$lastMethod/{@(lcfirst($1))}.puml";
				unless $path.IO.e {
					my $uc = open $path, :w;
					$uc.say("@startuml {@(lcfirst($1))}-Request");
					$uc.say("!theme $theme");
					$uc.say("title \"{@(lcfirst($1))} /api/{@(lcfirst($lastObject))}/$lastEndpointId $lastMethod Request\"");
					$uc.say('@enduml');
					$uc.say("@startuml {@(lcfirst($1))}-Response");
					$uc.say("!theme $theme");
					$uc.say("title \"{@(lcfirst($1))} /api/{@(lcfirst($lastObject))}/$lastEndpointId $lastMethod Response\"");
					$uc.say('@enduml');
					$uc.close;
				}
			}
		}
	} else {
		if $line ~~ rx/\!theme\s+($)/ {
			$theme = $0;
		}
	}
}

$API.close;

