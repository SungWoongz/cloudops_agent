#!/bin/bash
#
# AWS CodeArtifact pip login helper
#
# Configures pip's global index-url to an authenticated AWS CodeArtifact
# repository. The token is valid for 12 hours.
#
# Required environment variables:
#   AWS_ACCOUNT_ID        e.g. 123456789012
#   CODEARTIFACT_DOMAIN   e.g. mzc-cloudops
#   CODEARTIFACT_REPO     e.g. cloudops-pypi
#
# Optional (with defaults):
#   AWS_PROFILE           default: sandbox
#   CODEARTIFACT_REGION   default: ap-northeast-2

set -e

# -- config (from environment) --
: "${AWS_PROFILE:=sandbox}"
: "${CODEARTIFACT_REGION:=ap-northeast-2}"

require_env() {
    local missing=0
    for var in AWS_ACCOUNT_ID CODEARTIFACT_DOMAIN CODEARTIFACT_REPO; do
        if [ -z "${!var:-}" ]; then
            echo "[ERROR] Missing required environment variable: $var" >&2
            missing=1
        fi
    done

    if [ "$missing" -eq 1 ]; then
        echo "" >&2
        echo "Set the required variables in .env.local:" >&2
        echo "" >&2
        echo "  AWS_ACCOUNT_ID=123456789012" >&2
        echo "  CODEARTIFACT_DOMAIN=your-domain" >&2
        echo "  CODEARTIFACT_REPO=your-repo" >&2
        exit 1
    fi
}

check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "[ERROR] AWS CLI is not installed." >&2
        echo "  Install: brew install awscli" >&2
        return 1
    fi

    if ! aws configure list --profile "$AWS_PROFILE" &> /dev/null; then
        echo "[ERROR] AWS profile '$AWS_PROFILE' is not configured." >&2
        echo "  Configure: aws configure --profile $AWS_PROFILE" >&2
        return 1
    fi

    return 0
}

main() {
    require_env
    check_aws_cli || exit 1

    echo "=== CodeArtifact Login ==="
    echo "  Profile:    $AWS_PROFILE"
    echo "  Domain:     $CODEARTIFACT_DOMAIN"
    echo "  Repository: $CODEARTIFACT_REPO"
    echo "  Region:     $CODEARTIFACT_REGION"
    echo ""

    echo "Logging in to CodeArtifact..."

    if AWS_PROFILE=$AWS_PROFILE aws codeartifact login --tool pip \
        --domain "$CODEARTIFACT_DOMAIN" \
        --domain-owner "$AWS_ACCOUNT_ID" \
        --repository "$CODEARTIFACT_REPO" \
        --region "$CODEARTIFACT_REGION"; then
        echo ""
        echo "[OK] CodeArtifact login complete -- $CODEARTIFACT_REPO (token valid for 12 hours)"
    else
        echo "[FAIL] CodeArtifact login failed" >&2
        exit 1
    fi
}

main "$@"
