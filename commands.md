# Rough example
```bash
$ getbits ls
You have 6.3e82 bits!
$ getbits shop
Available upgrades:
- (A)utobuyers:
- - (1)ML: 1.34e3(6/10) | 1e20UB * 10
- - (2)ML: 2/10 | 1e30UB * 1
$ getbits p a 1
Purchased a first mining layer upgrade! Now you have:
- 1.35e3 1MLs!
```

# Commands
## ls
`[ls]` - calculates your current bits, and lists them.

## shop
`[shop]` - shop stuff.
### Sub commands
` ` - alias to `ls`
`[ls] <what_to_list>` - lists all the updates you can buy. if `<what_to_list>` is empty, list all the possible upgrades.
`[buy] <upgrade_category> <updgrade_number>` - purchase an upgrade.

## stats
`[stats]` - show stats, including production speed, and the total produced amount.

# Global params
`[--script]` - makes the game script-compatible, so this:
```bash
$ getbits ls
You have 6.3e82 bits!
```
becomes this:
```bash
$ getbits ls --script
6.3e82
```
This is just an example, every fancy-formated command will become script-compatible.

> [!IMPORTANT]
> Work In Progress
# Ncurses commands
## watch
[`watch`] - prints a bunch of info for 60 frames per second.
