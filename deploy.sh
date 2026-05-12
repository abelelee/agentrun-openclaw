#!/usr/bin/env bash
# deploy.sh — simple install / uninstall for the openclaw-agent Helm chart.
#
# Usage:
#   ./deploy.sh install   <namespace>
#   ./deploy.sh uninstall <namespace>
#   ./deploy.sh status    <namespace>
#   ./deploy.sh template  <namespace>
#
# The <namespace> positional arg is used for:
#   - helm's -n flag (where the release metadata lives)
#   - the Agent CR namespace (via --set namespace=...)
#   - the auto-derived Agent name ('openclaw-<namespace>')
#
# Environment (optional):
#   KUBECONFIG    default: ~/.kube/agentrun.kubeconfig
#   VALUES_FILE   default: ./examples/values-aliyun.yaml
#   RELEASE_NAME  default: openclaw-<namespace>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="$SCRIPT_DIR"

: "${KUBECONFIG:=$HOME/.kube/agentrun.kubeconfig}"
: "${VALUES_FILE:=$CHART_DIR/examples/values-aliyun.yaml}"
export KUBECONFIG

log() { printf '\033[1;34m[deploy]\033[0m %s\n' "$*" >&2; }
err() { printf '\033[1;31m[error]\033[0m  %s\n' "$*" >&2; }

usage() {
  cat <<EOF
Usage:
  $(basename "$0") install   <namespace>
  $(basename "$0") uninstall <namespace>
  $(basename "$0") status    <namespace>
  $(basename "$0") template  <namespace>
EOF
  exit "${1:-0}"
}

[[ $# -lt 1 ]] && usage 1

CMD="$1"; shift

case "$CMD" in
  -h|--help|help) usage 0 ;;
esac

[[ $# -lt 1 ]] && { err "Missing <namespace> argument"; usage 1; }
NS="$1"; shift

RELEASE_NAME="${RELEASE_NAME:-openclaw-$NS}"

log "Command:    $CMD"
log "Namespace:  $NS"
log "Release:    $RELEASE_NAME"
log "Kubeconfig: $KUBECONFIG"

case "$CMD" in
  install|upgrade)
    helm upgrade --install "$RELEASE_NAME" "$CHART_DIR" \
      -n "$NS" --create-namespace \
      -f "$VALUES_FILE" \
      --set "namespace=$NS" \
      "$@"
    ;;
  uninstall|delete)
    helm uninstall "$RELEASE_NAME" -n "$NS" "$@"
    ;;
  status)
    helm status "$RELEASE_NAME" -n "$NS" "$@" || true
    echo
    kubectl -n "$NS" get agent -o wide || true
    ;;
  template)
    helm template "$RELEASE_NAME" "$CHART_DIR" \
      -n "$NS" \
      -f "$VALUES_FILE" \
      --set "namespace=$NS" \
      "$@"
    ;;
  *)
    err "Unknown command: $CMD"
    usage 1
    ;;
esac
