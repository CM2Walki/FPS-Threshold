#include <sourcemod>
#include <regex>

// How often are we going to write out our results
#define FILE_WRITE_TIME_SECONDS 500

public Plugin myinfo =
{
    name = "Server FPS Recorder",
    author = "CM2Walki",
    description = "A plugin that records every seconds FPS and writes it out file after X minutes. Useful for benchmarking a server.",
    version = "1.0.0",
    url = "https://github.com/CM2Walki"
};

// Simple circular buffers to store the last frame time and timestamp
float g_fpsarr[FILE_WRITE_TIME_SECONDS];
int g_timestamps[FILE_WRITE_TIME_SECONDS];

// Array to copy to before writing to file (I/O is async), 
// because underlying the other arrays will already have new data being written to
float write_arr_fps[FILE_WRITE_TIME_SECONDS];
int write_arr_timestamp[FILE_WRITE_TIME_SECONDS];

int g_current_index = 0;

File g_file_hndl;
Regex g_regex_hndl;

public OnPluginStart()
{
	// Open handle to file
    g_file_hndl = OpenFile("serverbenchmark-data.txt", "w");
	// Precompile Regex
    g_regex_hndl = CompileRegex("(\\d+\\.\\d+)\\s+(\\d+\\.\\d+)\\s+(\\d+\\.\\d+)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+\\.\\d+)\\s+(\\d+)\\s+(\\d+\\.\\d+)\\s+(\\d+\\.\\d+)\\s+(\\d+\\.\\d+)");
    CreateTimer(1.0, logfps, 0, TIMER_REPEAT);
}

public OnPluginEnd()
{
    CloseHandle(g_file_hndl);
    CloseHandle(g_regex_hndl);
}

public Action:logfps(Handle:timer)
{
	g_fpsarr[g_current_index] = GetFPS();
	g_timestamps[g_current_index] = GetTime();

	// Increment index, also used to determine if we need to write the data to file
	g_current_index++;

	if (g_current_index >= FILE_WRITE_TIME_SECONDS)
	{
		// Reset to beginning of array
		g_current_index = 0;
		
		// Write data to file array
		for(int i = 0; i < FILE_WRITE_TIME_SECONDS; i++)
		{
			write_arr_fps[i] = g_fpsarr[i];
			write_arr_timestamp[i] = g_timestamps[i];
		}
		
		// Write data to file
		WriteBenchmarkData();
	}
}

public void WriteBenchmarkData()
{
    for(int i = 0; i < FILE_WRITE_TIME_SECONDS; i++)
    {
        WriteFileLine(g_file_hndl, "%i %f", write_arr_timestamp[i], write_arr_fps[i]);
    }
}

// Based on:
// https://forums.alliedmods.net/showpost.php?p=1966488&postcount=2
public float GetFPS()
{
    decl String:buffer[256];
    ServerCommandEx(buffer, sizeof(buffer), "stats");

    new subCount = MatchRegex(g_regex_hndl, buffer);
	
    PrintToServer(buffer);
    
    if (subCount < 10)
    {
        // not enough matches
		// Example what we want to match (CSGO, stats command):
		//   CPU   NetIn   NetOut    Uptime  Maps   FPS   Players  Svms    +-ms   ~tick
		//   10.0  10744.8  37350.5       4     1  127.50      20    4.48    0.96    0.02
        return -1.0;
    }

    decl String:cpu[12];
    decl String:incoming[12];
    decl String:out[12];
    decl String:uptime[12];
    decl String:mapchanges[12];
    decl String:fps[12];
    decl String:players[12];
    decl String:svms[12];
    decl String:ms[12];
    decl String:tick[12];

    GetRegexSubString(g_regex_hndl, 1, cpu, sizeof(cpu));
    GetRegexSubString(g_regex_hndl, 2, incoming, sizeof(incoming));
    GetRegexSubString(g_regex_hndl, 3, out, sizeof(out));
    GetRegexSubString(g_regex_hndl, 4, uptime, sizeof(uptime));
    GetRegexSubString(g_regex_hndl, 5, mapchanges, sizeof(mapchanges));
    GetRegexSubString(g_regex_hndl, 6, fps, sizeof(fps));
    GetRegexSubString(g_regex_hndl, 7, players, sizeof(players));   
    GetRegexSubString(g_regex_hndl, 8, svms, sizeof(svms));
    GetRegexSubString(g_regex_hndl, 9, ms, sizeof(ms));
    GetRegexSubString(g_regex_hndl, 10, tick, sizeof(tick));

    return StringToFloat(fps);
}  