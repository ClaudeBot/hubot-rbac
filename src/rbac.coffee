# Description:
#   Role-based Access Control (RBAC) using Listener IDs
#
# Configuration:
#   None
#
# Commands:
#   hubot auth me - Returns your current role(s).
#   hubot auth block <listener ID> <role> - Blocks <listener ID> from being executed by subjects in <role>.
#   hubot auth unblock <listener ID> <role> - Unblocks <listener ID> for subjects in <role>.
#   hubot auth assign <subject> <role> - Assigns <subject> to <role>.
#   hubot auth unassign <subject> <role> - Unassigns <subject> from <role>.
#   hubot auth default <role> - Changes the default <role> for unassigned subjects.
#
# Notes:
#   WIP
#   May add support for RegEx blocking
#
# Author:
#   MrSaints

Immutable = require "immutable"

module.exports = (robot) ->
    _policies = Immutable.Map()
    _subjects = Immutable.Map()
    _default = false

    robot.brain.on "loaded", ->
        _convertToSet = (k, v) ->
            if Immutable.Iterable.isIndexed(v) then v.toSet() else v.toMap()

        data = robot.brain.data.rbac
        _policies = Immutable.fromJS data[0], _convertToSet
        _subjects = Immutable.fromJS data[1], _convertToSet
        _default = data[2]
        robot.logger.debug "hubot-rbac: loading, and converting RBAC from brain..."
        robot.logger.debug "hubot-rbac: policies -> #{_policies}"
        robot.logger.debug "hubot-rbac: subjects -> #{_subjects}"
        robot.logger.debug "hubot-rbac: default -> #{_default}"

    _saveRBAC = ->
        robot.brain.data.rbac =
            Immutable.List [_policies, _subjects, _default]
        robot.brain.save()

    _updatePolicy = (lid, role, block = true) ->
        # Roles are automatically created if they do not exist
        newPolicies = _policies.update role, Immutable.Set(), (set) ->
            if block
                robot.logger.debug "hubot-rbac: blocking listener ID..."
                set.add lid
            else
                robot.logger.debug "hubot-rbac: unblocking listener ID..."
                set.remove lid

        _policies = newPolicies
        _saveRBAC()
        robot.logger.debug "hubot-rbac: policies -> #{_policies}"

    _updateSubject = (subject, role, assign = true) ->
        newSubjects = _subjects.update subject, Immutable.Set(), (set) ->
            if assign
                robot.logger.debug "hubot-rbac: assigning role..."
                set.add role
            else
                robot.logger.debug "hubot-rbac: unassigning role..."
                set.remove role

        _subjects = newSubjects
        _saveRBAC()
        robot.logger.debug "hubot-rbac: subjects -> #{_subjects}"

    robot.respond /auth me/i, id: "auth.me", (res) ->
        # TODO: List blacklist?
        subject = res.message.user.name
        if not _subjects.has(subject) or _subjects.get(subject).size is 0
            res.reply "You are not assigned to any roles."
        else
            roles = _subjects.get(subject).join(", ")
            res.reply "You have been assigned the following role(s): #{roles}"

    robot.respond /auth block (.+) (.+)/i, id: "auth.block", (res) ->
        lid = res.match[1]
        role = res.match[2]
        _updatePolicy lid, role
        res.reply "Listener ID \"#{lid}\" is blocked for \"#{role}\" subjects."

    robot.respond /auth unblock (.+) (.+)/i, id: "auth.unblock", (res) ->
        lid = res.match[1]
        role = res.match[2]
        _updatePolicy lid, role, false
        res.reply "Listener ID \"#{lid}\" is unblocked for \"#{role}\" subjects."

    robot.respond /auth assign (.+) (.+)/i, id: "auth.assign", (res) ->
        # TODO: Check if user, ~~and group exists~~
        #user = robot.brain.userForName subject
        #subject = user.name
        subject = res.match[1]
        role = res.match[2]

        if not _policies.has(role)
            res.reply "Warning: the role (\"#{role}\") you have entered does not have any policies."

        _updateSubject subject, role
        res.reply "Assigned \"#{subject}\" to \"#{role}\"."

    robot.respond /auth unassign (.+) (.+)/i, id: "auth.unassign", (res) ->
        subject = res.match[1]
        role = res.match[2]
        _updateSubject subject, role, false
        res.reply "Unassigned \"#{subject}\" from \"#{role}\"."

    robot.respond /auth default (.+)/i, id: "auth.default", (res) ->
        role = res.match[1]
        _default = role
        res.reply "Changed the default role to: \"#{role}\""

    robot.listenerMiddleware (context, next, done) ->
        lid = context.listener.options.id
        subject = context.response.message.user.name

        terminate = false
        _blockRequest = ->
            robot.logger.debug "hubot-rbac: \"#{subject}\" executed a blacklisted listener (\"#{lid}\")."
            context.response.reply "Sorry, you are not authorised to execute that command."
            done()
            terminate = true
            return false

        # Skip if there are no subjects
        if _subjects.size is 0
            next()
            return false
        # Check default role if the subject has no roles
        else if not _subjects.has(subject)
            if _policies.hasIn [_default, lid]
                _blockRequest subject, lid
        # Otherwise, check roles for blacklisted listener IDs
        else
            _subjects.get(subject).forEach (role) ->
                if _policies.hasIn [role, lid]
                    _blockRequest subject, lid

        next() unless terminate