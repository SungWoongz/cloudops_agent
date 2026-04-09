#!/usr/bin/env bash
set -euo pipefail

# get-repo.sh — Clone upstream repo into reference/ subdirectory (read-only)
# Usage: get-repo.sh <repo-name> [org] [project-root]

# --- Preflight: gh installed & authenticated? ---
if ! command -v gh &>/dev/null; then
  echo "ERROR: GitHub CLI (gh) is not installed."
  echo "       Run /setup-check to configure your environment."
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "ERROR: GitHub CLI is not authenticated."
  echo "       Run /setup-check to configure your environment."
  exit 1
fi

REPO="${1:?Usage: get-repo.sh <repo-name> [org] [project-root]}"
ORG="${2:-mzc-cloudops-v2}"
PROJECT_ROOT="${3:-.}"

# --- Step 1: Validate repo & get topics ---
echo ":: Checking ${ORG}/${REPO} ..."
REPO_JSON="$(gh repo view "${ORG}/${REPO}" --json name,repositoryTopics 2>&1)" || {
  echo "ERROR: Repository ${ORG}/${REPO} not found."
  exit 1
}

TOPICS="$(echo "${REPO_JSON}" | jq -r '
  if .repositoryTopics == null then ""
  else [.repositoryTopics[].name] | join(",")
  end
')"
echo "   Topics: ${TOPICS:-"(none)"}"

# --- Step 2: Determine destination ---
if echo "${TOPICS}" | grep -qi "core"; then
  DEST="reference/cores"
elif echo "${TOPICS}" | grep -qi "plugin"; then
  DEST="reference/plugins"
else
  DEST="reference/others"
fi
echo "   Destination: ${DEST}/"

# --- Step 3: Check for conflicts ---
TARGET_DIR="${PROJECT_ROOT}/${DEST}/${REPO}"
if [ -d "${TARGET_DIR}" ]; then
  echo "ERROR: ${TARGET_DIR} already exists. Aborting."
  exit 1
fi

# --- Step 4: Clone upstream directly (NO fork) ---
echo ":: Cloning ${ORG}/${REPO} into ${DEST}/${REPO} ..."
mkdir -p "${PROJECT_ROOT}/${DEST}"
cd "${PROJECT_ROOT}/${DEST}"
gh repo clone "${ORG}/${REPO}" "${REPO}"

# --- Step 5: Report ---
echo ""
echo "=== Done ==="
echo "Source:    ${ORG}/${REPO}"
echo "Topics:   ${TOPICS:-"(none)"}"
echo "Cloned:   ${DEST}/${REPO}"
echo ""
echo "WARNING: This is a READ-ONLY reference copy. Never modify files here."
