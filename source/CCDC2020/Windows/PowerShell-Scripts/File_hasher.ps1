param([bool]$r=1 ,[string]$p=$pwd,[string]$a="MD5",[array]$e=("all",""),[array]$ne=("none",""),[string]$f="",[Int32]$d=-1,[string]$n="hashes1.txt")




# This script is for hashing all files in a given directory and all it's sub directories
# It can also compare a previously made list of hashes, to a newly generated list of hashes,
# to check for any new files, removed files, or files with changed hashes
# - Made by David Parra

#Parameter guide
# -r <int or bool>    : if A true value is suplied the hasher will hash recursively ex. -r 3 
# -p <directory path> : specify a directory to hash the files of ex. -p C:\Windows\System32
# -a <algorithm>      : specify a hashing algorithm to use ex. -a SHA1
# -e <file extension> : specify a list of file extensions (strings) to exclusively hash ex. -e (".txt",".conf",".dll",".exe",".ini")
# -ne <file extension>: specify a list of file extenstions (strings) to exclude (overwrites -e) ex. -ne (".ova",".iso",".jpg",".exe")
# -f <file path>      : specify a hash list file to compare to, in the same format outputted by this script. ex. -f "hashes2.csv" -f "C:\Windows\hashes.csv"
# -d <integer>        : specify a directory depth to use when recursively hashing through directories. default is -1 (infinite depth) ex. -d 4 
# -n <file path>      : specify a name to use to save the file as (not properly implemented yet)
# -m <int>            : specify a max number of files to hash


#add functionality that limits a max file size
#add functionality that add's itself to the system PATH


#Resources
# Making tables: https://blogs.msdn.microsoft.com/rkramesh/2012/02/01/creating-table-using-powershell/


function Get-RecursiveHashes
{
    param(
    [Parameter()]
    [string]$path=$p,
    [bool]$recursive=$r,
    [Int32]$depth=$d 
    #[string]$file=($pwd + "hashes.txt")
    )

    Get-ChildItem $path | ForEach-Object{ 

        if($recursive -and $depth -ne 0)
        {
            if((Get-Item $_.FullName) -is [System.IO.DirectoryInfo])
            {
                Get-RecursiveHashes -path $_.FullName -depth ($depth - 1)
            }
        }
        if(($_.Extension -in $e -or "all" -in $e) -and ($_.Extension -inotin $ne -or "none" -in $ne))
        {
           Get-FileHash $_.FullName -Algorithm $a 
        }
    }
}


#====Checks to see if an acceptable hashing algorithm is supplied====
# If a proper algorithm is not supplied, the script aborts, and suggests acceptable algorithms
if($a -inotin ("SHA1","SHA256","SHA384","SHA512","MACTripleDES","MD5","RIPEMD160"))
{
    Write-Error -Message "Cannot validate argument on parameter 'Algorithm'. The argument $a does not belong to the set `"SHA1,SHA256,SHA384,SHA512,MACTripleDES,MD5,RIPEMD160`" specified by the ValidateSet attribute" -CategoryReason "InvalidData: (:) [Get-FileHash], ParameterBindingValidationException" -RecommendedAction  "Supply an argument that is in the set and then try the command again."
    Write-Host "`nChange -a to a proper algorithm: (SHA1,SHA256,SHA384,SHA512,MACTripleDES,MD5,RIPEMD160)" -ForegroundColor Green
    return
}
echo "Hashing files..."
$hashtable = Get-RecursiveHashes -path $p

#====Compares a previously generated csv file of hashes to a newly generated list of hashes====
# Currently it only uses the old hashes in a file named hashes1.csv
# the hashes1.csv file is generated after running the script for the first time
For($i=1;$i -lt 100; $i++)
{
    if(-NOT (Test-Path ($p + "\hashes" + $i + ".txt")))
    {
        $oldfile = $n
        $n=$n.replace("1", $i)


        Write-Output "$a hashes for the files in the `"$p`" directory, with a depth of $d" > $n

        $hashtable | Format-Table hash,path -AutoSize >> $n

        #add the -f parameter to be used for a supplied list to use to check old file hashes of
        $oldcsv = ($p + "\hashes" + "1" + ".csv")
        $hashtable | Export-CSV ($p + "\hashes" + $i + ".csv")


        $oldhashes = (Import-Csv ($p + "\hashes" + "1" + ".csv"))
        $newhashes = $hashtable
            

        if($i -ne 1)
        {
            $differences = New-Object system.Data.DataTable “Hashdifferences”

            ##====A Different method of adding tables to columns====
            ##This method does not output anything to the console
            
            $col1 = New-Object system.Data.DataColumn "Different Hashes"
            $col2 = New-Object system.Data.DataColumn "New Files"
            $col3 = New-Object system.Data.DataColumn "Removed Files"
            $differences.columns.add($col1)
            $differences.columns.add($col2)
            $differences.columns.add($col3)
            #>

            ##====A Different method of adding tables to columns====
            ##This method outputs column info to the console
            <#
            $differences.Columns.add( "Different Hashes" )
            $differences.Columns.add( "New Files" )
            $differences.Columns.add( "Removed Files" ) 
            #>

            ##====Prints out the list of old and new hashes, with file names, to the console====
            ## Useful for debugging
            <#
            Write-Host " OLD HASHES `n ------------" -ForegroundColor Green
            $oldhashes
            Write-Host " NEW HASHES `n ------------" -ForegroundColor Green
            $newhashes
            #>

            ##====Compares the new hashes to the old hashes====
            ##Checks for files with the same name (path), but different hashes
            ##Also checks for any new files, files that are in the new hashlist, but not in the old hashlist
            :start for($i=0;$i -lt $newhashes.Length; $i++)
            {
                $currenthash = $newhashes[$i].Hash
                $currentpath = $newhashes[$i].Path
                for($j=0;$j -lt $oldhashes.Length; $j++)
                {
                    if($oldhashes[$j].Path -eq $currentpath)
                    {
                        if($oldhashes[$j].Hash -eq $currenthash)
                        {
                            continue start
                        }
                        else
                        {
                            $row = $differences.NewRow()
                            $row["Different Hashes"] = $currentpath
                            $differences.Rows.Add($row)
                            continue start
                        }
                    }
                }
                $row = $differences.NewRow()
                $row["New Files"] = $currentpath
                $differences.Rows.Add($row)
            }

            for($k=0;$k -lt $oldhashes.Length; $k++)
            {
                if($oldhashes[$k].Path -inotin $newhashes.Path)
                {
                    echo "Removed File found"
                    $row = $differences.NewRow()
                    $row["Removed Files"] = $oldhashes[$k].Path
                    $differences.Rows.Add($row)  
                 }
            }
        }
        break
    } 
}
echo "differences is: `n" 
$differences | Format-Table "Different Hashes","New Files","Removed Files"
#$differences

Write-Host "Complete, Hash list saved as $n" -ForegroundColor Green