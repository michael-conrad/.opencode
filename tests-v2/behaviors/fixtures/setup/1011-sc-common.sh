#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario shared fixture (.opencode#1011 scenarios): a merged-PR state.
# feature/demo-login is pushed to the provisioned GitBucket remote, PR #1 is
# created and merged through the GitBucket web form (the GitBucket API v3 has
# no PR create/merge endpoints — probed 2026-10-07), and the local repo ends
# on the trunk with the feature branch still present locally and remotely.
#
# Requires BEHAVIOR_NEEDS_REMOTE=1 (GITBUCKET_PORT/GB_TOKEN exported by
# __ensure_gitbucket before the attempt loop sources this script).
#
# Determinism: the scenario scripts call __reset_gitbucket before
# behavior_run, so the container repo starts fresh and the scenario PR is
# number 1. The guards below make a within-run fixture re-source (attempt 2
# after an empty-output model retry) a no-op instead of a divergent re-push.

setup_1011_merged_pr_state() {
    local wd="$1"
    local port="${GITBUCKET_PORT:?GITBUCKET_PORT not set — BEHAVIOR_NEEDS_REMOTE=1 required}"
    local token="${GB_TOKEN:-root}"
    local origin="http://root:${token}@localhost:${port}/git/root/test-repo.git"

    git -C "$wd" remote add origin "$origin" 2>/dev/null ||
        git -C "$wd" remote set-url origin "$origin"

    # Align the local base branch name with the remote trunk.
    local base
    base="$(git -C "$wd" symbolic-ref --short HEAD)"
    if [ "$base" != "master" ]; then
        git -C "$wd" branch -m "$base" master
    fi

    git -C "$wd" fetch -q origin 2>/dev/null || true

    # Guard 1 — already merged (attempt-2 re-source): if the remote feature
    # branch is an ancestor of the remote trunk, the scenario state exists.
    if git -C "$wd" merge-base --is-ancestor origin/feature/demo-login origin/master 2>/dev/null; then
        git -C "$wd" checkout -q master
        return 0
    fi

    # Commit the auto-injected .issues fixture state onto the trunk, push it.
    git -C "$wd" add .issues tmp 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "chore: issue-store fixture state"
    git -C "$wd" push -q origin master

    # Feature branch with the delivered work.
    git -C "$wd" checkout -q -b feature/demo-login
    printf 'demo login\n' > "$wd/demo-login.txt"
    git -C "$wd" add demo-login.txt
    git -C "$wd" commit -q -m "feat: demo login"
    git -C "$wd" push -q origin feature/demo-login
    local from_sha to_sha
    from_sha="$(git -C "$wd" rev-parse HEAD~1)"
    to_sha="$(git -C "$wd" rev-parse HEAD)"

    # GitBucket web-form session (root/root admin — harness-provisioned).
    local cj
    cj="$(mktemp)"
    curl -s -c "$cj" -X POST "http://localhost:${port}/signin" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "userName=root" --data-urlencode "password=root" \
        --data-urlencode "hash=" -o /dev/null

    # Reuse PR #1 when a prior attempt created it; otherwise create it
    # through the web form (the API has no PR create endpoint).
    local existing
    existing="$(curl -s "http://localhost:${port}/api/v3/repos/root/test-repo/pulls/1" \
        -H "Authorization: token ${token}")"
    local pr_num pr_state
    pr_num="$(printf '%s' "$existing" | python3 -c 'import json,sys
d = json.load(sys.stdin)
print(d.get("number", "") if isinstance(d, dict) else "")' 2>/dev/null || true)"
    pr_state="$(printf '%s' "$existing" | python3 -c 'import json,sys
d = json.load(sys.stdin)
print(d.get("state", "") if isinstance(d, dict) else "")' 2>/dev/null || true)"

    if [ -z "$pr_num" ]; then
        local loc
        loc="$(curl -s -b "$cj" -o /dev/null -w '%{redirect_url}' -X POST "http://localhost:${port}/root/test-repo/pulls/new" \
            --data-urlencode "title=Add demo login" \
            --data-urlencode "content=Adds the demo login flow." \
            --data-urlencode "targetUserName=root" \
            --data-urlencode "targetBranch=master" \
            --data-urlencode "requestUserName=root" \
            --data-urlencode "requestRepositoryName=test-repo" \
            --data-urlencode "requestBranch=feature/demo-login" \
            --data-urlencode "commitIdFrom=${from_sha}" \
            --data-urlencode "commitIdTo=${to_sha}" \
            --data-urlencode "isDraft=false" \
            --data-urlencode "labelNames=" \
            --data-urlencode "milestoneId=" \
            --data-urlencode "assigneeUserNames=")"
        pr_num="$(printf '%s' "$loc" | grep -oE 'pull/[0-9]+' | grep -oE '[0-9]+' | head -1)"
        pr_state="open"
        if [ -z "$pr_num" ]; then
            echo "FATAL: PR creation returned no pull request location (loc=${loc})" >&2
            rm -f "$cj"
            return 1
        fi
    fi

    # Merge through the web form when the PR is still open.
    if [ "$pr_state" = "open" ]; then
        curl -s -b "$cj" -o /dev/null -X POST "http://localhost:${port}/root/test-repo/pull/${pr_num}/merge" \
            --data-urlencode "message=Merge pull request #${pr_num} from feature/demo-login" \
            --data-urlencode "strategy=merge-commit" \
            --data-urlencode "isDraft=false"
    fi
    rm -f "$cj"

    # Post-merge local state: on the trunk, feature branch still present.
    git -C "$wd" checkout -q master
}
