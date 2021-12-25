# Server FPS Recorder
## Description
A simple SourceMod plugin that saves the server fps for a CS:GO server every second using a regex and the `stats` command. Every 500 seconds it appends the data to the file `csgo/serverbenchmark-data.txt` in the format:

```unix_timestamp fps_this_second```

### Example:
```
1640434765 127.389999
1640434766 127.989997
1640434767 128.039993
1640434768 127.989997
1640434769 128.119995
1640434770 128.009994
1640434771 128.059997
1640434772 128.059997
1640434773 127.989997
1640434774 128.220001
1640434775 127.910003
1640434776 128.059997
```

Can then be visualized using Google spreadsheets like this:

![image](https://cm2.network/csgo/Server%20FPS%20-%2020%20Bots.png)

## Credits
* [Walentin Lamonos](https://github.com/CM2Walki) (fork)
* [Christian Deacon](https://github.com/gamemann) (gamemann/FPS-Threshold)
