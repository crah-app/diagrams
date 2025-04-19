# Diagrams

[PlantUML](https://plantuml.com/) is one of the most ergonomic tools for creating UML diagrams from text files.

### Getting Started
What you will need is the following
- [JRE](https://www.java.com/en/)
- [Rakudo](#rakudo-installation)
- [PlantUML](#plantuml-installation)

#### Rakudo Installation
To be able to run the scripts you have to install [Rakudo](https://rakudo.org/) first.
It is an implementation of the [Raku](https://raku.org/) programming language, commonly known as Perl 6.

Windows with Scoop
>```
>$ scoop install rakudo-moar
>```
Or download the `.msi` package from https://rakudo.org/downloads

Ubuntu/Debian
>```
>$ sudo apt-get install rakudo
>```

#### PlantUML Installation
To download PlantUML just run the following in the root folder of the repository
>```
>$ rakudo scripts/getPlantUML.raku
>```
> `plantuml.jar` should appear

### Generating Diagrams

The following script will generate all the diagrams in the repository
>```
>$ rakudo scripts/genDiagrams.raku
>```

If an error occurs the script will exit, you can then correct the `.puml` file, and resume from where it failed by running:

>```
>$ rakudo scripts/genDiagrams.raku resume
>```

### During Development

If you were to add new endpoints, methods or usecases, you can 
generate the missing directories and files with the following command
>```
>$ rakudo scripts/genDirectories.raku
>```
