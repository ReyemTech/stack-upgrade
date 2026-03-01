FROM node:22-bookworm-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ssh-client unzip curl gettext-base jq \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI (for auto PR creation)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Enable corepack for pnpm/yarn (pin pnpm@9 — avoid corepack signature verification failures with @latest)
RUN corepack enable && corepack prepare pnpm@9 --activate

# Non-root user (Claude Code refuses to run as root)
RUN useradd -m -s /bin/bash agent \
    && mkdir -p /workspace /output /skill \
    && chown -R agent:agent /workspace /output

# Copy skill files
COPY --chown=agent:agent templates/ /skill/templates/
COPY --chown=agent:agent scripts/ /skill/scripts/
COPY --chown=agent:agent kickoff-prompt.txt /skill/kickoff-prompt.txt
COPY --chown=agent:agent entrypoint.sh /skill/entrypoint.sh
RUN chmod +x /skill/entrypoint.sh /skill/scripts/*.sh

VOLUME /output
WORKDIR /workspace

USER agent

ENTRYPOINT ["/skill/entrypoint.sh"]
