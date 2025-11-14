# Rough example
```bash
$ getbits ls
You have 6.3e82B (bits)!

$ getbits shop
Available upgrades:
- (A)utobuyers:
- - (1)ML: 1.34e3 | 1e20UB * 10
- - (2)ML: 2 | 1e30UB * 1

$ getbits shop buy 1
Purchased a first mining layer upgrade! Now you have:
- 1.35e3 1MLs!

$
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

### Example
```bash
$ getbits stats
You have 1.32e84B.
Your bits are increasing by 1.5x every second!
You've already produced 5.4e85B.
```

> [!IMPORTANT]
> Work In Progress
# Global params
## --script
`[--script]` - makes the game script-compatible, so this:
```bash
$ getbits ls
You have 6.3e82B (bits)!
```
becomes this:
```bash
$ getbits ls --script
6.3e82B
```
This is just an example, every fancy-formated command will become script-compatible.

### Rough --script example
```bash
$ getbits ls --script
6.3e82B

$ getbits shop --script
A1 1.34e3 1e20UB
A2 2 1e30UB

$ getbits shop buy 1 10 --script
A1 1.35e3 1e21UB

$ 
```

## --json
`[--json]` - outputs data in json.

### Rough --json example
```bash
$ getbits ls --json
{"bits": 6.3e82}

$ getbits shop --json
{
    "upgrades": {
        "autobuyers": {
            "mining layers": [
                {
                    "already owned": 1.34e3,
                    "cost": {"number": 1e19, "currency": "ub"}
                },
                {
                    "already owned": 2
                    "cost": {"number": 1e30, "currency": "ub"}
                }
            ]
        }
    }
}
```

$ getbits shop
Available upgrades:
- (A)utobuyers:
- - (1)ML: 1.34e3 | 1e20UB * 10
- - (2)ML: 2 | 1e30UB * 1

> [!IMPORTANT]
> Work In Progress
# Ncurses commands
## watch
[`watch`] - prints a bunch of info for 60 frames per second.
