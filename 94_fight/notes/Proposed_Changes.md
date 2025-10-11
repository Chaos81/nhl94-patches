Plans for 94_patch version 1.0:

- H/Fs need to be adjusted for players based on 92-93 season fighting stats. Would like at least 1, maybe 2 fighters minimum for each team. (done)
- Reduce Minimum checks from 40. Compare to average checks/gm in a Classic season, and adjust (done, based on period length)
- Add RAM locations to keep track of per player ChksF (would need to patch FallDown routine). Player checks would be cleared when a fight happens. This is to prevent
    another fight from the same player when they get out of the box. (Not needed, don't think this is an issue)
- Create a python script that will expand the ROM, and add the patch for ROM expansion and fight.
- Adapt patch to work with 30 and 32-team ROMs. Will need to make compatible with sprite and palette patches. Will need to move the Sprite tile bytes in Frame Data at runtime.
- Add Fighting option into Main Menu. Add RAM variable for option, and add into patch code.
- Set up variables for "Arcade" fighting option (in progress). 
