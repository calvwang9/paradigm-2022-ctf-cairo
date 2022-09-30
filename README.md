# Paradigm CTF 2022 Cairo Challenges

This repository contains a [Protostar](https://docs.swmansion.com/protostar/docs/tutorials/introduction) environment setup for the Paradigm 2022 CTF Cairo challenges, alongside solutions to the challenges.

## Setup

See the [Protostar docs](https://docs.swmansion.com/protostar/docs/tutorials/installation) for setup.

**Note:** the challenges were designed for Cairo v0.9.x. You can use Protostar v0.3.2 which installs Cairo v0.9.1.

```
curl -L https://raw.githubusercontent.com/software-mansion/protostar/master/install.sh | bash -s -- -v 0.3.2
```

## How to use

Write your solutions in `test_solution.cairo` in each respective challenge.

Run your solution using `protostar test`, e.g.

```
protostar test proxy/test_solution.cairo
```

If the test passes, you win!

## License

MIT
