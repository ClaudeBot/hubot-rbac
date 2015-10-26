# hubot-authority

[![Build Status](https://travis-ci.org/ClaudeBot/hubot-authority.svg)](https://travis-ci.org/ClaudeBot/hubot-authority)
[![devDependency Status](https://david-dm.org/ClaudeBot/hubot-authority/dev-status.svg)](https://david-dm.org/ClaudeBot/hubot-authority#info=devDependencies)

A Hubot script for restricting access to commands through role-based access control (RBAC), and [Listener IDs][listenerids].

See [`src/authority.coffee`](src/authority.coffee) for full documentation.


## Installation via NPM

1. Install the **hubot-authority** module as a Hubot dependency by running:

    ```
    npm install --save hubot-authority
    ```

2. Enable the module by adding the **hubot-authority** entry to your `external-scripts.json` file:

    ```json
    [
        "hubot-authority"
    ]
    ```

3. Run your bot and see below for available config / commands


## Commands

Command | Listener ID | Description
--- | --- | ---
hubot auth me | `auth.me` | Returns your current role(s).
hubot auth block `listener ID` `role` | `auth.block` | Blocks `listener ID` from being executed by subjects in `role`.
hubot auth unblock `listener ID` `role` | `auth.unblock` | Unblocks `listener ID` for subjects in `role`.
hubot auth assign `subject` `role` | `auth.assign` | Assigns `subject` to `role`.
hubot auth unassign `subject` `role` | `auth.unassign` | Unassigns `subject` from `role`.
hubot auth default `role` | `auth.default` | Changes the default `role` for unassigned subjects.


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


[listenerids]: https://hubot.github.com/docs/scripting/#listener-metadata