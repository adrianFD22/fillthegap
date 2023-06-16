# The GAP package fillthegap

These are just the functions I used to declare in my gaprc. As my gaprc grew, I gathered all of them together in this package.

The only functions that I think can be useful for the person who is reading this (hi, btw) are the ones that offer the functionality of managing daily logs.


## Daily Logs

GAP offers the [`LogTo`](https://docs.gap-system.org/doc/ref/chap9_mj.html#X79813A6686894960) function to help saving your terminal session in a plain text file. In this package I provide two simple functions for organizing a folder with log files. Essentially, they store log files in a given directory and merge the logs that correspond to the same day in the same file.

- `LogToDate(LOG_PATH)`: logs to a file in the `LOG_PATH` directory as `LogTo` does.
- `CleanLogs(LOG_PATH, NUM_LOG_FILES)`: deletes log files in the `LOG_PATH` and maintains the `NUM_LOG_FILES` latest of them (WARNING: this deletes files).


## TODO

- Implement the `MinkowskiSum` function in a better way by using the Fast Fourier Transform (dont know about this is implemented in GAP).


## Contact

I'm Adrián Fidalgo-Díaz. If you have any suggestions or whatever, feel free to contact me at adrianfd22399@gmail.com.
