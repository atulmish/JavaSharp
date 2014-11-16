# JavaSharp, a free Java to C# translator based on ANTLRv4
# Copyright (C) 2014  Philip van Oosten
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# https://github.com/pvoosten

function Download-File($Url, $File){
    $webclient = New-Object System.Net.WebClient
    $webclient.DownloadFile($Url,$File)
}

function Prepare-JavaParser{
    
    # Create directories
    mkdir "lib"
    mkdir "parser"
    $grammarFile = "Java.g4"
    $antlrJarFile = "antlr-4.3-complete.jar"

    # Download the Java 7 grammar file. (BSD license)
    Download-File "https://raw.githubusercontent.com/antlr/grammars-v4/master/java/Java.g4" $grammarFile
    # Download ANTLRv4 to create the parser
    Download-File "http://www.antlr.org/download/$antlrJarFile" $antlrJarFile
    
    # Add Antlr to Java Class Path
    $Env:classpath=".;lib\$antlrJarFile;$Env:classpath"
    
    # Generate parser
    del -Recurse parser
    mkdir parser
    java org.antlr.v4.Tool -package javasharp -visitor -o parser\javasharp Java.g4
    
    # And the rest is for a Java IDE with a little Maven bolted into its nuts
    
}

function grun{
    java 
}