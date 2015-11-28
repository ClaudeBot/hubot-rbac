# hubot-rbac

[![Build Status](https://travis-ci.org/ClaudeBot/hubot-rbac.svg)](https://travis-ci.org/ClaudeBot/hubot-rbac)
[![devDependency Status](https://david-dm.org/ClaudeBot/hubot-rbac/dev-status.svg)](https://david-dm.org/ClaudeBot/hubot-rbac#info=devDependencies)

A Hubot script for restricting access to commands through [role-based access control (RBAC)][rbac], and [Listener IDs][options].

Roles are automatically created when policies are added / removed (e.g. when a listener ID is blocked).

### Caveats

- Currently, the script can only block listeners IF they have an ID attached to it via their [options / metadata][options];
- Furthermore, the full ID must be specified when creating policies;
- None of the script's commands are blocked by default (i.e. anyone can use it, but they can not use it against a power user).

See [`src/rbac.coffee`](src/rbac.coffee) for full documentation.


## Installation via NPM

1. Install the **hubot-rbac** module as a Hubot dependency by running:

    ```
    npm install --save hubot-rbac
    ```

2. Enable the module by adding the **hubot-rbac** entry to your `external-scripts.json` file:

    ```json
    [
        "hubot-rbac"
    ]
    ```

3. Run your bot and see below for available config / commands


## Configuration

Variable | Default | Description
--- | --- | ---
`HUBOT_RBAC_POWER_USERS` | N/A | A comma-separated list of user names to be granted complete, and immutable permissions.


## Commands

Command | Listener ID | Description
--- | --- | ---
hubot auth me | `auth.me` | Returns your current role(s).
hubot auth block `listener ID` `role` | `auth.block` | Blocks `listener ID` from being executed by subjects in `role`.
hubot auth unblock `listener ID` `role` | `auth.unblock` | Unblocks `listener ID` for subjects in `role`.
hubot auth assign `subject` `role` | `auth.assign` | Assigns `subject` to `role`.
hubot auth unassign `subject` `role` | `auth.unassign` | Unassigns `subject` from `role`.
hubot auth default `role` | `auth.default` | Changes the default `role` for unassigned subjects.
hubot auth ids | `auth.ids` | Returns a list of listener IDs that can be blocked.
hubot auth roles | `auth.roles` | Returns a list of roles, and their respective subjects.


## Sample Interaction

```
user1>> hubot links list
hubot>> user1: Nothing has been shared recently.
user1>> hubot auth me
hubot>> user1: You are not assigned to any roles.
user1>> hubot auth block links.list nolinkrecording
hubot>> user1: Listener ID "links.list" is blocked for "nolinkrecording" subjects.
user1>> hubot auth assign user1 nolinkrecording
hubot>> user1: Assigned "user1" to "nolinkrecording".
user1>> hubot links list
hubot>> user1: Sorry, you are not authorised to execute that command.
user1>> hubot auth me
hubot>> user1: You have been assigned the following role(s): nolinkrecording
```


[rbac]: https://en.wikipedia.org/wiki/Role-based_access_control
[options]: https://hubot.github.com/docs/scripting/#listener-metadata