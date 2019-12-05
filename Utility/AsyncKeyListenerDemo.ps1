# Listens for W, reports true if it was pressed at any point (timeslice of 10ms) between second-long intervals. Basically a poorman's readkeyasync but for a single key
# Google shows a lot of good C# solutions that could be translated to PS as well, but this is the most powershell method I could come up with
# Plus I just found out about jobs so now I have to abuse the fuck out of them, like when I found %{}, or &{}, or pipes.

start-job -initializationscript {
	$signature = '[DllImport("user32.dll")]public static extern short GetKeyState(int nVirtKey);'
	$type = Add-Type -MemberDefinition $signature -Name User32 -Namespace GetKeyState -PassThru
} -scriptblock {
	while($true){
		[bool]($type::GetKeyState(0x57) -band 0x80);
		start-sleep -milliseconds 10;
	}
}

while($true){
	(receive-job *).contains($true);
	start-sleep 1
}

stop-job *
remove-job *
