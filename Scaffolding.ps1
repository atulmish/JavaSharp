# JavaSharp, a free Java to C# translator based on ANTLRv4
# Copyright (C) 2014-2015  Philip van Oosten
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

## Prepare-JavaParser
# preparation of Java source code to further develop by hand.
function Prepare-JavaParser{
    param([string]$Path)

    # Create directory
    New-Item -ItemType directory -Path $Path

    $grammarFile = "Java.g4"
    $antlrJarFile = "antlr-4.3-complete.jar"

    # Download the Java 7 grammar file. (BSD license)
    $grammarFilePath = $(Join-Path $Path $grammarFile)
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/antlr/grammars-v4/master/java/$grammarFile" -OutFile $grammarFilePath
    # Download ANTLRv4 to create the parser
    $antlrJarPath = $(Join-Path $Path $antlrJarFile)
    Invoke-WebRequest -Uri "http://www.antlr.org/download/$antlrJarFile" -OutFile $antlrJarPath
    
    # Add Antlr to Java Class Path
    $classpath = [string]::Join(';', @('.', $antlrJarPath))
    
    # Generate parser
    $parserDir = $(Join-Path $Path "parser")
    Remove-Item -Path $parserDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType directory -Path $parserDir
    java -classpath $classpath org.antlr.v4.Tool -package javasharp -visitor -o $(Join-Path $parserDir 'javasharp') $grammarFilePath
    
    # And the rest is for a Java IDE with a little Maven bolted into its nuts
    
}
