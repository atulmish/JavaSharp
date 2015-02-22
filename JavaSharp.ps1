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

# This is the framework

function Find-JavaFiles{
    param([string]$Path)
    Get-ChildItem -Path $Path -Recurse | where {$_.Name.EndsWith('.java')} | select FullName
}

function Parse-JavaSource{
    param([string]$InputObject)
    $JavaFile = $InputObject
    $tempFile = [System.IO.Path]::GetTempFileName()
    java -classpath "$PSScriptRoot\JavaSharp\target\JavaSharp-0.1.jar;$PSScriptRoot\lib\antlr-4.3-complete.jar" javasharp.Tool $JavaFile $tempFile
    [xml]$content = Get-Content -Raw $tempFile
    Remove-Item $tempFile -ErrorAction SilentlyContinue
    $content
}

function Text{
    param($txt)
    $input + """$txt"
}

function Element{
    param($name)
    $input + "<$name"
}

function Indent{
    $cs = $input
    if($cs -and $cs[-1] -is [bool] -and !$cs[-1]){
        # indent eats dedent
        $cs[0..($cs.Length-2)]
    }else{
        $cs + $true
    }
}

function Dedent{
    $cs = $input
    if($cs -and $cs[-1] -is [bool] -and !$cs[-1]){
        # dedent eats indent
        $cs[0..($cs.Length-2)]
    }else{
        $cs + $false
    }
}

function Process-ChildNodes($processors, $astNode){
    for($i=0; $i -lt $astNode.ChildNodes.Count; $i++){
        $childNode = $astNode.ChildNodes[$i]
        if($childNode.NodeType -eq 'Element'){
            $input = $input | Process-AstNode $processors $childNode
        }
    }
    $input
}

function Process-AstNode($processors, $astNode) {
    if($astNode.NodeType -ne 'Element'){
        "No element: $($astNode.NodeType)"
    }elseif($processors.ContainsKey($astNode.Name)){
        $input | &$processors[$astNode.Name] $processors $astNode
    }elseif($astNode.ChildNodes -ne $null){
        $input | Element $astNode.Name | Indent | Process-ChildNodes $processors $astNode | Dedent
    }else{
        $input | Element $astNode.Name
    }
}

function Transform-ArrayToTree{
    param($pass="dummy")

    $cs = $input
    [xml]$tree = "<CompilationUnit pass=""$pass""/>"
    $cursor = $tree.DocumentElement

    foreach($item in $cs){
        if($item.GetType() -eq [bool]){
            $indent = if($item){1}else{
                $cursor = $cursor.ParentNode
                0
            }
        }else{
            if($item[0] -eq '"'){
                $cursor.InnerText += ' ' + $item.Substring(1, $item.Length-1)
            }elseif($item[0] -eq '<'){
                $tagname = $item.Substring(1, $item.Length-1)
                if($indent -eq 0){
                    $cursor = $cursor.ParentNode
                }
                $cursor.InnerXml += "<$tagname/>"
                $cursor = $cursor.LastChild
                $indent = 0
            }
        }
    }
    $tree
}

function Flatten-ArrayKeys($dictionary){
    $flattened = @{}
    foreach($kv in $dictionary.GetEnumerator()){
        if($kv.Key -is [string]){
            $flattened[$kv.Key] = $kv.Value
        }else{
            $kv.Key | foreach {
                $flattened[$_] = $kv.Value
            }
        }
    }
    $flattened
}

