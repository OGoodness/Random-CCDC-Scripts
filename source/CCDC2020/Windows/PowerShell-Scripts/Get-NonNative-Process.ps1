$filterList = @(
    "ApplicationFrameHost";
    "autochk";
    "calc";
    "chkdsk";
    "csrss";
    "dllhost";
    "dwm";
    "explorer";
    "eventvwr";
    "grpconv";
    "Idle";
    "iexplore";
    "igfxCUIService";
    "igfxEM";
    "logonui";
    "lsass";
    "MicrosoftEdge";
    "MicrosoftEdgeCP";
    "MicrosoftEdgeSH";
    "mmc";
    "msconfig";
    "msiexec";
    "MsMpEng";
    "mspaint";
    "NisSrv";
    "notepad";
    "ntoskrnl";
    "nvudisp";
    "OneDrive";
    "pdboot";
    "Registry";
    "regsvr32";
    "rundll32";
    "runonce";
    "sc";
    "schtasks";
    "services";
    "shutdown";
    "sihost";
    "smss";
    "sndvol32";
    "spoolsv";
    "svchost";
    "System";
    "SystemSettings";
    "taskhostw";
    "taskmgr";
    "TrustedInstaller";
    "userinit";
    "wininit";
    "winlogon";
    "WinStore.App";
    "wmiPrvSE";
    "wuauclt";
    "wuauclt1";
    "wupdmgr";
)

$nonNativeProcesses = Get-Process | Where-Object -Property ProcessName -NotIn $filterList
$nonNativeProcesses
Write-Host ' '
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');