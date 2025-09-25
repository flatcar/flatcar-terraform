# How to Contribute

Welcome! We’re excited that you’re interested in contributing to this project. Whether you’re a seasoned developer or new to open source, your contributions are valued and appreciated. Please read the guidelines below to help us maintain a collaborative and inclusive environment.

CoreOS projects are [Apache 2.0 licensed](LICENSE) and accept contributions via
GitHub pull requests.  This document outlines some of the conventions on
development workflow, commit message formatting, contact points and other
resources to make it easier to get your contribution accepted.

# Certificate of Origin

By contributing to this project we agree to the Developer Certificate of
Origin (DCO). This document was created by the Linux Kernel community and is a
simple statement that we, as contributors, have the legal right to make the
contribution. See the [DCO](DCO) file for details.

# Email and Chat

The project currently uses the general CoreOS email list and IRC channel:
- Email: [coreos-dev](https://groups.google.com/forum/#!forum/coreos-dev)
- IRC: #[coreos](irc://irc.freenode.org:6667/#coreos) IRC channel on freenode.org

Please avoid emailing maintainers found in the [MAINTAINERS](MAINTAINERS) file directly. They
are very busy and read the mailing lists.

## Getting Started

- Fork the repository on GitHub
- Read the [README](README.md) for build and test instructions
- Play with the project, submit bugs, submit patches!

## Contribution Flow

This is a rough outline of what a contributor's workflow looks like:

- Create a topic branch from where you want to base your work (usually master).
- Make commits of logical units.
- Make sure your commit messages are in the proper format (see below).
- Push your changes to a topic branch in your fork of the repository.
- **Run the tests:**
  - Follow the instructions in the [README](README.md) to run the test suite locally.
  - Ensure all tests pass before submitting your changes.
  - If you add new features or fix bugs, please add or update tests as appropriate.
- **Code style:**
  - Please follow any existing code style and formatting conventions in the project.
  - If you are unsure, ask in the mailing list or open a draft pull request for feedback.
- Submit a pull request to the original repository.
- **Code review:**
  - Your pull request will be reviewed by maintainers or other contributors.
  - Reviewers may request changes or ask questions to clarify your implementation.
  - Please respond to feedback and update your pull request as needed.
  - Once approved, your changes will be merged.

Thanks for your contributions!

### Format of the Commit Message

To help ensure clarity and consistency, please follow these commit message guidelines:

**Commit Message Checklist:**
- [ ] The subject line summarizes what changed (max 70 characters)
- [ ] The second line is blank
- [ ] The body explains why the change was made (wrapped at 80 characters)
- [ ] The footer (if present) references issues or pull requests (e.g., Fixes #123)

**Good Example:**
```
flatcar-terraform: add the test-cluster command

this uses tmux to setup a test cluster that you can easily kill and
start for debugging.

Fixes #38
```

**Bad Example:**
```
update stuff

added some things
```

The format can be described more formally as follows:

```
<subsystem>: <what changed>
<BLANK LINE>
<why this change was made>
<BLANK LINE>
<footer>
```

The first line is the subject and should be no longer than 70 characters, the
second line is always blank, and other lines should be wrapped at 80 characters.
This allows the message to be easier to read on GitHub as well as in various
git tools.
